require_relative 'command'

module HundredFive
  module Commands
    class Import < Command
      DESC = 'Importer les devoirs de Pronote'
      USAGE = 'import'
      ARGS = {}

      def self.exec(context, _args)
        waiter = Classes::Waiter.new(context, ":airplane_arriving: Importation des devoirs depuis Pronote, veuillez patienter...", "L'exécution de cette commande peut être plus ou moins longue, selon le nombre de devoirs à importer.")

        begin
          crawler_file = File.read("#{CONFIG['bot']['crawler_folder']}/assignments.json")
        rescue
          raise Classes::ExecutionError.new(waiter, "une erreur s'est produite lors de l'ouverture du fichier du crawler. Vérifiez le chemin dans la configuration de 105bot.")
        end

        assignments = JSON.parse(crawler_file)
        assignments.each do |assignment|
          Models::Assignments.create do |model|
            model.date = Time.at(assignment['due'])
            model.subject = IMPORT_SUBJECTS[assignment['subject']]
            model.type = 'homework'
            model.text = assignment['content']
          end
        end

        waiter.finish("Importation des devoirs effectuée.", "Rafraichissez l'agenda pour les voir apparaître.")
      end
    end
  end
end
