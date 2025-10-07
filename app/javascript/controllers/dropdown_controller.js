import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('hidden')
  }

  hide(event) {
    // メニュー内のクリックは無視
    if (this.element.contains(event.target)) {
      return
    }
    this.menuTarget.classList.add('hidden')
  }

  connect() {
    // ドキュメント全体でクリックを監視してメニューを閉じる
    this.hideHandler = this.hide.bind(this)
    document.addEventListener('click', this.hideHandler)
  }

  disconnect() {
    document.removeEventListener('click', this.hideHandler)
  }
}
