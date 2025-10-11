import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["child"]

    close (event) {
        const child = this.childTarget;
        child.remove();
    }
}