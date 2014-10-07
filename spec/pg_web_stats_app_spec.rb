require 'spec_helper'
require 'pg_web_stats_app'

PG_WEB_STATS = PgWebStats.new(File.expand_path(File.join(File.dirname(__FILE__), 'config.yml')))

def app
  PgWebStatsApp
end

describe "PgWebStatsApp", :type => :request do
  before(:all) do
    PG_WEB_STATS.connection.instance_eval do
      exec('CREATE EXTENSION IF NOT EXISTS pg_stat_statements')
      exec('CREATE TABLE IF NOT EXISTS users ("id" INTEGER PRIMARY KEY NOT NULL, "name" varchar(255) NOT NULL)')
      exec('TRUNCATE TABLE users')
      exec('SELECT pg_stat_statements_reset()')
      exec(%q(INSERT INTO users ("id", "name") VALUES ('1', 'Alex')))
      exec(%q(INSERT INTO users ("id", "name") VALUES ('2', 'Ted')))
      exec(%q(SELECT * FROM users))
      exec(%q(SELECT * FROM users WHERE id = '1'))
    end
  end

  describe "GET on /" do
    subject { last_response }

    it "responds with 200 status" do
      get '/'
      should be_ok
    end
  end

  describe "filter by query" do
    subject { last_response.body.gsub(/<[^<>]+>/, '') }

    it 'retults only results with matching query from start' do
      get '/?q=SELECT+*+FROM+users'

      expect(subject).to include 'SELECT * FROM users'
      expect(subject).to include 'SELECT * FROM users WHERE id = ?'
      expect(subject).to_not include 'INSERT'
    end
  end
end
