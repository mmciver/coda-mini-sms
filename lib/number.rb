# frozen_string_literal: true

module CodaMiniSMS
  module App
    # Definition of a phone number
    class Number
      def initialize(number, group_number)
        @string = number
        define_found(number, group_number)
      end

      def define_found(number, group_number)
        @group = App::Group.from_number(group_number)
        @role = @group.dig(:numbers, number, :role) || 'unknown'
        @status = @group.dig(:numbers, number, :status) || 'unknown'
      end

      def to_s
        string
      end

      def active?
        @group[:active].key?(@string)
      end

      def exists?
        @group[:numbers].key?(@string)
      end

      def db_row
        App::DB.query("SELECT * FROM people #{where};").first || {}
      end

      def status=(value)
        @status = value
        @group[:numbers][@string][:status] = @status
        App::DB.execute("UPDATE people SET status = '#{@status}' #{where};")
        App::Sender.send(
          "Your phone number's status has been set to: #{@status}",
          @string
        )
      end

      def role=(value)
        @role = value
        @group[:numbers][@string][:role] = @role
        App::DB.execute("UPDATE people SET role = '#{@role}' #{where};")
        App::Sender.send(
          "Your phone number's role has been set to: #{@role}",
          @string
        )
      end

      def test?
        @group[:numbers][@string][:test]
      end

      def test=(value)
        @group[:numbers][@string][:test] = value
        App::DB.execute("UPDATE people SET test = '#{value}' #{where};")
        App::Sender.send(
          "Your phone number's test status has been set to: #{value}",
          @string
        )
      end

      def where
        "WHERE group_id = #{@group[:id]} AND phone_number = '#{@string}'"
      end

      def add
        App::DB.execute("INSERT INTO people (#{fields}) VALUES (#{values});")
        define_found
      end

      def self.fields
        ['`phone_number`', `group_id`, '`role`', '`status`', '`date`']
      end

      def self.values
        [
          "'#{@string}'",
          "'#{@group[:id]}'",
          'member',
          'active',
          "'#{Time.now}'"
        ].join(', ')
      end
    end
  end
end
