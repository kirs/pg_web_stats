# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "pg_web_stats"
  spec.version       = "0.0.1"
  spec.authors       = ["Kir Shatrov"]
  spec.email         = ["shatrov@me.com"]
  spec.summary       = %q{Sinatra app for pg_stat_statements}
  spec.description   = %q{Sinatra app for pg_stat_statements}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["**/*.rb"] + %w{config.ru setup.rb}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "pg"
  spec.add_dependency "sinatra"
  spec.add_dependency "sinatra-param"
  spec.add_dependency "coderay"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "thin"
end
