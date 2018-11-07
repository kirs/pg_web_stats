require 'pg'
require 'coderay'
require 'yaml'

class PgWebStats
  attr_accessor :default_server, :connections

  def initialize(config_path = 'config.yml')
    hash = config_path.is_a?(Hash) ? config_path : YAML.load_file(config_path)

    self.default_server = nil
    self.connections = Hash.new
    hash.each do |name, config|
      self.default_server = name unless self.default_server
      self.connections[name] = PG.connect(
        dbname: config['database'],
        host: config['host'],
        user: config['user'] || config['username'],
        password: config['password'],
        port: config['port']
      )
    end
    if self.connections.length < 1
      raise RuntimeError, "configuration must contain at least one server"
    end
  end

  def reset_stats(server)
    connections[server].exec("SELECT pg_stat_statements_reset()")
  end

  def get_stats(server, params = { order: "total_time desc" })
    connection = connections[server]
    query = build_stats_query_base(connection, "COUNT(*) AS count", params)

    count = 0
    connection.exec(query) do |result|
      count = result[0]["count"].to_i
    end

    query = build_stats_query(connection, "*", params)

    results = []
    connection.exec(query) do |result|
      result.each do |row|
        results << Row.new(row, users(server), databases(server))
      end
    end

    {total: count, items: results}
  end

  def users(server)
    @users ||= Hash.new

    if not @users.has_key? server
      @users[server] = select_by_oid(server, "select oid, rolname from pg_authid order by rolname;", 'rolname')
    end

    @users[server]
  end

  def databases(server)
    @databases ||= Hash.new

    if not @databases.has_key? server
      @databases[server] = select_by_oid(server, "select oid, datname from pg_database order by datname;", 'datname')
    end

    @databases[server]
  end

  private

  def select_by_oid(server, select_query, row_name)
    @selection = {}
    connections[server].exec(select_query) do |result|
      result.each do |row|
        @selection[row['oid']] = row[row_name]
      end
    end

    @selection
  end

  def build_stats_query_base(connection, what, params)
    query = "SELECT #{what} FROM pg_stat_statements"

    where_conditions = []

    userid = params[:userid]
    if userid && !userid.empty?
      where_conditions << "userid=#{userid}"
    end

    dbid = params[:dbid]
    if dbid && !dbid.empty?
      where_conditions << "dbid=#{dbid}"
    end

    q = params[:q]
    if q && !q.empty?
      where_conditions << "query LIKE '#{connection.escape_string(q)}%'"
    end

    query += " WHERE #{where_conditions.join(" AND ")}" if where_conditions.size > 0

    query
  end

  def build_stats_query(connection, what, params)
    order_by = params[:order]

    query = build_stats_query_base(connection, "*", params)

    order_by = if params[:order_by] && params[:direction]
      "#{params[:order_by]} #{params[:direction]}"
    else
      "total_time desc"
    end
    query += " ORDER BY #{order_by}"

    count = params[:count] ? params[:count].clamp(1, 1000) : 25
    query += " LIMIT #{count}"

    if params[:offset] > 0
      query += " OFFSET #{params[:offset]}"
    end

    query
  end
end

class PgWebStats::Row
  attr_accessor :data, :users, :databases

  def initialize(data, users, databases)
    self.data = data
    self.users = users
    self.databases = databases
  end

  def respond_to?(method_sym, include_private = false)
    if data[method_sym.to_s]
      true
    else
      super
    end
  end

  def method_missing(method_sym, *arguments, &block)
    if result = data[method_sym.to_s]
      result
    else
      super
    end
  end

  def user
    users[userid]
  end

  def db
    databases[dbid]
  end

  def query
    CodeRay.scan(data["query"].gsub(/\s+/, ' ').strip, "sql").div(:css => :class)
  end

  def waste?
    clean_query = self.query.dup.downcase.strip
    keywords = ['show', 'set', 'rollback', 'savepoint', 'release', 'begin', 'create_extension']
    keywords.any? { |k| clean_query.start_with?(k) }
  end
end
