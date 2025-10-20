import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "select" ]

    // ここでは選択されたソートの種類を取得する
    option () {
        const option = this.selectTarget.value;
    }
}