// これはタグの登録の際にカラーピッカーでカラーが選択されたら自動的に反映する処理
import {  Controller } from "@hotwired/stimulus"

export default class extends Controller { 
    // HTMLでdata-color-target=pickerと指定されたDOMを使用することを指定
    // document.querySelectorを使用しないでもDOMにアクセスできるようにする
    static targets = [ "picker", "preview" ]

    // ここでpicker要素がクリックされた際のイベントを定義する
    getColor() {
        const color = this.pickerTarget.value;
        const preview = this.previewTarget;

        // プレビューに色を適用（20%の透明度で背景、40%で枠線）
        preview.style.backgroundColor = color + "20";
        preview.style.color = color;
        preview.style.borderColor = color + "40";
    }
}