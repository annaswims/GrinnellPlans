source 'http://rubygems.org'
source  'http://gems.github.com'

gem 'rails', '3.0.4'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'

# Deploy with Capistrano
gem 'capistrano'
gem 'mysql'
gem 'haml'

#https://github.com/rails/jquery-ujs
gem 'jquery-rails', '>= 0.2.6'

group :production do
  gem "exception_notification", :git => "git://github.com/rails/exception_notification", :require => 'exception_notifier'
end

group :development do
  gem 'hirb'
  gem 'annotate'
  gem "railroady"
  # gem 'rails3-footnotes'
  # To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
   gem 'ruby-debug'
  # gem 'ruby-debug19'
end
