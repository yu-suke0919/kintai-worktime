import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output1","output2","output1Datetime","output2Datetime"]
  static values = {
    startedAt: String,
    finishedAt: String,
    breakStartedAt: String,
    breakFinishedAt: String
  }
  connect() {
    this.changeText()
  }

    changeText(event) {
      return
    var value = event?.target?.value || "notSelected"
    if (value === "work_time" || value === "notSelected") {
      this.output1Target.textContent = "出勤時間"
      this.output2Target.textContent = "退勤時間"
      this.output1DatetimeTarget.value = this.startedAtValue
      this.output2DatetimeTarget.value = this.finishedAtValue
    } else if (value=== "break_time") {
      this.output1Target.textContent = "休憩開始時間"
      this.output2Target.textContent = "休憩終了時間"
      this.output1DatetimeTarget.value = this.breakStartedAtValue
      this.output2DatetimeTarget.value = this.breakFinishedAtValue

    }

  }
}