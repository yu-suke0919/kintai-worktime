module WorkDateExceptionRequests
  class ExceptionCreator
    class CreationError < StandardError; end
    def initialize(exception_request:)
      @exception_request = exception_request
    end

    def call
      @employee = @exception_request.employee
      case @exception_request.request_type
      when "hourly_paid_leave"
        ApplicationRecord.transaction do
          @exception_request.save!
            exception = @exception_request.work_date_exceptions.create!(
              usage_status: :pending,
              employee: @employee,
              work_date: @exception_request.starts_at,
              starts_at: @exception_request.starts_at,
              ends_at: @exception_request.ends_at,
              exception_type: @exception_request.request_type
            )
          PaidLeaves::TransactionRebuilder.new(employee: @employee, work_date: @exception_request.starts_at).execute()
          @exception_request.notifications.create!(
            notification_type: :pending,
            recipient_employee: @employee,
            message_text: "時間有給申請が完了しました。\n#{exception.starts_at.strftime("%y-%m-%d %H:%M")}~#{exception.ends_at.strftime("%y-%m-%d%H:%M")}"
          )
        end
      else
        ApplicationRecord.transaction do
          @exception_request.save!
          (@exception_request.start_date..@exception_request.end_date).each do |date|
            @exception_request.work_date_exceptions.create!(
              usage_status: :pending,
              employee: @employee,
              work_date: date,
              exception_type: @exception_request.request_type
            )
          end
          if @exception_request.request_type == "paid_leave"
            PaidLeaves::TransactionRebuilder.new(employee: @employee, work_date: @exception_request.start_date).execute
          end
          @exception_request.notifications.create!(
            notification_type: :pending,
            recipient_employee: @employee,
            message_text: "振替/休暇申請が完了しました。"
          )
        end
      end
    rescue RuntimeError => e
      raise CreationError, e.message
    end
  end
end
