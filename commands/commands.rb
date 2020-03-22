module Coronagenda
  module Commands
    LIST = {
      'refresh' => -> (_) { refresh },
      'add' => -> (args) { add(args) },
      'show' => -> (args) { show(args) }
    }
  end
end