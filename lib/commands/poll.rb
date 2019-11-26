# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Poll

        def self.description
          [
            '',
            ''
          ].join("\n")
        end

        def self.execute(sms)
        end

        FORMAT = 'Poll <question>'.freeze
        def self.valid_format?(sms)
          sms.body =~ /^poll /i
        end

        def self.admin_only?
          true
        end
      end
    end
  end
end
