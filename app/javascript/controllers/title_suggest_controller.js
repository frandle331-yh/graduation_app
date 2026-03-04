import { Controller } from "@hotwired/stimulus"

// カテゴリ選択時にタイトル候補をチップ表示し、タップで入力
export default class extends Controller {
  static targets = ["categorySelect", "titleInput", "suggestions", "hint"]
  static values  = { url: String }

  categoryChanged() {
    const category = this.categorySelectTarget.value
    if (!category) {
      this.#clear()
      return
    }

    this.#fetchSuggestions(category)
    this.#showHint()
  }

  pick(event) {
    event.preventDefault()
    this.titleInputTarget.value = event.currentTarget.dataset.title
    // 選択状態をビジュアルに反映
    this.suggestionsTarget.querySelectorAll(".title-chip").forEach(el => {
      el.classList.remove("title-chip--active")
    })
    event.currentTarget.classList.add("title-chip--active")
  }

  async #fetchSuggestions(category) {
    try {
      const url = `${this.urlValue}?category=${encodeURIComponent(category)}`
      const res = await fetch(url, { headers: { Accept: "application/json" } })
      const titles = await res.json()
      this.#render(titles)
    } catch {
      this.#clear()
    }
  }

  #render(titles) {
    if (!titles.length) {
      this.suggestionsTarget.innerHTML = ""
      this.suggestionsTarget.hidden = true
      return
    }

    this.suggestionsTarget.innerHTML = titles.map(t =>
      `<button type="button"
              class="title-chip"
              data-title="${this.#escape(t)}"
              data-action="title-suggest#pick">${this.#escape(t)}</button>`
    ).join("")
    this.suggestionsTarget.hidden = false
  }

  #showHint() {
    if (this.hasHintTarget) {
      this.hintTarget.hidden = false
    }
  }

  #clear() {
    this.suggestionsTarget.innerHTML = ""
    this.suggestionsTarget.hidden = true
    if (this.hasHintTarget) {
      this.hintTarget.hidden = true
    }
  }

  #escape(str) {
    return str.replace(/[&<>"']/g, c =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])
    )
  }
}
