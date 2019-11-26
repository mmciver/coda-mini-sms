# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      # Handle testing status
      module Test
        def self.description
          [
            'Test',
            'Sets the application into a testing state for the sending number',
            'This reflects the results of all commands back at the number',
            'instead of applying them'
          ].join("\n")
        end

        def self.execute(sms)
          sms.from.test? ? test_off(sms) : test_on(sms)
        end

        def self.test_off(sms)
          sms.from.test = false
        end

        def self.test_on(sms)
          sms.from.test = true
        end

        FORMAT = 'Test'
        def self.valid_format?(_sms)
          true
        end

        def self.admin_only?
          true
        end
      end
    end
  end
end
