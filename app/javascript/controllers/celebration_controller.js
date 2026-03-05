import { Controller } from "@hotwired/stimulus"

// 記録完了時のお祝いアニメーション
// flash notice が存在する場合にパーティクルを表示する
export default class extends Controller {
  connect() {
    this.#burst()
    // アニメーション後に要素を削除
    setTimeout(() => this.element.remove(), 2000)
  }

  #burst() {
    const emojis = ["🎉", "✨", "⭐", "🌟", "💪", "✅"]
    const container = this.element

    for (let i = 0; i < 12; i++) {
      const particle = document.createElement("span")
      particle.className = "celebration-particle"
      particle.textContent = emojis[i % emojis.length]
      particle.style.setProperty("--x", `${(Math.random() - 0.5) * 200}px`)
      particle.style.setProperty("--y", `${-60 - Math.random() * 120}px`)
      particle.style.setProperty("--delay", `${Math.random() * 0.3}s`)
      particle.style.setProperty("--rotation", `${(Math.random() - 0.5) * 720}deg`)
      container.appendChild(particle)
    }
  }
}
