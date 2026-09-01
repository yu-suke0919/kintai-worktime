import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minutes","days"]

  static values = {
    minutesPerDay:{
      type: Number,
      default: 480
    }
  }

  connect(){
    this.convertMinutes()
  }

  convertMinutes(){
    const minutes = Number.parseInt(this.minutesTarget.value,10)
    if ( !Number.isInteger(minutes) || (minutes < 0)){
      this.daysTarget.value = "0日0時間"
      return
    }
    const days = Math.floor(minutes / this.minutesPerDayValue)
    const remain = minutes % this.minutesPerDayValue
    const hours = Math.floor(remain / 60)

    this.daysTarget.value = `${days}日${hours}時間`

  }
}