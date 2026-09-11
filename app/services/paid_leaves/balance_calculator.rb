module PaidLeaves
  class BalanceCalculator
    def initialize(grant:)
      @grant = grant
    end

    def remaining_leaves
      remaining_leaves = { days: @grant.granted_minutes/480, hours: 0 }
      before_work_hours = 0
      @grant.balances.order(:effective_from).each do |balance|
        current_work_hours = (balance.employee_rule.scheduled_work_minutes / 60).ceil
        if before_work_hours > 0
          remaining_leaves[:hours] = (1.0*remaining_leaves[:hours] / before_work_hours * current_work_hours).ceil
          if remaining_leaves[:hours] >= current_work_hours
            remaining_leaves[:days] += 1
            remaining_leaves[:hours] -= current_work_hours
          end
        end
        before_work_hours = current_work_hours
        balance.transactions.order(:effective_on).each do |transaction|
          remaining_leaves[:days] -= transaction.delta_days
          remaining_leaves[:hours] -= transaction.delta_minutes / 60
          if remaining_leaves[:hours] < 0
            remaining_leaves[:days] -= 1
            remaining_leaves[:hours] += current_work_hours
          end
        end
      end
      remaining_leaves
    end
    BalanceHistoryItem = Data.define(
      :date,
      :history_type,
      :work_hours,
      :delta_days,
      :delta_hours,
      :remaining_days,
      :remaining_hours,
      :reason
    )
    def balance_history
      history = []
      remaining_leaves = { days: @grant.granted_minutes/480, hours: 0 }
      before_work_hours = 0
      @grant.balances.order(:effective_from).each do |balance|
        current_work_hours = (balance.employee_rule.scheduled_work_minutes / 60).ceil
        history.push(
          BalanceHistoryItem.new(
            date: balance.effective_from,
            history_type: :new_employee_rule,
            delta_days: 0,
            delta_hours: 0,
            work_hours: current_work_hours,
            remaining_days: remaining_leaves[:days],
            remaining_hours: remaining_leaves[:hours],
            reason: "ルール変更or既存ルール継続"
          )
        )
        if before_work_hours > 0
          remaining_leaves[:hours] = (1.0*remaining_leaves[:hours] / before_work_hours * current_work_hours).ceil
          if remaining_leaves[:hours] >= current_work_hours
            remaining_leaves[:days] += 1
            remaining_leaves[:hours] -= current_work_hours
          end
          history.push(
            BalanceHistoryItem.new(
              date: balance.effective_from,
              history_type: :round_up,
              delta_days: 0,
              delta_hours: 0,
              work_hours: current_work_hours,
              remaining_days: remaining_leaves[:days],
              remaining_hours: remaining_leaves[:hours],
              reason: "単位時間変更による残時間変換"
            )
          )
        end
        before_work_hours = current_work_hours


        balance.transactions.order(:effective_on).each do |transaction|
          remaining_leaves[:days] -= transaction.delta_days
          remaining_leaves[:hours] -= transaction.delta_minutes / 60
          if remaining_leaves[:hours] < 0
            remaining_leaves[:days] -= 1
            remaining_leaves[:hours] += current_work_hours
          end
          history.push(
            BalanceHistoryItem.new(
              date: transaction.effective_on,
              history_type: :uses,
              delta_days: transaction.delta_days,
              delta_hours: transaction.delta_minutes/ 60,
              work_hours: current_work_hours,
              remaining_days: remaining_leaves[:days],
              remaining_hours: remaining_leaves[:hours],
              reason: "使用"
            )
          )
        end
      end
    history
    end
  end
end
