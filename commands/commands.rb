module Coronagenda
  module Commands
    LIST = {
      'refresh' => -> (_, _) { refresh },
      'add' => -> (_, args) { add(args) },
      'show' => -> (context, args) { show(context, args) },
      'hide' => -> (context, args) { hide(context, args) }
    }
  end
end