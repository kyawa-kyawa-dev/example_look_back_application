import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["flash"]

    close () {
        // 閉じるボタンを押すことでフラッシュメッセージの直下のdivを削除する
        // this.elementはdata-controller="flash"が接続されている要素自体を指す
        const flashMessage = this.element.firstElementChild
        if (flashMessage) {
            flashMessage.remove()
        }
    }
}