class NotificationsController < ApplicationController
  before_action :authenticate_employee!
  def index
    @notifications = current_employee.notifications.includes(:notifiable)
  end

  def show
    @notification = current_employee.notifications.find(params[:id])
  end
end
