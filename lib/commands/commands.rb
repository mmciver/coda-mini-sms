# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands

      autoload :Help, 'lib/commands/help'
      autoload :Password, 'lib/commands/password'
      autoload :List, 'lib/commands/list'
      autoload :Remove, 'lib/commands/remove'
      autoload :Ban, 'lib/commands/ban'
      autoload :Add, 'lib/commands/add'
      autoload :Test, 'lib/commands/test'
      autoload :Cost, 'lib/commands/cost'
      autoload :Resign, 'lib/commands/resign'
      autoload :Promote, 'lib/commands/promote'
      autoload :Demote, 'lib/commands/demote'
      autoload :Welcome, 'lib/commands/welcome'
      autoload :Recent, 'lib/commands/recent'
      autoload :Leave, 'lib/commands/leave'
      autoload :Join, 'lib/commands/join'
      autoload :Poll, 'lib/commands/poll'

      def self.commands
        {
          help: Commands::Help,
          password: Commands::Password,
          list: Commands::List,
          remove: Commands::Remove,
          ban: Commands::Ban,
          add: Commands::Add,
          test: Commands::Test,
          cost: Commands::Cost,
          resign: Commands::Resign,
          promote: Commands::Promote,
          demote: Commands::Demote,
          welcome: Commands::Welcome,
          recent: Commands::Recent,
          stop: Commands::Leave,
          end: Commands::Leave
          leave: Commands::Leave,
          join: Commands::Join,
          start: Commands::Join,
          poll: Commands::Poll,
          vote: Commands::Vote,
          #block: Commands::Block,
          #snooze: Commands::Snooze,
          #sleep: Commands::Sleep,
          #report: Commands::Report
        }
      end

      def self.execute(sms)
        cmd = command(sms)

        if cmd.valid_format?(sms)
          cmd.execute(sms)
        else
          send_invalid_format(sms, cmd)
        end
      end

      def self.command(sms)
        commands[possible_commands(sms).first.intern]
      end

      def self.possible_commands(sms)
        sms.body.scan(/^(?:#{commands.keys.join('|')}) /i)
      end

      def self.contains_command?(sms)
        possible_commands(sms).any?
      end

      def self.send_invalid_format(sms, cmd)
        App::Sender.send(
          "Command is not in the proper format. It should look like #{cmd::FORMAT}",
          sms.from.to_s
        )
      end

    end
  end
end
