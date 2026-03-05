import { Controller } from "@hotwired/stimulus"

// 所要時間のプリセットボタン（5/10/15/30/60分）
export default class extends Controller {
  static targets = ["input", "btn"]

  pick(event) {
    event.preventDefault()
    const minutes = event.currentTarget.dataset.minutes
    this.inputTarget.value = minutes

    // 選択状態の反映
    this.btnTargets.forEach(btn => btn.classList.remove("time-preset--active"))
    event.currentTarget.classList.add("time-preset--active")
  }
}
