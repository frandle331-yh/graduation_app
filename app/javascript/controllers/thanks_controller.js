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
        // トースト通知を表示
        this.showToast("💜 ありがとうを送りました！")
      } else {
        const data = await res.json().catch(() => ({}))
        this.showToast(data.error || "送信に失敗しました", "alert")
        btn.disabled = false
      }
    } catch {
      this.showToast("通信エラーが発生しました", "alert")
      btn.disabled = false
    }
  }

  showToast(message, type = "notice") {
    const container = document.getElementById("toast-container")
    if (!container) return

    const toast = document.createElement("div")
    toast.className = `toast toast--${type}`
    toast.dataset.controller = "toast"
    toast.dataset.toastDurationValue = "3000"
    toast.innerHTML = `
      <span class="toast__icon">${type === "notice" ? "✅" : "⚠️"}</span>
      <span class="toast__message">${message}</span>
      <button class="toast__close" data-action="toast#dismiss" aria-label="閉じる">×</button>
    `
    container.appendChild(toast)
  }
}
