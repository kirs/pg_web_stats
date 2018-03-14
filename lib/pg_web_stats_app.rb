require 'sinatra'
require 'sinatra/param'
require 'pg_web_stats'

class PgWebStatsApp < Sinatra::Base
  helpers Sinatra::Param

  set :root,  File.expand_path(File.join(File.dirname(__FILE__), '../'))
  set :views, File.join(settings.root, 'views')

  helpers do
    def link(title, update, alt_title = nil)
      update = Hash[update.map{ |k, v| [k.to_s, v] }]
      url = "?" + URI.encode_www_form(params.merge(update))

      "<a href='#{url}' title='#{alt_title}'>#{title}</a>"
    end

    def page_links
      offset = params[:offset]
      count = params[:count]

      pages = @stats[:total].fdiv(count).floor  # Pages are 0-indexed, so floor
      this_page = offset.fdiv(count).floor

      Enumerator.new do |enum|
        if offset > 0
          enum.yield text: 'prev', offset: [0, offset - count].max
        end

        [0, this_page - 4].max.upto([this_page + 4, pages].min) do |page|
          classname = page == this_page ? "active" : ""
          enum.yield text: (page + 1).to_s, offset: page * count, class: classname
        end

        if @stats[:items].length >= count
          enum.yield text: 'next', offset: offset + count
        end
      end
    end

    def sort_link(title, update, alt_title = nil)
      direction = if params[:order_by] == update && params[:direction] == "desc"
        "asc"
      else
        "desc"
      end
      update = {
        order_by: update,
        direction: direction,
        offset: 0   # Changing sorting resets pagination
      }
      link title, update, alt_title
    end

    def page_link(info)
      text = info.delete(:text)
      classname = info.delete(:class)
      attrs = classname && !classname.empty? ? " class=\"#{classname}\"" : ""
      "<li#{attrs}>" + link(text, info) + "</li>"
    end
  end

  get '/' do
    @servers = PG_WEB_STATS.connections.keys
    if @servers.length == 1
      redirect '/' + PG_WEB_STATS.default_server + '/', 307
    else
      erb :servers, layout: :application
    end
  end

  get '/:server/' do |server|
    param :q,          String
    param :userid,     String, format: /^\d*$/
    param :dbid,       String, format: /^\d*$/
    param :count,      Integer, default: 25
    param :offset,     Integer, default: 0
    param :order_by,   String, default: "total_time"
    param :direction,  String, in: ["asc", "desc"], default: "desc"

    all_keys = %w{q userid dbid count offset order_by direction}
    params.select {|key| all_keys.include? key}

    if not PG_WEB_STATS.connections.has_key? server
      halt(404)
    end

    @stats = PG_WEB_STATS.get_stats(server, params)
    @databases = PG_WEB_STATS.databases(server)
    @users = PG_WEB_STATS.users(server)

    erb :queries, layout: :application
  end
end
