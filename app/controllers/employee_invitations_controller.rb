class EmployeeInvitationsController < ApplicationController
  before_action :set_employee
  def edit
  end

  def update
  end

  def expired
  end

  def set_employee
    @employee = Employee.find_by_token_for(:invitational, params[:token])
    logger.debug { "招待リンク確認結果: employee_id=#{@employee&.id || 'not_found'}" }
    logger.debug { "#{params[:token]}" }
    if @employee.nil?
      render :expired, status: :gone
    end
  end
end
