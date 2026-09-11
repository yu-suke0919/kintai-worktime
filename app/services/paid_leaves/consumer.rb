module PaidLeaves
  class Consumer
    def initialize(employee:)
      @employee = employee
      date = Date.current
      @grants = @employee.paid_leave_grants
        .where(granted_on: ..date)
        .where(expires_on: date..)
        .order(:expires_on, :id)
      @remain_balance_days =
        @grants.sum { |grant| grant.remaining_leaves[:days] }

      @remain_balance_hours =
        @grants.sum { |grant| grant.remaining_leaves[:hours] }
    end

    def consume(exception:)
      return :no_grant if @grants.empty?
      case exception.exception_type
      when "paid_leave"
          return :insufficient_balance if @remain_balance_days < 1
          create_transactions!(1, 0, exception)

      when "hourly_paid_leave"
          hour_leaves_length = (exception.ends_at - exception.starts_at) / 3600
          return :insufficient_balance if @remain_balance_days < 1 && @remain_balance_hours < hour_leaves_length
          create_transactions!(0, hour_leaves_length, exception)
      else
          :error
      end
    end

    private

    def create_transactions!(use_days, use_hours, exception)
      @grants.each do |grant|
        remaining = grant.remaining_leaves
        balance = grant.balances.where(effective_from: ..exception.work_date).order(:effective_from).last
        if remaining[:days] >= 1
          create_transaction!(balance, use_days, use_hours, exception)
          break
        elsif remaining[:hours] >= 1
          if remaining[:hours] > use_hours
            create_transaction!(balance, use_days, use_hours, exception)
            break
          else
            create_transaction!(balance, use_days, use_hours - remaining, exception)
            use_hours -= remaining
          end
        end
      end
    end
    def create_transaction!(balance, use_days, use_hours, exception)
      balance
        .transactions
        .create!(delta_days: use_days,
                delta_minutes: use_hours * 60,
                effective_on: exception.work_date,
                paid_leave_balance: balance,
                reason: "有給休暇のため",
                transaction_type: 1,
                work_date_exception: exception
                )
    end
  end
end
