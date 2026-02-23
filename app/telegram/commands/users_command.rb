  module Commands
    class UsersCommand < BaseCommand
      def call
        return no_access unless @user.admin?

        list = User.all.map do |u|
          "#{u.display_name} — #{role_label(u)} — #{u.balance} токенов"
        end.join("\n")

        @responder.send("👥 Пользователи:\n\n#{list}")
      end
    end
  end

