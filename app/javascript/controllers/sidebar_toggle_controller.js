import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    // ヘッダーの実際の高さを取得してサイドバーの位置を調整
    const header = document.querySelector('header')
    if (header && this.hasSidebarTarget) {
      const headerHeight = header.offsetHeight
      this.sidebarTarget.style.top = `${headerHeight}px`
      this.sidebarTarget.style.height = `calc(100vh - ${headerHeight}px)`
    }
  }

  toggle() {
    this.sidebarTarget.classList.toggle('-translate-x-full')
    this.overlayTarget.classList.toggle('hidden')
  }
}
