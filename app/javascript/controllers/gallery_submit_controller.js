import { Controller } from "@hotwired/stimulus"

// Progressive enhancement: the GET form works without JavaScript.
export default class extends Controller {
  static targets = ["button"]

  submit() {
    this.element.setAttribute("aria-busy", "true")
    if (this.hasButtonTarget) {
      this.buttonTarget.value = "Carregando..."
      // Do not disable the submit button: browsers may omit disabled submitters,
      // and the native GET navigation should remain functional.
    }
  }

  connect() {
    this.element.removeAttribute("aria-busy")
  }
}
