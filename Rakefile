# Import in official clean and clobber tasks
require 'rake/clean'
CLEAN.include("db/data.db")

desc "Create local db."
task :db do
  require "sequel"

  db_url = ENV['DATABASE_URL'] || "sqlite://db/data.db"
  ret = Kernel.system("sequel -m ./db/ #{db_url}");

  if ret
    puts "Database migrated."
  else
    puts "Database migration failed."
  end
end
