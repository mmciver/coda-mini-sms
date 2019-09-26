module CodaMiniSMS
  module App
    class SMS
      attr_reader :body, :from, :to, :params
      def initialize(params)
        @params = params
        @from = params.fetch(:From)
        @to = params.fetch(:To)
        @body = params.fetch(:Body, '<<No Body>>')
      end

      def validated?
        body =~ /coda/i || DB.query(
          "SELECT * FROM phone_numbers WHERE phone_number = '#{from}'"
        ).length > 0
      end
    end
  end
end
