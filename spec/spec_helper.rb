# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'pry-remote'
require 'mocha'

require "capybara/rspec"


# class ActiveRecord::Base
#   mattr_accessor :shared_connection
#   @@shared_connection = nil

#   def self.connection
#     @@shared_connection || retrieve_connection
#   end
# end

# ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit
Capybara.ignore_hidden_elements = true
Capybara.default_wait_time = 5
#Capybara.asset_host = 'http://localhost:3000'

if ENV["VAGRANT_DEV"]
  Capybara.save_and_open_page_path = "/vagrant/tmp/capybara"
  module Capybara
    class Session
      def save_and_open_page(file_name=nil)
        save_page file_name
      end
    end
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
if ActiveRecord::Migrator.needs_migration?
  drop_constraints = ActiveRecord::Base.connection.select_all <<-SQL
  SELECT 'ALTER TABLE '||table_name||' DROP CONSTRAINT  IF EXISTS '||constraint_name||' CASCADE;' as sql
    FROM information_schema.constraint_table_usage;
  SQL

  drop_constraints.each do |drop_constraint|
    ActiveRecord::Base.connection.execute(drop_constraint['sql'])
  end
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.mock_with :mocha

  if defined? FactoryGirl
    FactoryGirl::SyntaxRunner.send(:include, FactoryGirlHelpers)
  end

  config.include QuestionEditorHelpers, type: :feature
  config.include ProjectEditorHelpers, type: :feature
  config.include FormResponseHelpers, type: :feature
  config.include EmberHelpers, type: :feature
  config.include UserHelpers, type: :feature
  config.include ControllerHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include MockSelfHelpers

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    $FAILURE_FILE = File.open("./.rspec-failures", "w")
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

  config.after(:each) do
    if example.exception
      $FAILURE_FILE.write("--example \"#{example.full_description}\" ")
    end
  end

  config.after(:suite) do
    if $FAILURE_FILE
      $FAILURE_FILE.close
    end
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
