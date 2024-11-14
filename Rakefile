# Rakefile
require 'rake'
require "sinatra/activerecord/rake"
require 'delayed_job_active_record'

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    require './app'

    ActiveRecord::Migrator.migrations_paths = ['db/migrate']
    ActiveRecord::Base.establish_connection
    ActiveRecord::MigrationContext.new('db/migrate').migrate
    puts 'Database migrated'
  end

  desc 'Create the database'
  task :create do
    require './app'

    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.create_database
    puts 'Database created'
  end
end
