import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["tag", "hidden", "checkmark", "closeButton"]

    select(event) {
        const tag = event.currentTarget
        const tagId = tag.id
        const hidden = this.hiddenTargets.find(h => h.id === tagId)
        const checkmark = tag.querySelector('[data-knowledge-checkmark]')
        const closeButton = tag.querySelector('[data-knowledge-close]')

        if (tag.classList.contains("ring-2")) {
            // 選択解除
            tag.classList.remove("ring-2", "ring-offset-2")
            tag.classList.add("opacity-70", "hover:opacity-100")
            if (checkmark) checkmark.classList.add("hidden")
            if (closeButton) closeButton.classList.add("hidden")

            // hiddenフィールドをクリア
            hidden.name = ""
            hidden.value = ""
        } else {
            // 選択
            tag.classList.remove("opacity-70", "hover:opacity-100")
            tag.classList.add("ring-2", "ring-offset-2")
            if (checkmark) checkmark.classList.remove("hidden")
            if (closeButton) closeButton.classList.remove("hidden")

            // hiddenフィールドに値を設定
            hidden.name = "knowledge[tag_ids][]"
            hidden.value = tagId
        }
    }
}