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
          if sms.body =~ /^broadcast$/i
            broadcast(sms)
          elsif sms.body =~ /^remove me$/i
            set_inactive(sms)
          elsif sms.body =~ /^query$/i
            send_redacted_numbers(sms)
          else
            send_commands(sms, status)
          end
        when 'inactive'
          if sms.body =~ /add me/i
            set_active(sms)
          else
            send_commands(sms, status)
          end
        end
      end

      def self.send_commands(sms, status)
        msg = ['Valid actions are:']
        msg << 'Text "Add me" to subscribe to the messaging list.' if status == 'inactive'
        msg << 'Text "Remove me" to be removed from the messaging list.' if status == 'active'
        msg << 'Text "Broadcast" to set your phone to automatically send all messages to everyone currently active. This will be turned on for 5 minutes' if status == 'active'
        msg << "The current status of your phone number is: #{status}"
        Sender.send(msg.join("\n"), sms.from)
      end

      def self.add_to_database(sms)
        sql = [
          'INSERT INTO phone_numbers',
          '(phone_number, status)',
          "VALUES ('#{sms.from}', 'inactive')"
        ]
        DB.execute(sql.join(' '))
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

      def self.set_active(sms)
        sql = [
          'UPDATE phone_numbers',
          "SET status = 'active'",
          "WHERE phone_number = '#{sms.from}'"
        ]
        DB.execute(sql.join(' '))
        Sender.send([
          "Your phone number has been set to active.",
          "Text 'Remove me' to remove yourself from the subscription list.",
          "Text 'Broadcast' followed by a message to send to all active numbers."
        ].join("\n"), sms.from)
      end

      def self.set_broadcast
        sql = [
          'UPDATE phone_numbers',
          "SET status = 'broadcast'",
          "WHERE phone_number = '#{sms.from}'"
        ]
        DB.execute(sql.join(' '))
      end

      def self.broadcast(sms)
        message = sms.body.gsub(/^broadcast/i,'').gsub("'",'').strip
        num_sent = 0
        destinations = active_phone_numbers
        Sender.send("Sending this message to #{destinations.length - 1} phone numbers: #{message}", sms.from)
        return false
        destinations.each do |phone_number|
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

      def self.redacted_phone_numbers(status)
        sql = "SELECT * FROM phone_numbers WHERE status = '#{status}'"
        DB.query(sql).each_with_index.map do |row, i|
          "#{i + 1}: #{row['phone_number'][-4..-1]}"
        end
      end

      def self.send_redacted_numbers(sms)
        sql = "SELECT * FROM phone_numbers"
        active = redacted_phone_numbers('active')
        inactive = redacted_phone_numbers('inactive')
        msg = [
          "#{active.length} active phone numbers",
          active,
          "#{inactive.length} inactive phone numbers.",
          inactive
        ].flatten.join("\n")
        Sender.send(msg, sms.from)
      end
    end
  end
end
