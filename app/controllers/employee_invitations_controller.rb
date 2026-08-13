class EmployeeInvitationsController < ApplicationController
  before_action :set_employee
  def edit
  end

  def update
    params = password_params
    if @employee.reset_password(params[:password], params[:password_confirm])
      redirect_to new_employee_session_path, notice: "本登録が完了しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def expired
  end

  private

  def set_employee
    @employee = Employee.find_by_token_for(:invitational, params[:token])
    if @employee.nil?
      render :expired, status: :gone
    end
  end

  def password_params
    params.require(:employee).permit(:password, :password_confirm)
  end
end
