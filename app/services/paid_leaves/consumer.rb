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
        obtainable = grant.remaining_leaves[:days]
        if obtainable > use_days
          balance = grant.balances.where(effective_from: ..exception.work_date).order(:effective_from).first
          balance
            .transactions
            .create!(delta_days: use_days,
                    delta_minutes: 0,
                    effective_on: exception.work_date,
                    paid_leave_balance: balance,
                    reason: "有給休暇のため",
                    transaction_type: 1,
                    work_date_exception: exception
                    )
          break
        end
      end
    end

    private

    def calculate_transaction
    end
  end
end
