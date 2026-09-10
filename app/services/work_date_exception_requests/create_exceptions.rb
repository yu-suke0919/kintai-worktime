module WorkDateExceptionRequests
  class CreateExceptions
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
          PaidLeaves::Consumer.new(employee: @employee).consume(exception: exception)
          @exception_request.notifications.create!(
            notification_type: :pending,
            recipient_employee: @employee,
            message_text: "時間有給申請が完了しました。\n#{exception.starts_at.strftime("%y-%m-%d %H:%M")}~#{exception.ends_at.strftime("%y-%m-%d%H:%M")}"
          )
        end
      else
        if @exception_request.request_type == "paid_leave"
          consumer = PaidLeaves::Consumer.new(employee: @employee)
        end
        ApplicationRecord.transaction do
          @exception_request.save!
          (@exception_request.start_date..@exception_request.end_date).each do |date|
            exception = @exception_request.work_date_exceptions.create!(
              usage_status: :pending,
              employee: @employee,
              work_date: date,
              exception_type: @exception_request.request_type
            )
            consumer.consume(exception: exception) if @exception_request.request_type == "paid_leave"
          end
          @exception_request.notifications.create!(
            notification_type: :pending,
            recipient_employee: @employee,
            message_text: "振替/休暇申請が完了しました。"
          )
        end
      end
    end
  end
end
