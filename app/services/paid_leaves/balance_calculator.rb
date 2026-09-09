module PaidLeaves
  class BalanceCalculator
    def initialize(grant:)
      @grant = grant
    end

    def remaining_leaves
      remaining_leaves = { days: @grant.granted_minutes/360 }
      @grant.balances.order(:effective_from).each do |balance|
        balance.transactions.order(:effective_on).each do |transaction|
          remaining_leaves[:days] -= transaction.delta_days
        end
      end
      remaining_leaves
    end
  end
end
