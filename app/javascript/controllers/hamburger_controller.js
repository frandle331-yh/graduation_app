import { Controller } from "@hotwired/stimulus"

// ハンバーガーメニューの開閉を制御する
export default class extends Controller {
  static targets = ["drawer", "button"]

  toggle() {
    const isOpen = this.drawerTarget.classList.toggle("is-open")
    this.buttonTarget.setAttribute("aria-expanded", isOpen)
    this.buttonTarget.setAttribute("aria-label", isOpen ? "メニューを閉じる" : "メニューを開く")
  }

  close() {
    this.drawerTarget.classList.remove("is-open")
    this.buttonTarget.setAttribute("aria-expanded", false)
    this.buttonTarget.setAttribute("aria-label", "メニューを開く")
  }
}
