import { Controller } from "@hotwired/stimulus"

// クリップボードにテキストをコピーし、ボタンのラベルを一時的に変更する
export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    const text = this.sourceTarget.textContent.trim()
    const btn = this.buttonTarget

    try {
      await navigator.clipboard.writeText(text)
      const orig = btn.textContent
      btn.textContent = "コピー済 \u2713"
      btn.disabled = true
      setTimeout(() => { btn.textContent = orig; btn.disabled = false }, 2000)
    } catch {
      // フォールバック: clipboard API 非対応
    }
  }
}
