require 'bundler/setup'
require "active_record"

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s puma -p 9393")
end

namespace :db do

  desc "Migrate the database"
  task :migrate do
    require File.expand_path("../config/database.rb", __FILE__)
    ActiveRecord::Migrator.migrate("db/migrate/")
    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    require File.expand_path("../config/database.rb", __FILE__)
    require 'active_record/schema_dumper'
    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
end
