require 'rails_helper'

RSpec.describe Employee, type: :model do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_2_manager) { FactoryBot.create(:employee, email: "test2@gmail.com", role: 1) }
  let(:user_3_admin) { FactoryBot.create(:employee, email: "test3@gmail.com", role: 2) }
  let(:user_99_super_super_admin) { FactoryBot.create(:employee, email: "test@99gmail.com", role: 99) }

  it "manager(Employee)に所属しているかどうか" do
    is_expected.to belong_to(:manager).class_name("Employee").optional
  end

  it "部下(subordinates)をmanager_id(自身のid)で複数持ち、削除時は各部下のmanager_idをNULLにすること" do
    is_expected.to have_many(:subordinates).class_name("Employee").with_foreign_key("manager_id").dependent(:nullify)
  end

  it "勤怠情報Attendanceを複数もち、" do
    is_expected.to have_many(:attendances)
  end



  it 'enumで定義していないroleを持つユーザーを弾くかどうか' do
    expect(user_1).to be_valid
    expect(user_2_manager).to be_valid
    expect(user_3_admin).to be_valid
    expect { user_99_super_super_admin }.to raise_error(ArgumentError, "'99' is not a valid role")
  end
  it 'has_request_attendancesでrequestを持つattendanceを取得できるか' do
    user_1.attendances.create(worked_on: '2026-05-01')
    user_1.attendances.create(worked_on: '2026-05-02')
    user_1.attendances.create(worked_on: '2026-05-03')
    user_1.attendances.find_by(worked_on: '2026-05-02').create_attendance_edit_request(employee_id: user_1.id)
    user_1.attendances.find_by(worked_on: '2026-05-03').create_attendance_edit_request(employee_id: user_1.id)
    expect(user_1.has_request_attendances.count).to eq 2
  end
end




# require 'rails_helper'

# RSpec.describe Article, type: :model do
#   let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'emailA') }
#   let(:article1) { FactoryBot.create(:article, user: user_a, title: 'title1') }
#   let(:article1_dup) { FactoryBot.build(:article, user: user_a, title: 'title1') }
#   let(:article2) { FactoryBot.build(:article, user: user_a, title: 'title2') }
#   describe 'title' do
#     it 'タイトルが重複していなければ、どちらもsave可能' do
#       expect(article1).to be_valid
#       expect(article2.save).to eq true
#     end

#     it 'タイトルが重複している場合、後者はセーブ不可' do
#       expect(article1).to be_valid
#       expect(article1_dup.save).to eq false
#     end
#   end
# end
