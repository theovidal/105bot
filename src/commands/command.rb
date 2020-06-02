module HundredFive
  module Commands
    class Command
      DESC = 'Socle des commandes'
      USAGE = 'commande'
      CATEGORY = 'default'
      LISTEN = %w(public)
      ARGS = {}

      def self.exec(_, _)
        # --
      end
    end
  end
end
