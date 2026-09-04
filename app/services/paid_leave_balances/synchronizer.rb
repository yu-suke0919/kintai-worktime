module PaidLeaveBalances
  class Synchronizer
    def self.for_new_paid_leave_grant!(grant)
      grant.employee.employee_rules
        .where(effective_from: ..grant.expires_on)
        .where(expires_on: grant.granted_on..)
        .each do |rule|
          synchronize!(grant, rule)
        end
    end

    def self.for_new_employee_rule!(rule)
      rule.employee.paid_leave_grants
        .where(granted_on: ..rule.expires_on)
        .where(expires_on: rule.effective_from..)
        .each do |grant|
          synchronize!(grant, rule)
        end
    end

    def self.synchronize!(grant, rule)
      effective_from = [ grant.granted_on, rule.effective_from ].max
      PaidLeaveBalance.find_or_create_by!(paid_leave_grant: grant, employee_rule: rule, effective_from: effective_from)
    end
  end
end
