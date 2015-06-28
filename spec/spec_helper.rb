require 'bundler/setup'
Bundler.setup

# gems
require 'pry'

# files
require_relative '../lib/fire-model'

RSpec.configure do |config|

  config.before :all do
    Fire.setup(firebase_path: ENV['TEST_FIREBASE_URL'])
    Fire.logger.level = Logger::INFO
  end

end
