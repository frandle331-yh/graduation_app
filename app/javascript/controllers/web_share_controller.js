import { Controller } from "@hotwired/stimulus"

// Web Share API を使った共有ボタン
// navigator.share が利用可能な場合のみ表示される
export default class extends Controller {
  static values = { title: String, text: String }

  connect() {
    if (navigator.share) {
      this.element.style.display = ""
    }
  }

  async share() {
    try {
      await navigator.share({
        title: this.titleValue,
        text: this.textValue
      })
    } catch {
      // ユーザーがキャンセルした場合は無視
    }
  }
}
