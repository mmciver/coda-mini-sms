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

      def self.validate_number(sms)
        status = Status.of_number(sms.from)
        add_to_database(sms) if status == 'unknown'
        Status.of_number(sms.from)
      end

      def self.handle_valid(sms)
        status = validate_number(sms)

        case status
        when 'active'
          if sms.body =~ /^broadcast$/i
            set_broadcast(sms, :on)
          elsif sms.body =~ /^remove me$/i || sms.body =~ /^stop$/i
            set_inactive(sms)
          elsif sms.body =~ /^query$/i
            send_redacted_numbers(sms)
          elsif sms.body =~ /^recent$/i
            send_last_week_broadcasts(sms)
          else
            send_commands(sms, status)
          end
        when 'broadcast'
          if sms.body =~ /^end$/i
            set_broadcast(sms, :off)
          else
            send_broadcast(sms)
          end
        when 'inactive'
          if sms.body =~ /add me/i
            set_active(sms)
          else
            send_commands(sms, status)
          end
        end
      end

      def self.last_week_of_broadcasts
        msgs = []
        DB.query('SELECT * FROM broadcasts').each do |row|
          t = Time.parse(row['stamp'])
          next if (Time.new - t) > (60 * 60 * 24 * 7)
          msgs << "Sent on: #{t.to_s[0..9]}\n\n#{row['message']}"
        end
        msgs.sort
      end

      def self.send_commands(sms, status)
        msg = ['Valid actions are:']
        msg << 'Text "Add me" to subscribe to the messaging list.' if status == 'inactive'
        msg << 'Text "Remove me" to be removed from the messaging list.' if status == 'active'
        msg << 'Text "Broadcast" to set your phone to automatically send all messages to everyone currently active. This will be turned on for 30 minutes' if status == 'active'
        msg << 'Text "Recent" to see all broadcast messages for the past week.'
        msg << "The current status of your phone number is: #{status}"
        Sender.send(msg.join("\n"), sms.from)
      end

      def self.send_last_week_broadcasts(sms)
        messages = last_week_of_broadcasts
        Sender.send("There were #{messages.length} broadcast over the past week. These are the messages:", sms.from)
        last_week_of_broadcasts.each do |message|
          Sender.send(message, sms.from)
        end
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
          "Text 'Broadcast' to enable sending to all active phone numbers for 30 minutes.",
          "Text 'Recent' to see all broadcast messages for the past week."
        ].join("\n"), sms.from)
        send_last_week_broadcasts(sms)
      end

      def self.set_broadcast(sms, direction)
        case direction
        when :on
          sql = [
            'UPDATE phone_numbers',
            "SET status = 'broadcast',",
            "reference = '#{Time.new.to_s}'",
            "WHERE phone_number = '#{sms.from}'"
          ].join(' ')
          Sender.send("All messages you send to this phone number will be sent to all active phone numbers (#{Status.active_numbers.length - 1} in number) for the next 30 minutes.\nSend 'End' to stop broadcasting immediately.", sms.from)
        when :off
          sql = [
            'UPDATE phone_numbers',
            "SET status = 'active',",
            "reference = '#{Time.new.to_s}'",
            "WHERE phone_number = '#{sms.from}'"
          ].join(' ')
          Sender.send("Broadcasting stopped. Text 'Recent' to see all broadcast messages for the past week.", sms.from)
        end
        DB.execute(sql)
      end

      def self.send_broadcast(sms)
        num_sent = 0
        DB.execute([
          "INSERT INTO broadcasts (from_number, message, stamp) VALUES ('",
          [
            sms.from,
            sms.body,
            Time.new
          ].join("', '"),
          "')"
        ].join(' '))
        destinations = Status.active_numbers(false)
        destinations.each do |phone_number|
          next if sms.from == phone_number


          Sender.send(sms.body, phone_number)
          num_sent += 1
        end
      end

      def self.send_redacted_numbers(sms)
        active = Status.active_numbers(true)
        inactive = Status.inactive_numbers(true)
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
