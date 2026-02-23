class CommandRouter
    def initialize(message)
      @message = message
      @responder = BotResponder.new(message.chat.id)
      @user = User.find_or_create_by_telegram(message.from.id).tap do |u|
        u.update(username: message.from.username)
      end
    end

    def dispatch
      case @message.text
      when '/start'             then Commands::StartCommand.new(@message, @user, @responder).call
      when '/balance'           then Commands::BalanceCommand.new(@message, @user, @responder).call
      when '/spin'              then Commands::SpinCommand.new(@message, @user, @responder).call
      when '/bets'              then Commands::BetsCommand.new(@message, @user, @responder).call
      when '/users'             then Commands::UsersCommand.new(@message, @user, @responder).call
      when /^\/bet (\d+) (\d+) (\d+)$/
        Commands::PlaceBetCommand.new(@message, @user, @responder, $1, $2, $3).call
      when /^\/create_bet (.+)$/
        Commands::CreateBetCommand.new(@message, @user, @responder, $1).call
      when /^\/close_bet (\d+)$/
        Commands::CloseBetCommand.new(@message, @user, @responder, $1).call
      when /^\/resolve_bet (\d+) (\d+)$/
        Commands::ResolveBetCommand.new(@message, @user, @responder, $1, $2).call
      when /^\/cancel_bet (\d+)$/
        Commands::CancelBetCommand.new(@message, @user, @responder, $1).call
      when /^\/set_role (\d+) (user|creator|admin)$/
        Commands::SetRoleCommand.new(@message, @user, @responder, $1, $2).call
      end
    end
end

