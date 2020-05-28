require_relative 'command'

module HundredFive
  module Commands
    class Import < Command
      DESC = 'Importer les devoirs de Pronote'
      USAGE = 'import'
      ARGS = {
        acceptDuplicates: {
          description: "Accepter les devoirs déjà inclus dans la base de données (si vous n'êtes pas sûrs, laissez la valeur par défaut)",
          type: Integer,
          boolean: true,
          default: 0
        }
      }

      def self.exec(context, args)
        waiter = Classes::Waiter.new(context, ":airplane_arriving: Importation des devoirs depuis Pronote, veuillez patienter...", "L'exécution de cette commande peut être plus ou moins longue, selon le nombre de devoirs à importer.")

        begin
          crawler_file = File.read("#{CONFIG['bot']['crawler_folder']}/assignments.json")
        rescue
          raise Classes::ExecutionError.new(waiter, "une erreur s'est produite lors de l'ouverture du fichier du crawler. Vérifiez le chemin dans la configuration de 105bot.")
        end

        imported = 0

        assignments = JSON.parse(crawler_file)
        assignments.each do |assignment|
          p args[:acceptDuplicates]
          p Models::Assignments.where(text: assignment['content']).first.nil?
          next unless Models::Assignments.where(text: assignment['content']).first.nil? || args[:acceptDuplicates]

          Models::Assignments.create do |model|
            model.date = Time.at(assignment['due'])
            model.subject = IMPORT_SUBJECTS[assignment['subject']]
            model.type = 'homework'
            model.text = assignment['content']
          end
          imported += 1
        end

        subtext = imported < 1 ? nil : "Rafraichissez l'agenda pour les voir apparaître."
        waiter.finish("Importation de #{imported} devoirs effectuée.", subtext)
      end
    end
  end
end
