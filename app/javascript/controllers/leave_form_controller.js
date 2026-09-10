import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["requestType","dateField","startsDatetimeField","endsDatetimeField"]
  connect(){
    this.toggleDateAndDateTime()
  }

  toggleDateAndDateTime(){
    const dateFieldEnabled = this.requestTypeTarget.value === "hourly_paid_leave"
    this.dateFieldTargets.forEach((target) =>{
      target.disabled = dateFieldEnabled
    })
    
    this.startsDatetimeFieldTarget.disabled = !dateFieldEnabled
    this.endsDatetimeFieldTarget.disabled = !dateFieldEnabled
  }

  updateEndTime(){
    const minEndsTime = this.startsDatetimeFieldTarget.value

    this.endsDatetimeFieldTarget.value = minEndsTime
    this.endsDatetimeFieldTarget.min = minEndsTime
  }
}