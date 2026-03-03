import { Controller } from "@hotwired/stimulus"

// フォーム送信時にボタンをdisabledにしてスピナーを表示する
export default class extends Controller {
  static targets = ["button"]
  static values = { label: String }

  submit(event) {
    // バリデーションエラーの場合は発火させない
    const form = event.target.closest("form") || this.element
    if (form && !form.checkValidity()) return

    this.buttonTargets.forEach((btn) => {
      btn.disabled = true
      const original = btn.textContent.trim()
      btn.dataset.originalLabel = original
      btn.innerHTML = `<span class="spinner"></span>${this.labelValue || "送信中..."}`
    })
  }
}
