pg_web_stats
============

[![Code Climate](https://codeclimate.com/github/kirs/pg_web_stats.png)](https://codeclimate.com/github/kirs/pg_web_stats)

![](http://f.cl.ly/items/1M2D402O0E0c0p2Y461E/Screen%20Shot%202013-06-29%20at%2012.30.22.png)

Sexy sinatra app for [pg_stat_statements](http://www.postgresql.org/docs/9.2/static/pgstatstatements.html). [![Code Climate](https://codeclimate.com/github/kirs/pg_web_stats.png)](https://codeclimate.com/github/kirs/pg_web_stats)

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


Made by [Kir Shatrov](https://github.com/kirs), sponsored by [Evil Martians](http://evl.ms).

Thanks to [Ivan Evtuhovich](https://twitter.com/evtuhovich) for advice about making this app.
