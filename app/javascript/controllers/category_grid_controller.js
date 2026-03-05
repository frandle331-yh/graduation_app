import { Controller } from "@hotwired/stimulus"

// カテゴリをアイコングリッドで選択
// hidden select と同期する
export default class extends Controller {
  static targets = ["select", "btn"]

  connect() {
    // 初期値があれば対応するボタンをアクティブに
    if (this.selectTarget.value) {
      this.#highlight(this.selectTarget.value)
    }
  }

  pick(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.category
    this.selectTarget.value = value

    this.#highlight(value)

    // select の change イベントを発火（title-suggest 連携用）
    this.selectTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  #highlight(value) {
    this.btnTargets.forEach(btn => {
      btn.classList.toggle("category-grid__btn--active", btn.dataset.category === value)
    })
  }
}
