module Commands
    class SetRoleCommand < BaseCommand
      def initialize(message, user, responder, telegram_id, role)
        super(message, user, responder)
        @telegram_id = telegram_id.to_i
        @role        = role
      end

      def call
        return no_access unless @user.admin?

        target = User.find_by(telegram_id: @telegram_id)
        return @responder.send("❌ Пользователь не найден") unless target

        target.update!(role: @role)
        @responder.send("✅ #{target.display_name} теперь #{role_label(target)}")
      end
    end
end
