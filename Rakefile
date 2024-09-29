# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rails_best_practices/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new
RailsBestPractices::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop rails_best_practices spec]
