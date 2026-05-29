class NotificationsController < ApplicationController
  def index
    @notifications = current_employee.notifications
  end

  def show
    @notification = current_employee.notifications.find(params[:id])
  end
end
