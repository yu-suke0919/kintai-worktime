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
    console.log(this.labelsValue)
    const labels = this.labelsValue.map(value => value.date)
    const data = {
      labels: labels,
      datasets: [
        {
          label: '勤務時間',
          data: this.labelsValue.map(value =>{
            if(value.finished_minutes <= 1440){
              return ({x:value.date,y:[value.started_minutes,value.finished_minutes]})
            }else{
              return ({x:value.date,y:[value.started_minutes,1440]},
                      {x:value.date+1,y:[0,value.finished_minutes-1440]}
              )
            }
          }
          ),
          backgroundColor: "#3f4cff",
          grouped: false,
          order: 2,
        },
        {
          label: '休憩時間',
          data: this.labelsValue.map(value => 
            [value.break_started_minutes,value.break_finished_minutes]
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
        interaction: {
            mode: 'index'
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
            enabled: true,
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
            }
          }
        }
      }
    };
    this.chart = new Chart(this.canvasTarget, config)
  }
  disconnect() {
    this.chart?.destroy()
  }
}
