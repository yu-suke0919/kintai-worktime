module PaidLeaves
  class Consumer
    def initialize(employee:)
      @employee = employee
      date = Date.current
      @grants = @employee.paid_leave_grants
        .where(granted_on: ..date)
        .where(expires_on: date..)
        .order(:expires_on, :id)
    end

    def consume(exception:)
      use_days = 1
      @grants.each do |grant|
        obtainable = calculate_remain_paid_leave(grant)
        if obtainable > use_days
          balance = grant.balances.find_by(effective_from)
          balance
            .transactions
            .create!(delta_days: use_days,
                    delta_minutes: 0,
                    effective_on: exception.work_date,
                    paid_leave_balance: balance,
                    reason: "有給休暇のため",
                    transaction_type: 1,
                    exception: exception
                    )
          break
        end
      end
    end

    private

    def calculate_transaction
    end

    def calculate_remain_paid_leave(grant)
      grant.balances.sum do |balance|
        balance.transactions.sum do |transaction|
          transaction.delta_days
        end
      end
    end
  end
end
