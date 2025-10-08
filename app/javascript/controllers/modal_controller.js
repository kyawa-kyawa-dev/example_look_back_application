import { Controller } from "@hotwired/stimulus"

// ここでは新規タグ作成の画面でのモーダルの制御を行う
export default class extends Controller {
    static targets = ["overlay"]

    open () {
        this.overlayTarget.classList.remove('hidden');
    }
}