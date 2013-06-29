class PgWebStats
  attr_accessor :config, :connection

  def initialize(config_path)
    self.config = YAML.load_file(config_path)
    self.connection = PG.connect(
      dbname: config['database'],
      host: config['host'],
      user: config['user'],
      password: config['password'],
      port: config['port']
    )

    # create_extension
  end

  def get_stats(order_by)
    results = []
    connection.exec("SELECT * FROM pg_stat_statements order by #{order_by}") do |result|
      result.each do |row|
        results << Row.new(row)
      end
    end

    results
  end

  private

  def create_extension
    connection.exec('CREATE EXTENSION pg_stat_statements')
  end
end

class PgWebStats::Row
  attr_accessor :data

  def initialize(data)
    self.data = data
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

  def waste?
    clean_query = self.query.dup.downcase.strip
    keywords = ['show', 'set', 'rollback', 'savepoint', 'release', 'begin', 'create_extension']
    keywords.any? { |k| clean_query.start_with?(k) }
  end
end
