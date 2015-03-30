$LOAD_PATH << "#{File.expand_path(File.dirname(__FILE__))}/../lib"
RSpec.configure do |config|
  config.formatter = :documentation
end
