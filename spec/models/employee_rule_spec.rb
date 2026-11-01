require 'rails_helper'

RSpec.describe EmployeeRule, type: :model do
  let(:employee) { FactoryBot.create(:employee) }
  describe "in_office_days_hash" do
    context "出勤日が月~金の場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee) }
      it "monday~fridayがtrue,sunday,saturdayがfalseのhashが返される" do
        hash = { sunday: false, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false }
        expect(rule.in_office_days_hash).to eq(hash)
      end
    end
    context "毎日出勤日の場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee, required_workdays_mask: 127) }
      it "monday~fridayがtrue,sunday,saturdayがfalseのhashが返される" do
        hash = { sunday: true, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: true }
        expect(rule.in_office_days_hash).to eq(hash)
      end
    end
    context "出勤日がない場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee, required_workdays_mask: 0) }
      it "monday~fridayがtrue,sunday,saturdayがfalseのhashが返される" do
        hash = { sunday: false, monday: false, tuesday: false, wednesday: false, thursday: false, friday: false, saturday: false }
        expect(rule.in_office_days_hash).to eq(hash)
      end
    end
  end

  describe "in_office_days_text" do
    context "出勤日が月~金の場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee) }
      it "「月,火,水,木,金」のtextが返される" do
        text = "月,火,水,木,金"
        expect(rule.in_office_days_text).to eq(text)
      end
    end
    context "毎日出勤日の場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee, required_workdays_mask: 127) }
      it "「日,月,火,水,木,金,土」のtextが返される" do
        text = "日,月,火,水,木,金,土"
        expect(rule.in_office_days_text).to eq(text)
      end
    end
    context "出勤曜日がない場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee, required_workdays_mask: 0) }
      it "「」のtextが返される" do
        text = ""
        expect(rule.in_office_days_text).to eq(text)
      end
    end
  end

  describe "workday?" do
    let(:sunday) { Date.new(2026, 4, 5) }
    let(:monday_to_friday) { (Date.new(2026, 4, 6)..Date.new(2026, 4, 10)) }
    let(:saturday) { Date.new(2026, 4, 11) }
    context "mondayからfridayが勤務日の場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee) }

      it "workday?は月~金はtrueとなり、日,土はfalseとなる" do
        expect(rule.workday?(sunday)).to be false
        expect(monday_to_friday.all? { |date|rule.workday?(date) }).to be true
        expect(rule.workday?(saturday)).to be false
      end
    end
    context "毎日勤務日の場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee, required_workdays_mask: 127) }
      it "workday?は日曜から土曜までtrueとなる" do
        expect(rule.workday?(sunday)).to be true
        expect(monday_to_friday.all? { |date|rule.workday?(date) }).to be true
        expect(rule.workday?(saturday)).to be true
      end
    end
    context "勤務日がない場合" do
      let(:rule) { FactoryBot.create(:employee_rule, employee: employee, required_workdays_mask: 0) }

      it "workday?は日曜から土曜までfalseとなる" do
        expect(rule.workday?(sunday)).to be false
        expect(monday_to_friday.all? { |date|rule.workday?(date) }).to be false
        expect(rule.workday?(saturday)).to be false
      end
    end
  end
end
