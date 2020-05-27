require_relative 'storage'

module HundredFive
  CONFIG = load_yml('config')

  SUBJECTS = load_yml('subjects')

  IMPORT_SUBJECTS = load_yml('import_subjects')

  strings = load_yml('strings')

  EMOJI_DAYS = strings['emoji_days']

  MONTHS = strings['months']

  DAYS = strings['days']
end