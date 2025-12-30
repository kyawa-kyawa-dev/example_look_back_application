import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button", "content"]

    selectTab(event) {
        const clickedButton = event.currentTarget
        const tabName = clickedButton.dataset.tabName

        // 全てのボタンから active スタイルを削除
        this.buttonTargets.forEach(button => {
            button.classList.remove("text-indigo-600")
            button.classList.add("text-gray-500", "hover:text-gray-700")

            // 下線を非表示
            const underline = button.querySelector(".absolute")
            if (underline) {
                underline.classList.add("hidden")
            }
        })

        // クリックされたボタンに active スタイルを追加
        clickedButton.classList.remove("text-gray-500", "hover:text-gray-700")
        clickedButton.classList.add("text-indigo-600")

        // 下線を表示
        const clickedUnderline = clickedButton.querySelector(".absolute")
        if (clickedUnderline) {
            clickedUnderline.classList.remove("hidden")
        }

        // 全てのコンテンツを非表示
        this.contentTargets.forEach(content => {
            content.classList.add("hidden")
        })

        // 対応するコンテンツを表示
        const activeContent = this.contentTargets.find(
            content => content.dataset.tabName === tabName
        )
        if (activeContent) {
            activeContent.classList.remove("hidden")
        }
    }
}
