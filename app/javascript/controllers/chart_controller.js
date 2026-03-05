import { Controller } from "@hotwired/stimulus"
import "chart.js"

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    type: String,
    labels: Array,
    data: Array,
    colors: Array,
    legend: { type: Boolean, default: false },
    legendPosition: { type: String, default: "bottom" }
  }

  connect() {
    this.chart = new Chart(this.canvasTarget, this.#chartConfig())
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  #chartConfig() {
    if (this.typeValue === "bar") {
      return this.#barConfig()
    }
    return this.#doughnutConfig()
  }

  #barConfig() {
    return {
      type: "bar",
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: "所要時間（分）",
          data: this.dataValue,
          backgroundColor: this.colorsValue.length ? this.colorsValue[0] : "rgba(99, 132, 255, 0.7)",
          borderRadius: 4
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true } }
      }
    }
  }

  #doughnutConfig() {
    return {
      type: "doughnut",
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.dataValue,
          backgroundColor: this.colorsValue.length ? this.colorsValue : [
            "#6384FF", "#FF6384", "#FFCE56", "#4BC0C0", "#9966FF", "#FF9F40", "#C9CBCF"
          ]
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: this.legendValue,
            position: this.legendPositionValue
          }
        }
      }
    }
  }
}
