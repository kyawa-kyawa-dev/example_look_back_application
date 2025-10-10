import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["flash"]

    close () {
        // 閉じるボタンを押すことでフラッシュメッセージを削除する
        this.flashTarget.remove()
    }
}