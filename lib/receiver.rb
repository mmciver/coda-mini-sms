module CodaMiniSMS
  module App
    module Receiver

      def self.receive(params)
        sms = SMS.new(params)
        record_sms(sms)
        sms.validated? ? handle_valid(sms) : :invalid_message
      end

      def self.record_sms(sms)
        sql = [
          'INSERT INTO messages',
          '(from_number, to_number, body, state, country, timestamp)',
          "VALUES (",
          "'#{sms.from}',",
          "'#{sms.to}',",
          "'#{sms.body}',",
          "'#{sms.params.fetch(:State, '<<NoState>>')}',",
          "'#{sms.params.fetch(:Country, '<<NoCountry>>')}',",
          "'#{Time.now.to_s}'",
          ")"
        ]
        DB.execute(sql.join(' '))
      end

      def self.number_status(sms)
        sql = "SELECT * FROM phone_numbers WHERE phone_number = '#{sms.from}'"
        result = DB.query(sql)
        if result.empty?
          add_to_database(sms)
          return 'inactive'
        end

        result.first.fetch('status')
      rescue => e
        puts sms.inspect
        puts sql.inspect
        puts result.inspect
      end

      def self.send_status(sms)
        Sender.send("Your status is: #{number_status(sms)}", sms.from)
      end

      def self.handle_valid(sms)
        status = number_status(sms)

        case status
        when 'active'
          if sms.body =~ /broadcast/i
            broadcast(sms)
          elsif sms.body =~ /^remove me$/i
            set_inactive(sms)
          else
            send_commands(sms, status)
          end
        when 'inactive'
          if sms.body =~ /add me/i
            set_to_active
          else
            send_commands(sms, status)
          end
        end
      end

      def self.send_commands(sms, status)
        msg = ['Valid actions are:']
        msg << 'Text "Add me" to subscribe to the messaging list.' if status == 'inactive'
        msg << 'Text "Remove me" to be removed from the messaging list.' if status == 'active'
        msg << 'Text "Broadcast" followed by a message to send that message to all active phone numbers' if status == 'active'
        msg << "The current status of your phone number is: #{status}"
        Sender.send(msg.join(' '), sms.from)
      end

      def self.add_to_database(sms)
        sql = [
          'INSERT INTO phone_numbers',
          '(phone_number, status)',
          "VALUES ('#{sms.from}', 'inactive')"
        ]
        DB.execute(sql.join(' '))
        Sender.send("Your phone number is not active. Text 'Add me' to enable receiving broadcast messages.", sms.from)
      end

      def self.set_inactive(sms)
        sql = [
          'UPDATE phone_numbers',
          "SET status = 'inactive'",
          "WHERE phone_number = '#{sms.from}'"
        ]
        DB.execute(sql.join(' '))
        Sender.send("Your phone number has been set to inactive", sms.from)
      end

      def self.broadcast(sms)
        message = sms.body.gsub(/^.*broadcast/i,'').strip
        num_sent = 0
        active_phone_numbers.each do |phone_number|
          next if sms.from == phone_number

          Sender.send(message, phone_number)
          num_sent += 1
        end
        Sender.send("Your broadcast message has been sent to #{num_sent} phone numbers.", sms.from)
      end

      def self.active_phone_numbers
        sql = "SELECT * FROM phone_numbers WHERE status = 'active'"
        DB.query(sql).map { |row| row['phone_number'] }.uniq
      end
    end
  end
end
