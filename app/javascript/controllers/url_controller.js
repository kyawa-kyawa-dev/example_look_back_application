import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "url", "delete", "container"]

  add () {
    // url_fieldを追加する親要素を取得
    const container = this.containerTarget

    // inputタグを作成
    const newInputElement = document.createElement("input")
    newInputElement.type = "url"
    newInputElement.name = "knowledge[urls][]"
    newInputElement.placeholder = "https://example.com"
    newInputElement.className = "flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"

    // buttonタグを作成
    const newButtonElement = document.createElement("button")
    newButtonElement.type = "button"
    newButtonElement.className = "px-3 py-3 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition-colors"
    newButtonElement.innerHTML = `
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
      </svg>
    `

    // wrapperのdivを作成
    const wrapper = document.createElement("div")
    wrapper.className = "flex gap-2"
    wrapper.appendChild(newInputElement)
    wrapper.appendChild(newButtonElement)

    // containerの末尾に挿入
    // insertAdjacentElement("beforebegin")ではbuttonTargetの開始タグの前にwrapperを挿入する
    this.buttonTarget.insertAdjacentElement("beforebegin", wrapper)
  }

  delete () {
    const url = this.urlTarget
    // クリックされたURL入力欄を削除する
    url.remove()

    console.log("クリックされました")
  }
}
