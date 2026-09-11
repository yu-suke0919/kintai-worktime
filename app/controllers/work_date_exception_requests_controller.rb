class WorkDateExceptionRequestsController < ApplicationController
  before_action :authenticate_employee!
  before_action :ensure_owner!
  before_action :set_employee, only: [ :new, :edit, :create, :update ]
  def new
    @exception_request = WorkDateExceptionRequest.new()
  end

  def edit
    @exception_request = WorkDateExceptionRequest.find(params[:id])
  end
  def create
    params = request_params
    params[:start_date] = params[:starts_at]
    params[:end_date] = params[:ends_at]
    @exception_request = @employee.work_date_exception_requests.build(params)
    WorkDateExceptionRequests::CreateExceptions.new(
      exception_request: @exception_request
    ).call
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn(
      "#{e.record.class.name}: #{e.record.errors.full_messages.join('、')}"
    )

    render :new, status: :unprocessable_entity
  else
    redirect_to notifications_path, notice: "振替/休暇申請を完了しました。"
  end

  def update
    @exception_request = WorkDateExceptionRequest.find(params[:id])
    if @exception_request.update(request_params)
      @exception_request.notifications.create!(

        notification_type: :pending,
        recipient_employee: @employee,
        message_text: "振替/休暇申請の修正が完了しました。"
      )
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ensure_owner!
    redirect_to employee_attendances_path(current_employee), alert: "自分以外の振替/休暇申請はできません。" if params[:employee_id].to_i != current_employee.id
  end

  def set_employee
    @employee = current_employee
  end

  def request_params
    params.require(:work_date_exception_request).permit(:request_type, :start_date, :end_date, :starts_at, :ends_at, :reason)
  end
end
