require 'rails_helper'

RSpec.describe "AttendanceEditRequests", type: :request do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_2) { FactoryBot.create(:employee, email: "user2@email",) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@email", role: :manager) }

  shared_examples "redirect_to_login_page" do
    it "ログインページにリダイレクトされ、alertが設定されること" do
      request_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_employee_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  shared_examples "redirect_to_current_employee_attendance_index_page" do
    it "ログイン中の従業員勤怠画面にリダイレクトされ、alertが設定されること" do
      request_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(employee_attendances_path(logged_in_employee))
      expect(flash[:alert]).to be_present
    end
  end

  shared_examples "have_http_status_success" do
    it "HTTPリクエストステータスが、成功となること" do
      request_action
      expect(response).to have_http_status(:success)
    end
  end

  shared_examples "redirect_with_found_status" do
    it "redirect_toによって所定のページにリダイレクトされること" do
      request_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(redirect_path)
    end
  end

  context "非ログイン時" do
    let(:user_1_attendance) { FactoryBot.create(:attendance, :eight_hour_shift, :properly_clocked, employee: user_1) }
    let(:user_2_attendance) { FactoryBot.create(:attendance, :eight_hour_shift, :properly_clocked, employee: user_2) }

    describe "GET /index" do
      let(:request_action) { get new_employee_attendance_attendance_edit_request_path(user_1, '2026-05-01') }
      it_behaves_like "redirect_to_login_page"
    end
  end

  describe "ユーザー1がログイン時" do
    let!(:user_1_attendance) { FactoryBot.create(:attendance, :eight_hour_shift, :properly_clocked, employee: user_1) }
    let!(:user_2_attendance) { FactoryBot.create(:attendance, :eight_hour_shift, :properly_clocked, employee: user_2) }

    before do
      sign_in user_1
    end
    context "GET user_1/attendance_edit_request/index" do
      let(:request_action) { get employee_attendance_edit_requests_path(user_1) }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "have_http_status_success"
    end
    context "GET user_1/attendances/2026-05-01/attendance_edit_request/new" do
      let(:request_action) { get new_employee_attendance_attendance_edit_request_path(user_1, '2026-05-01') }
      let(:logged_in_employee) { user_1 }
      context " 未打刻のAttendanceに対して修正する場合" do
      end
      it_behaves_like "have_http_status_success"
    end
    context "POST user_1/attendances/2026-05-01/attendance_edit_requests" do
      let(:worked_on) { '2026-05-01' }
      let(:request_action) { post employee_attendance_attendance_edit_request_path(user_1, worked_on), params: { attendance_edit_request: request_params } }
      let(:logged_in_employee) { user_1 }
      let(:request_params) { FactoryBot.attributes_for(:attendance_edit_request) }
      let(:redirect_path) { employee_attendances_path(user_1) }

      it "attendance_edit_requestが反映されるか" do
        expect(user_1_attendance.attendance_edit_request).to be_nil
        request_action
        expect(user_1_attendance.reload.attendance_edit_request.requested_started_at).to eq(DateTime.new(2026, 5, 1, 8, 50, 00))
      end

      it_behaves_like "redirect_with_found_status"
    end

    context "GET user_1/attendances/2026-05-01/attendance_edit_request/edit" do
      let(:request_action) { get edit_employee_attendance_attendance_edit_request_path(user_1, '2026-05-01') }
      let(:logged_in_employee) { user_1 }
      before do
        attendance = Attendance.find_by(employee: user_1, worked_on: "2026-05-01")
        FactoryBot.create(:attendance_edit_request, attendance: attendance, employee: user_1,)
      end

      it_behaves_like "have_http_status_success"
    end
    context "PATCH user_1/attendances/2026-05-01/attendance_edit_requests" do
      let(:worked_on) { '2026-05-01' }
      let!(:before_request) { FactoryBot.create(:attendance_edit_request, employee: user_1, attendance: user_1_attendance) }
      let(:request_action) { patch employee_attendance_attendance_edit_request_path(user_1, worked_on), params: { attendance_edit_request: request_params } }
      let(:logged_in_employee) { user_1 }
      let(:request_params) { FactoryBot.attributes_for(:attendance_edit_request, requested_started_at: (DateTime.new(2026, 5, 1, 8, 20, 00))) }
      let(:redirect_path) { employee_attendances_path(user_1) }

      it "attendance更新が反映されるか" do
        expect(user_1_attendance.reload.attendance_edit_request.requested_started_at).to eq(DateTime.new(2026, 5, 1, 8, 50, 00))
        request_action
        expect(user_1_attendance.reload.attendance_edit_request.requested_started_at).to eq(DateTime.new(2026, 5, 1, 8, 20, 00))
      end

      it_behaves_like "redirect_with_found_status"
    end
  end


  context "ユーザー1がログイン時にユーザー2のページにアクセスする時" do
    before do
      sign_in user_1
    end

    describe "GET user_2/attendance_edit_request/index" do
      let(:request_action) { get employee_attendance_edit_requests_path(user_2) }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
    describe "GET user_2/attendances/2026-05-01/attendance_edit_request/new" do
      let(:request_action) { get new_employee_attendance_attendance_edit_request_path(user_2, '2026-05-01') }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
  end

  context "マネージャーがログイン時" do
    before do
      sign_in user_manager
    end
    describe "GET user_1/attendance_edit_request/index" do
      let(:request_action) { get employee_attendance_edit_requests_path(user_1) }
      let(:logged_in_employee) { user_manager }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
    describe "GET user_1/attendances/2026-05-01/attendance_edit_request/new" do
      let(:request_action) { get new_employee_attendance_attendance_edit_request_path(user_1, '2026-05-01') }
      let(:logged_in_employee) { user_manager }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
  end
end
