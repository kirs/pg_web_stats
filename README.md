pg_web_stats
============

![](http://f.cl.ly/items/1M2D402O0E0c0p2Y461E/Screen%20Shot%202013-06-29%20at%2012.30.22.png)

Sexy sinatra app for [pg_stat_statements](http://www.postgresql.org/docs/9.2/static/pgstatstatements.html). [![Code Climate](https://codeclimate.com/github/kirs/pg_web_stats.png)](https://codeclimate.com/github/kirs/pg_web_stats)

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

### Features

* Sorting by any column from pg_stat_statements
* Filtering by database or user
* Highlighting important queries && hidding not important queries

## Installation

0. Prepare your PG setup: enable the `pg_stat_statements` extension and execute `CREATE EXTENSION pg_stat_statements` inside the database you want to inspect. *Hint: there is an [awesome article about pg_stat_statements in russian](http://evtuhovich.ru/blog/2013/06/28/pg-stat-statements/#comment-945382408).*
1. Clone the repo
2. Fill `config.yml.example` with your credentians and save it as `config.yml`
3. Start the app: `rake server` (or run `rake console` to have command line)
4. ???
5. PROFIT

## Mount inside a rails app

Add this line to your application's Gemfile:

    gem 'pg_web_stats', require: 'pg_web_stats_app'

Or if gem is not released yet

    gem 'pg_web_stats', git: 'https://github.com/shhavel/pg_web_stats', require: 'pg_web_stats_app'

And then execute:

    $ bundle

Create file config/initializers/pg_web_stats.rb

```ruby
# Configure database connection
config_hash = YAML.load_file(Rails.root.join('config', 'database.yml'))[Rails.env]
PG_WEB_STATS = PgWebStats.new(config_hash)

# Restrict access to pg_web_stats with Basic Authentication
# (or use any other authentication system).
PgWebStatsApp.use(Rack::Auth::Basic) do |user, password|
  password == "secret"
end
```

Add to routes.rb

```ruby
mount PgWebStatsApp, at: '/pg_stats'
```

Restart rails app and visit [http://localhost:3000/pg_stats](http://localhost:3000/pg_stats)

<hr />
Made by [Kir Shatrov](https://github.com/kirs), sponsored by [Evil Martians](http://evl.ms).

Thanks to [Ivan Evtuhovich](https://twitter.com/evtuhovich) for advice about making this app.
