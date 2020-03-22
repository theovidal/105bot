# Loads a YAML file from data
#
# @param name [String] file's name
def load_yml(name)
  file = File.dirname(__FILE__) + "/../data/#{name}.yml"
  raise StandardError, "The #{name}.yml configuration file is required in the data folder" unless File::exist?(file)
  Psych.load(File.read(file))
end
