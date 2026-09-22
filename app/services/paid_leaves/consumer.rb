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

    def consume(new_exception:)
      raise "有給休暇がありません" if @grants.empty?
      affected_exceptions = []
      @employee.work_date_exceptions.where(work_date: new_exception.work_date..).order(work_date: :asc).each do |affected_exception|
        affected_exceptions.push(affected_exception)
        affected_exception.paid_leave_transactions.destroy_all
      end
      affected_exceptions.each do |exception|
        case exception.exception_type
        when "paid_leave"
            raise "有給残高が足りません" if @remain_balance_days < 1
            create_transactions!(1, 0, exception)

        when "hourly_paid_leave"
            hour_leaves_length = (exception.ends_at - exception.starts_at) / 3600
            raise "有給残高が足りません" if @remain_balance_days < 1 && @remain_balance_hours < hour_leaves_length
            create_transactions!(0, hour_leaves_length, exception)
        else
            raise "不正な呼び出し"
        end
      end
    end


    private

    def create_transactions!(use_days, use_hours, exception)
      @grants.each do |grant|
        remaining = grant.remaining_leaves
        balance = grant.balances.where(effective_from: ..exception.work_date).order(:effective_from).last
        raise "対象となる有給残高がありません" if balance.nil?
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
