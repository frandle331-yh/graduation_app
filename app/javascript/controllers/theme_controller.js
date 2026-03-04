import { Controller } from "@hotwired/stimulus"

// テーマ切替（ライト / ダーク / システム自動）
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyStoredTheme()
  }

  toggle() {
    const current = localStorage.getItem("theme")
    let next

    if (current === "dark") {
      next = "light"
    } else if (current === "light") {
      next = null  // システム自動に戻す
    } else {
      next = "dark"
    }

    if (next) {
      localStorage.setItem("theme", next)
      document.documentElement.setAttribute("data-theme", next)
    } else {
      localStorage.removeItem("theme")
      document.documentElement.removeAttribute("data-theme")
    }

    this.updateIcon()
  }

  applyStoredTheme() {
    const stored = localStorage.getItem("theme")
    if (stored) {
      document.documentElement.setAttribute("data-theme", stored)
    }
    this.updateIcon()
  }

  updateIcon() {
    if (!this.hasIconTarget) return
    const stored = localStorage.getItem("theme")
    if (stored === "dark") {
      this.iconTarget.textContent = "🌙"
    } else if (stored === "light") {
      this.iconTarget.textContent = "☀️"
    } else {
      this.iconTarget.textContent = "🌓"
    }
  }
}
