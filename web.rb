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

    "<a href='?order_by=#{key}&direction=#{direction}' title='#{alt_title}'>#{title}</a>"
  end
end

get '/' do
  order_by = if params[:order_by] && params[:direction]
    "#{params[:order_by]} #{params[:direction]}"
  else
    "total_time desc"
  end

  @stats = pg_web_stats.get_stats(order_by)

  erb :queries, layout: :application
end