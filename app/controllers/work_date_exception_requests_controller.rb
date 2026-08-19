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
    @exception_request = @employee.work_date_exception_requests.build(request_params)
    if @exception_request.save
      @exception_request.notifications.create!(
        notification_type: :pending,
        recipient_employee: @employee,
        message_text: "振替/休暇申請が完了しました。"
      )
      redirect_to notifications_path, notice: "振替/休暇申請を完了しました。"
    else
      render :new, status: :unprocessable_entity
    end
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
    params.require(:work_date_exception_request).permit(:request_type, :start_date, :end_date, :reason)
  end
end
