class Attendance < ApplicationRecord
  enum :status, {
  not_clocked: 0,
  working: 1,
  normal: 2,
  abnormal: 3,
  absent: 4,
  paid_leave: 5,
  holiday: 6,
  corrected: 20
}

  belongs_to :employee
  has_one :attendance_edit_request, dependent: :destroy

  def stamp_start(time: Time.current)
    if original_started_at.present?
      errors.add(:base, :already_stamped)
      return false
    elsif status != "not_clocked"
      errors.add(:base, :invalid_stamped)
      return false
    end
    update(started_at: time, original_started_at: time, status: "working")
  end

  def stamp_finish(time: Time.current)
    if original_finished_at.present?
      errors.add(:base, :already_stamped)
      return false
    elsif original_break_started_at.present? && original_break_finished_at.blank?
      errors.add(:base, :break_not_finished)
      return false
    elsif status != "working"
      errors.add(:base, :invalid_stamped)
      return false
    end
    update(finished_at: time, original_finished_at: time, status: "normal")
  end

  def stamp_break_start(time: Time.current)
    if original_break_started_at.present?
      errors.add(:base, :already_stamped)
      return false
    elsif status != "working"
      errors.add(:base, :invalid_stamped)
      return false
    end
    update(break_started_at: time, original_break_started_at: time)
  end

  def stamp_break_finish(time: Time.current)
    if original_break_finished_at.present?
      errors.add(:base, :already_stamped)
      return false
    elsif original_break_started_at.blank?
      errors.add(:base, :break_not_started)
      return false
    elsif status != "working"
      errors.add(:base, :invalid_stamped)
      return false
    end
    update(break_finished_at: time, original_break_finished_at: time)
  end

  def cancel_stamp_within_5_minutes
    unless working? || normal? || abnormal?
      return false
    end
    attrs = {}
    if finished_at.presence && finished_at >= 5.minutes.ago
      attrs[:finished_at] = nil
      attrs[:original_finished_at] = nil
      attrs[:status] = "working"
    end
    if started_at.presence && started_at >= 5.minutes.ago
      attrs[:started_at] = nil
      attrs[:original_started_at] = nil
      attrs[:status] = "not_clocked"
    end
    if break_started_at.presence && break_started_at >= 5.minutes.ago
      attrs[:break_started_at] = nil
      attrs[:original_break_started_at] = nil
    end
    if break_finished_at.presence && break_finished_at >= 5.minutes.ago
      attrs[:break_finished_at] = nil
      attrs[:original_break_finished_at] = nil
    end
    update(attrs)
  end
end
