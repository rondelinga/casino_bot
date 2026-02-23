module Telegram
  module Commands
    class BaseCommand
      ROLE_LABELS = {
        'user'    => '👤 Игрок',
        'creator' => '🎨 Креатор',
        'admin'   => '👑 Админ'
      }.freeze

      def initialize(message, user, responder)
        @message   = message
        @user      = user
        @responder = responder
      end

      private

      def no_access
        @responder.send("⛔ Нет доступа.")
      end

      def role_label(user)
        ROLE_LABELS[user.role]
      end
    end
  end
end