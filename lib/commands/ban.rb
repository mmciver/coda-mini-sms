# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Ban

        def self.description
          [
            'Ban <phone_number>',
            'Bans a phone number from membership, preventing them from interacting with the messaging system. All admins will be notified of this change.',
            'The phone number must be in the correct format with + and the country code',
            'Example: "Ban +15551234567" will ban the US number (555) 123-4567',
          ].join("\n")
        end

        def self.execute(sms)
          changed = []
          sms.body_numbers.each do |number|
            next unless number.exists?

            number.status = 'Banned'
            changed << number.to_s
          end
          send_complete(sms)
          send_banned_alert(sms, changed)
        end

        def self.send_complete(sms)
          App::Sender.send(
            sms.body_numbers.map { |number| "#{number.string} is #{number.status}" }.join("\n"),
            sms.from.to_s
          )
        end

        def self.send_banned_alert(sms, changed)
          sms.from.group[:admins].each do |admin|
            App::Sender.send(
              "The following phone numbers have been banned from the system: #{changed.join(', ')}",
              admin[:phone_number]
            )
          end
        end

        FORMAT = 'Ban +15551234567'.freeze
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
