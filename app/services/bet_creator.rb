class BetCreator
  def initialize(user, title:, outcomes:, odds: nil)
    @user     = user
    @title    = title
    @outcomes = outcomes
    @odds     = odds
  end

  def create!
    ActiveRecord::Base.transaction do
      predict = Bet.create!(title: @title, created_by: @user)
      @outcomes.each_with_index do |title, i|
        predict.bet_outcomes.create!(
          title:    title,
          position: i + 1,
          odds:     @odds&.dig(i)
        )
      end
      predict
    end
  end
end
