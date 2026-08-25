class MonthlyAttendanceClosingsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee
  before_action :owner_or_admin_required
  def index
    permitted = params.permit(:selected_year)
    match = permitted[:selected_year]&.match(/\A(\d{4})\z/)
    if match
      @selected_year = match[0].to_i
    else
      @selected_year = Date.today.year
    end
    range = Date.new(@selected_year, 1, 1).all_year
    @monthly_attendance_closings = @employee.monthly_attendance_closings.where(target_month: range).index_by { |closing|closing.target_month.month }
  end

  def new
    permitted = params.permit(:target_month)
    year, month = permitted[:target_month]&.split("-").map(&:to_i)
    selected_month = Date.new(year, month, 1)
    @monthly_attendance_closing = @employee.monthly_attendance_closings.new(target_month: selected_month)
    @summaries = DailyWorkSummariesPresenter.new(@employee, selected_month).daily_work_summaries
  end

  def create
    unless @employee.manager.persisted?
      redirect_to employee_attendances_path(@employee), alert: "マネージャーが割り当てられていないか、無効なマネージャーです。現在の上司に確認してください。"
    end
    params = closing_params
    target_month = Date.strptime(params[:target_month], "%Y-%m").beginning_of_month
    @employee.transaction do
      closing = @employee.monthly_attendance_closings.create!(target_month: target_month)
      closing.monthly_attendance_closing_approvals.create!(approver_id: @employee.manager.id, status: :pending, approval_order: 1)
    end

    redirect_to redirect_to employee_attendances_path(@employee), notice: "成功しました。"
  end

  def show
  end

  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
  def closing_params
    params.require(:monthly_attendance_closing).permit(:target_month)
  end

  def owner_or_admin_required
    redirect_to employee_attendances_path(current_employee), alert: "エラーが発生しました" if current_employee.id != params[:employee_id].to_i && current_employee.role == "member"
  end
end
