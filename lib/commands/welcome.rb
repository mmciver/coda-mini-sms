# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      # Handles welcome statement commands
      module Welcome
        def self.description
          [
            'Welcome',
            'Sends the current welcome message to you.',
            'or',
            'Welcome <message>',
            "Sets the group's welcome message to the <message>"
          ].join("\n")
        end

        def self.execute(sms)
          if sms.body =~ /^welcome [a-z0-9]+/i
            msg = sms.body.gsub(/^welcome +/i, '').strip
            App::DB.execute("UPDATE groups SET welcome = '#{msg}'")
            sms.from.group[:welcome] = msg
          end
          send_welcome(sms)
        end

        def self.send_welcome(sms)
          App::Sender.send(
            "The group's Welcome message is:\n#{sms.from.group[:welcome]}",
            sms.from.to_s
          )
        end

        FORMAT = '"Welcome" or "Welcome <message>"'
        def self.valid_format?(sms)
          sms.body_numbers.any?
        end

        def self.admin_only?
          true
        end
      end
    end
  end
end
