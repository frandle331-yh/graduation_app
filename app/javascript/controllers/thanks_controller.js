import { Controller } from "@hotwired/stimulus"

// 「ありがとう」ボタンのAJAXリアクション
export default class extends Controller {
  static targets = ["button", "heart", "count"]
  static values  = { url: String }

  async send() {
    const btn = this.buttonTarget
    if (btn.disabled) return

    btn.disabled = true

    try {
      const res = await fetch(this.urlValue, {
        method:  "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Content-Type": "application/json",
          "Accept":       "application/json"
        }
      })

      if (res.ok) {
        const data = await res.json()
        // カウント更新
        this.countTarget.textContent = data.thanks_count
        // ハート爆発アニメーション
        this.heartTarget.classList.add("thanks-btn__heart--sent")
        this.element.classList.add("thanks-block--sent")
        // ボタンを「送り済み」スタイルに
        btn.classList.add("thanks-btn--sent")
        btn.querySelector(".thanks-btn__text").textContent = "ありがとうを送りました！"
      } else {
        btn.disabled = false
      }
    } catch {
      btn.disabled = false
    }
  }
}
