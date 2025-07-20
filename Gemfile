source "https://rubygems.org"

gem "rails", "~> 8.0"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "bootstrap", "~> 5.3"
gem "sassc-rails"
gem "sprockets-rails"

# BJJ Seminar Tracker specific gems
gem "phlex-rails"
gem "geocoder"
gem "rack-attack"
gem "web-push"

group :development, :test do
  gem "bootsnap", require: false
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  
  # Code quality and style checking
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-rspec", require: false
  
  # Testing framework
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
  gem "cucumber-rails", require: false
  gem "faker"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  
  # LSP support
  gem "ruby-lsp", require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  
  # Code coverage analysis
  gem "simplecov", require: false
  
  # Database cleaning for tests
  gem "database_cleaner-active_record"
  
  # Controller testing helpers
  gem "rails-controller-testing"
end
