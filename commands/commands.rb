module Coronagenda
  module Commands
    LIST = {
      'refresh' => -> (_) { refresh },
      'add' => -> (args) { add(args) },
      'generate' => -> (args) { generate(args) }
    }
  end
end