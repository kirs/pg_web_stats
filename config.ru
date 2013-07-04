require 'sinatra'
require 'yaml'

require './setup'

helpers do
  def sort_link(title, key, alt_title = nil)
    direction = if params[:order_by] == key && params[:direction] == "desc"
      "asc"
    else
      "desc"
    end

    url = "?order_by=#{key}&direction=#{direction}"
    url += "&userid=#{params[:userid]}" if params[:userid]
    url += "&dbid=#{params[:dbid]}" if params[:dbid]

    "<a href='#{url}' title='#{alt_title}'>#{title}</a>"
  end
end

get '/' do
  order_by = if params[:order_by] && params[:direction]
    "#{params[:order_by]} #{params[:direction]}"
  else
    "total_time desc"
  end

  @stats = PG_WEB_STATS.get_stats(
    order: order_by,
    userid: params[:userid],
    dbid: params[:dbid]
  )

  @databases = PG_WEB_STATS.databases
  @users = PG_WEB_STATS.users

  erb :queries, layout: :application
end

run Sinatra::Application