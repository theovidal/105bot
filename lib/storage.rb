require 'psych'

# Loads a YAML file from data
#
# @param name [String] file's name
def load_yml(name)
  file = File.dirname(__FILE__) + "/../data/#{name}.yml"
  raise StandardError, "The #{name}.yml configuration file is required in the data folder" unless File::exist?(file)
  Psych.load(File.read(file))
end

# Loads the configuration according to the development environment
def load_config
  config = load_yml('config')
  return ENV['BOT_ENV'] == 'development' ? load_yml('config.dev') : config
end
