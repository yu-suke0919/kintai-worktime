module PaidLeaves
  class BalanceCalculator
    def initialize(grant:)
      @grant = grant
    end

    def remaining_leaves
      remaining_leaves = { days: @grant.granted_minutes/360, hours: 0 }
      @grant.balances.order(:effective_from).each do |balance|
        balance.transactions.order(:effective_on).each do |transaction|
          remaining_leaves[:days] -= transaction.delta_days
          remaining_leaves[:hours] -= transaction.delta_minutes / 60
          if remaining_leaves[:hours] < 0
            remaining_leaves[:days] -= 1
            remaining_leaves[:hours] += balance.employee_rule.scheduled_work_minutes / 60
          end
        end
      end
      Rails.logger.debug(remaining_leaves)
      remaining_leaves
    end
  end
end
