import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="attendance-chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    labels: Array,
    //times: Array,
  }
  connect() {
    const attendanceByDate = Object.fromEntries(this.labelsValue.map(value => [value.date,value]))
    const data = {
      datasets: [
        {
          label: '勤務時間',
          data: this.labelsValue.flatMap(value =>{
            if(value.finished_minutes <= 1440){
              return ({x:value.date,y:[value.started_minutes,value.finished_minutes],original:attendanceByDate[value.date]})
            }else{
              let nextDate = new Date(value.date + "T00:00:00")
              nextDate.setDate(nextDate.getDate() + 1)
              let nextDateString = [
                nextDate.getFullYear(),
                String(nextDate.getMonth() + 1).padStart(2, "0"),
                String(nextDate.getDate()).padStart(2, "0")
              ].join("-")
              return [{x: value.date,y:[value.started_minutes,1440],original:attendanceByDate[value.date]},
                      {x:nextDateString,y:[0,value.finished_minutes-1440],original:attendanceByDate[value.date]}
            ]
            }
          }
          ),
          backgroundColor: "#3f4cff",
          grouped: false,
          order: 2,
        },
        {
          label: '休憩時間',
          data: this.labelsValue.flatMap(value =>{
            if(value.break_finished_minutes <= 1440){
              return ({x:value.date,y:[value.break_started_minutes,value.break_finished_minutes],original:attendanceByDate[value.date]})
            }else{
              let nextDate = new Date(value.date + "T00:00:00")
              nextDate.setDate(nextDate.getDate() + 1)
              let nextDateString = [
                nextDate.getFullYear(),
                String(nextDate.getMonth() + 1).padStart(2, "0"),
                String(nextDate.getDate()).padStart(2, "0")
              ].join("-")
              if(value.break_started_minutes > 1440){
                return {x:nextDateString,y:[value.break_started_minutes-1440,value.break_finished_minutes-1440],original:attendanceByDate[value.date]}
              }else{
                return [{x: value.date,y:[value.break_started_minutes,1440],original:attendanceByDate[value.date]},
                        {x:nextDateString,y:[0,value.break_finished_minutes-1440],original:attendanceByDate[value.date]}
                ]
              }

              
            }
          }
          ),
          backgroundColor: "#6ffaff",
          grouped: false,
          order: 1,
        },
      ]
    };
    const config = {
      type: 'bar',
      data: data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
            mode: 'nearest',
            intersect: true
        },
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: '今月の勤務実績'
          },
          tooltip:{
            displayColors: false,
            enabled: true,
            callbacks: {
              title: (items) => {
                return items[0].raw.original.date + "開始の勤怠"
              },
              label: (context) =>{
                const data = context.raw.original
                const startedTime = this.formatTime(data.started_minutes)
                const finishedTime = this.formatTime(data.finished_minutes)
                const breakStartedTime = this.formatTime(data.break_started_minutes)
                const breakFinishedTime = this.formatTime(data.break_finished_minutes)
                return [`勤務時間:${startedTime}~${finishedTime}`,
                        `休憩時間:${breakStartedTime}~${breakFinishedTime}`
                ]
              }
            }
          }
        },
        scales: {
          y:{
            min: 0,
            max: 1440,
            ticks: {
              stepSize: 180,
              autoSkip: false,
              callback: function(value,index,ticks){
                return value/60 + ":00"
              }
            }
          },
          x:{
            ticks:{
              autoSkip: false,
              callback: function(value,index,ticks){
                const date = this.getLabelForValue(value).split("-").map((str) => parseInt(str))
                if (date[2] == 1){
                  return String(date[1]) + "/" + String(date[2])
                }
                else{
                  return String(date[2])
                }
              }
            }
          }
        }
      }
    };
    this.chart = new Chart(this.canvasTarget, config)
  }
  formatTime(totalMinutes){
    const hour = Math.floor(totalMinutes/60)%24
    const minutes = totalMinutes%60
    return `${hour}:${String(minutes).padStart(2,'0')}`
  }
  disconnect() {
    this.chart?.destroy()
  }
}
