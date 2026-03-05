import { Controller } from "@hotwired/stimulus"

// タイトル検索のオートコンプリート
export default class extends Controller {
  static targets = ["input", "list"]
  static values  = { url: String }

  #debounceTimer = null

  connect() {
    // 重複リスナー防止
    this.disconnect()
    // クリックで候補を閉じる
    this._outsideClick = (e) => {
      if (!this.element.contains(e.target)) this.#close()
    }
    document.addEventListener("click", this._outsideClick)
  }

  disconnect() {
    clearTimeout(this.#debounceTimer)
    if (this._outsideClick) {
      document.removeEventListener("click", this._outsideClick)
      this._outsideClick = null
    }
  }

  // input イベントでデバウンスしてサジェストを取得
  suggest() {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => this.#fetch(), 300)
  }

  // 候補クリックで入力欄にセット＆フォーム送信
  select(event) {
    this.inputTarget.value = event.currentTarget.dataset.value
    this.#close()
    this.element.closest("form").requestSubmit()
  }

  // キーボード操作（上下矢印・Enter・Escape）
  keydown(event) {
    const items = this.listTarget.querySelectorAll("[data-autocomplete-action]")
    const current = this.listTarget.querySelector("[aria-selected='true']")

    if (event.key === "Escape") {
      this.#close()
      return
    }

    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault()
      const idx = [...items].indexOf(current)
      let next
      if (event.key === "ArrowDown") {
        next = items[idx + 1] || items[0]
      } else {
        next = items[idx - 1] || items[items.length - 1]
      }
      if (current) current.removeAttribute("aria-selected")
      if (next) {
        next.setAttribute("aria-selected", "true")
        this.inputTarget.value = next.dataset.value
      }
      return
    }

    if (event.key === "Enter" && current) {
      event.preventDefault()
      this.inputTarget.value = current.dataset.value
      this.#close()
      this.element.closest("form").requestSubmit()
    }
  }

  async #fetch() {
    const q = this.inputTarget.value.trim()
    if (!q) { this.#close(); return }

    const url = `${this.urlValue}?q=${encodeURIComponent(q)}`
    try {
      const res = await fetch(url, { headers: { Accept: "application/json" } })
      const titles = await res.json()
      this.#render(titles)
    } catch {
      this.#close()
    }
  }

  #render(titles) {
    if (!titles.length) { this.#close(); return }

    this.listTarget.innerHTML = titles.map((t) =>
      `<li role="option"
           data-value="${this.#escape(t)}"
           data-autocomplete-action="click->autocomplete#select"
           class="autocomplete-item">${this.#escape(t)}</li>`
    ).join("")

    this.listTarget.hidden = false
  }

  #close() {
    this.listTarget.innerHTML = ""
    this.listTarget.hidden = true
  }

  #escape(str) {
    return str.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]))
  }
}
