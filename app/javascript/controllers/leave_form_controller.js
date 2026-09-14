import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["requestType","leaveDateField","startsDatetimeField","endsDatetimeField","balanceDisplay","leaveDateFields","leaveHourFields"]
  connect(){
    this.toggleDateAndDateTime()
  }

  toggleDateAndDateTime(){
    const hourlyPaidLeaveSelected = this.requestTypeTarget.value === "hourly_paid_leave"
    const fullDayPaidLeaveSelected = this.requestTypeTarget.value === "paid_leave"
    const paidLeaveSelected = hourlyPaidLeaveSelected || fullDayPaidLeaveSelected

    //時間選択が必要なとき、時間選択欄を有効化する
    this.leaveDateFieldTargets.forEach((target) =>{
      target.disabled = hourlyPaidLeaveSelected
    })

    //日付選択が必要なとき、日付選択欄を有効にする
    this.startsDatetimeFieldTarget.disabled = !hourlyPaidLeaveSelected
    this.endsDatetimeFieldTarget.disabled = !hourlyPaidLeaveSelected

    //時間有給or1日有給が選択されていたら有給残高を表示
    this.balanceDisplayTarget.classList.toggle("d-none",!paidLeaveSelected)
    //日時選択系なら日時選択フォームを表示
    this.leaveDateFieldsTarget.classList.toggle("d-none",hourlyPaidLeaveSelected)
    //時間選択系なら日時選択フォームを表示
    this.leaveHourFieldsTarget.classList.toggle("d-none",!hourlyPaidLeaveSelected)


    

  }

  updateEndTime(){
    const minEndsTime = this.startsDatetimeFieldTarget.value

    this.endsDatetimeFieldTarget.value = minEndsTime
    this.endsDatetimeFieldTarget.min = minEndsTime
  }
}