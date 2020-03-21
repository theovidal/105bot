module Coronagenda
  module Commands
    def Commands.add(args)
      date = Time.new(2020, args[1], args[0], args[2])
      Models::Assignments.create do |assignment|
        assignment.date = date
        assignment.subject = args[3]
        assignment.type = args[4]
        assignment.link = args[5]
        assignment.text = args[6..].join(" ")
      end

      Commands::refresh
    end
  end
end