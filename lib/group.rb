# frozen_string_literal: true

module CodaMiniSMS
  module App
    # Handles group level data on a per-number basis
    module Group
      # rubocop:disable Metrics/MethodLength
      def self.from_number(number)
        group = group_info(number)
        id = group['id']
        phone_numbers = numbers(id)
        {
          id: id,
          number: number,
          password: group['password'],
          admins: admins(phone_numbers),
          members: members(phone_numbers),
          numbers: phone_numbers(id),
          active: active(phone_numbers),
          inactive: inactive(phone_numbers),
          banned: banned(phone_numbers),
          welcome: group['welcome'],
          weekly: group['weekly']
        }
      end
      # rubocop:enable Metrics/MethodLength

      def self.group_info(number)
        App::DB.query(
          "SELECT * FROM groups WHERE phone_number = '#{number}'"
        ).first
      end

      def self.numbers(id)
        group = App::DB.query("SELECT * FROM people WHERE group_id = #{id}")
        Hash[
          group.map do |row|
            [
              row['phone_number'],
              Hash[row.map { |key, value| [key.intern, value] }]
            ]
          end
        ]
      end

      def self.admins(phone_numbers)
        phone_numbers.select do |_number, info|
          info[:role] == 'admin'
        end
      end

      def self.members(phone_numbers)
        phone_numbers.select do |_number, info|
          info[:role] == 'member'
        end
      end

      def self.active(phone_numbers)
        phone_numbers.select do |_number, info|
          info[:status] == 'active'
        end
      end

      def self.inactive(phone_numbers)
        phone_numbers.select do |_number, info|
          info[:status] == 'inactive'
        end
      end

      def self.banned(phone_numbers)
        phone_numbers.select do |_number, info|
          info[:status] == 'banned'
        end
      end
    end
  end
end
