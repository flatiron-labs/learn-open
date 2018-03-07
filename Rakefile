require "bundler/gem_tasks"
require 'pry'

desc "Start Console"
task :console => [:environment] do
  Pry.start
end

task :environment do
  require_relative 'lib/learn_open'
end
