module WorkDateExceptionRequests
  class CreateExceptions
    def initialize(exception_request:)
      @exception_request = exception_request
    end

    def call
      @employee = @exception_request.employee

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
