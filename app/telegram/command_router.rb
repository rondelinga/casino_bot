class CommandRouter
  def initialize(message: nil, callback_query: nil)
    if callback_query
      @callback_query = callback_query
      @responder      = BotResponder.new(callback_query.message.chat.id)
      @user           = User.find_or_create_by_telegram(callback_query.from.id).tap do |u|
        u.update(username: callback_query.from.username)
      end
    else
      @message   = message
      @responder = BotResponder.new(message.chat.id, reply_to: message.message_id)
      @user      = User.find_or_create_by_telegram(message.from.id).tap do |u|
        u.update(username: message.from.username)
      end
    end
  end

  def dispatch
    if @callback_query
      dispatch_callback
    else
      dispatch_message
    end
  end

  private

  def dispatch_message
    text = @message.text.split('@').first

    case text
    when '/start'   then Commands::StartCommand.new(@message, @user, @responder).call
    when '/balance' then Commands::BalanceCommand.new(@message, @user, @responder).call
    when '/spin'    then Commands::SpinCommand.new(@message, @user, @responder).call
    when '/predict'    then Commands::BetsCommand.new(@message, @user, @responder).call
    when '/users'   then Commands::UsersCommand.new(@message, @user, @responder).call
    when /^\/predict (\d+) (\d+) (\d+)$/
      Commands::PlaceBetCommand.new(@message, @user, @responder, $1, $2, $3).call
    when /^\/create_predict (.+)$/
      Commands::CreateBetCommand.new(@message, @user, @responder, $1).call
    when /^\/close_predict (\d+)$/
      Commands::CloseBetCommand.new(@message, @user, @responder, $1).call
    when /^\/resolve_predict (\d+) (\d+)$/
      Commands::ResolveBetCommand.new(@message, @user, @responder, $1, $2).call
    when /^\/cancel_predict (\d+)$/
      Commands::CancelBetCommand.new(@message, @user, @responder, $1).call
    when /^\/set_role (\d+) (user|creator|admin)$/
      Commands::SetRoleCommand.new(@message, @user, @responder, $1, $2).call
    end
  end

  def dispatch_callback
    case @callback_query.data
    when /^predict:(\d+):(\d+)$/
      Commands::SelectBetOutcomeCommand.new(@callback_query, @user, @responder, $1, $2).call
    when /^place:(\d+):(\d+):(\d+)$/
      Commands::PlaceBetCallbackCommand.new(@callback_query, @user, @responder, $1, $2, $3).call
    end
  end
end
