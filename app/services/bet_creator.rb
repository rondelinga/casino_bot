class BetCreator
  def initialize(user, title:, outcomes:)
    @user = user
    @title = title
    @outcomes = outcomes
  end

  def create!
    bet = Bet.create!(title: @title, created_by: @user, status: :open)
    @outcomes.each_with_index do |title, i|
      bet.bet_outcomes.create!(title: title, position: i + 1)
    end
    bet
  end
end
