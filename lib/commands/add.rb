# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Add

        def self.description
          [
            'Add <phone_number>',
            'Adds a phone number to the member list.',
            'The phone number must be in the correct format with + and the country code',
            'Example: "Add +15551234567" will add the US number (555) 123-4567',
          ].join("\n")
        end

        def self.execute(sms)
          sms.body_numbers.each do |number|
            if number.exists?
              number.status = 'Active'
            else
              number.add
            end
          end
          send_complete(sms)
        end

        def self.send_complete(sms)
          App::Sender.send(
            sms.body_numbers.map { |number| "#{number.string} is #{number.status}" }.join("\n"),
            sms.from.to_s
          )
        end

        FORMAT = 'Add +15551234567'.freeze
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
