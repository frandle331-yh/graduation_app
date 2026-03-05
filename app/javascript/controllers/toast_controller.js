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
    const el = this.element
    el.classList.remove("toast--visible")
    el.classList.add("toast--hiding")
    el.addEventListener("transitionend", () => {
      el.remove()
    }, { once: true })
    // フォールバック: transition が発火しなかった場合（CSS 300ms + 余裕）
    setTimeout(() => { if (el.parentNode) el.remove() }, 350)
  }
}
