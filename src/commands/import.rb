require 'net/http'
require_relative 'command'

module HundredFive
  module Commands
    class Import < Command
      DESC = 'Importer les devoirs de Pronote'
      CATEGORY = 'agenda'
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
          response = Net::HTTP.get_response(CONFIG['bot']['crawler']['host'], '/assignments', CONFIG['bot']['crawler']['port'])
          case response.code.to_i
          when 404 then raise Classes::ExecutionError.new(waiter, "l'adresse URL vers le crawler est inconnue. Veuillez la vérifier dans la configuration du robot.")
          else nil
          end
        rescue SocketError
          raise Classes::ExecutionError.new(waiter, "la connexion avec le crawler n'a pu s'effectuer. Vérifier son adresse dans la configuration du robot.")
        end

        imported = 0

        assignments = JSON.parse(response.body)['data']
        assignments.each do |assignment|
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
