# Rakefile
require 'rake'
require "sinatra/activerecord/rake"
require 'delayed_job_active_record'

namespace :jobs do
  desc 'Start a delayed_job worker'
  task work: :environment do
    Delayed::Worker.new.start
  end

  desc 'Clear the delayed_job queue'
  task clear: :environment do
    Delayed::Job.delete_all
    puts 'Delayed jobs queue cleared'
  end
end

task :environment do
  require './app'
end
