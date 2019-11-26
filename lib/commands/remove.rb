# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      # Handles removing a member from active status
      module Remove
        def self.description
          [
            'Remove <phone_number>',
            'Removes a phone number from the active member list.',
            'The number must be in the correct format with +<country_code>',
            'Example: "Add +15551234567" will add the US number (555) 123-4567'
          ].join("\n")
        end

        def self.execute(sms)
          sms.body_numbers.each do |number|
            next unless number.exists?
            next unless number.status == 'Active'

            number.status = 'Inactive'
          end
          send_complete(sms)
        end

        def self.send_complete(sms)
          number_statuses = sms.body_numbers.map do |number|
            "#{number.string} is #{number.status}"
          end

          App::Sender.send(
            number_statuses.join("\n"),
            sms.from.to_s
          )
        end

        FORMAT = 'Remove +15551234567'
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
