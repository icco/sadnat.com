# Import in official clean and clobber tasks
require 'rake/clean'
CLEAN.include("data.db")

desc "Create local db."
task :db do
  require "sequel"

  db_url = ENV['DATABASE_URL'] || "sqlite://data.db"
  Kernel.system("sequel -m ./db/ #{db_url}");

  puts "Database migrated."
end
