require_relative 'storage'

module Coronagenda
  CONFIG = load_yml('config')

  SUBJECTS = load_yml('subjects')

  strings = load_yml('strings')

  EMOJI_DAYS = strings['emoji_days']

  MONTHS = strings['months']

  DAYS = strings['days']
end