pg_web_stats
============

Sexy sinatra app for pg_stat_statements.

## Installation

0. Prepage your pg installation: enable the `pg_stat_statements` and execute `CREATE EXTENSION pg_stat_statements` for the DB you want to inspect. Hint: there is an [awesome article about pg_stat_statements in russian](http://evtuhovich.ru/blog/2013/06/28/pg-stat-statements/#comment-945382408).
1. Clone the repo
2. Fill `config.yml.example` with your credentians and save it as `config.yml`
3. Start the app: `ruby web.rb`
4. ???
5. PROFIT

Made by [Kir Shatrov](https://github.com/kirs), sponsored by [Evil Martians](http://evl.ms).

Thanks [evtuhovich](https://twitter.com/evtuhovich) for advice about making this project.