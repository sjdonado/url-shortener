# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/app/channels'
    add_filter '/app/mailers'
    add_filter '/app/jobs'

    enable_coverage :branch
  end

  simplecov_formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(simplecov_formatters)

  SimpleCov::Formatter::Console.show_covered = true

  puts 'required simplecov'
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
