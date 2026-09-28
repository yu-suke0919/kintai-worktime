module PaidLeaves
  class TransactionRebuilder
    def initialize(employee:, work_date:)
      @employee = employee
      @date = work_date
      @grants = @employee.paid_leave_grants
        .where(granted_on: ..@date)
        .where(expires_on: @date..)
        .order(:expires_on, :id)
    end

    def execute
      raise "有給休暇が付与されていません" if @grants.empty?
      affected_exceptions = []
      @employee.work_date_exceptions.where(work_date: @date..).order(work_date: :asc).each do |affected_exception|
        affected_exceptions.push(affected_exception)
        affected_exception.paid_leave_transactions.destroy_all
      end
      affected_exceptions.each do |exception|
        case exception.exception_type
        when "paid_leave"
            create_transactions!(1, 0, exception)

        when "hourly_paid_leave"

            hour_leaves_length = (exception.ends_at - exception.starts_at) / 3600
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
        raise "不正な残高です" if remaining[:days] < 0 || remaining[:hours] < 0
        next if remaining[:days] == 0 && remaining[:hours] == 0
        balance = grant.balances.where(effective_from: ..exception.work_date).order(:effective_from).last
        raise "取得する日に就業ルールが存在せず有給が取得できません。" if balance.nil?

        if remaining[:days] > use_days
          tr = create_transaction!(balance, use_days, use_hours, exception)
        elsif remaining[:days] == use_days
          if remaining[:hours] >= use_hours
            tr = create_transaction!(balance, use_days, use_hours, exception)
          else
            tr = create_transaction!(balance, remaining[:days], remaining[:hours], exception)
          end
        else
          tr = create_transaction!(balance, remaining[:days], remaining[:hours], exception)
        end

        use_days -= tr.delta_days
        use_hours -= tr.delta_minutes / 60

        if use_hours < 0
          use_days -= 1
          use_hours += (balance.employee_rule.scheduled_work_minutes/60).ceil
        end
        break if use_days == 0 && use_hours == 0
      end

      raise "残高が足りません" if use_days > 0 || use_hours > 0
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
