import { Controller } from "@hotwired/stimulus"

// 自動消去付きトースト通知
// data-controller="toast" を付けた要素が表示後に自動でフェードアウトする
export default class extends Controller {
  static values = { duration: { type: Number, default: 4000 } }

  connect() {
    // 次フレームでアニメーションクラスを付与（CSS transition 発火）
    requestAnimationFrame(() => {
      this.element.classList.add("toast--visible")
    })

    this.timeout = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.remove("toast--visible")
    this.element.classList.add("toast--hiding")
    this.element.addEventListener("transitionend", () => {
      this.element.remove()
    }, { once: true })
    // フォールバック: transition が発火しなかった場合
    setTimeout(() => this.element.remove(), 500)
  }
}
