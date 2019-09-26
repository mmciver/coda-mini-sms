module CodaMiniSMS
  module App
    module Sender

      CLIENT = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH_TOKEN'])

      def self.send(message, number)
        return empty_message if empty?(message)
        puts "SID token length: #{ENV['TWILIO_SID'].length}"
        puts "AUTH token length: #{ENV['TWILIO_AUTH_TOKEN'].length}"

        CLIENT.messages.create(
          from: ENV['TWILIO_PHONE_NUMBER'],
          to: number,
          body: message
        )
      end

      def self.empty?(message)
        message.nil? || message.empty?
      end

      def self.empty_message
        warn('No message was supplied for Send Method')
        :empty_message
      end
    end
  end
end
