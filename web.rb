require 'pg'
require 'sinatra'
require 'yaml'

$:.unshift File.dirname(__FILE__)
require 'pg_web_stats'

pg_web_stats = PgWebStats.new("config.yml")

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

  @stats = pg_web_stats.get_stats(
    order: order_by,
    userid: params[:userid],
    dbid: params[:dbid]
  )

  @databases = pg_web_stats.databases
  @users = pg_web_stats.users

  erb :queries, layout: :application
end