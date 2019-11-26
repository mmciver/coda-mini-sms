# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Help

        def self.description
          [
            'Help',
            'Sends the list of available commands'
          ].join("\n")
        end

        def self.execute(sms)
          App::Sender.send(
            collect_descriptions.join("\n\n")
            sms.from
          )
        end

        def self.collect_descriptions
          Commands.commands.map do |command|
            command.description
          end
        end

        FORMAT = 'Help'.freeze
        def self.valid_format?(sms)
          true
        end

        def self.admin_only?
          false
        end
      end
    end
  end
end
