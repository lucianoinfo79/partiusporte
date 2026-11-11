import { Controller } from "@hotwired/stimulus"

// PP04.4: only uses preview URLs already authorized by the public catalog.
// No original/master photo URL, signed token, or new upstream API call.
export default class extends Controller {
  static targets = ["card", "dialog", "image", "status", "counter", "previous", "next"]

  connect() {
    this.currentIndex = 0
    this.onCancel = () => { this.imageTarget.removeAttribute("src"); this.returnFocus?.focus() }
    this.dialogTarget.addEventListener("close", this.onCancel)
    this.dialogTarget.addEventListener("cancel", this.onEscapeCancel = () => { this.statusTarget.textContent = "" })
    this.onImageLoad = () => { this.statusTarget.textContent = "" }
    this.onImageError = () => { this.statusTarget.textContent = "Não foi possível carregar a fotografia. Tente novamente." }
    this.imageTarget.addEventListener("load", this.onImageLoad)
    this.imageTarget.addEventListener("error", this.onImageError)
  }

  disconnect() {
    this.imageTarget.removeEventListener("load", this.onImageLoad)
    this.imageTarget.removeEventListener("error", this.onImageError)
    this.dialogTarget.removeEventListener("close", this.onCancel)
    this.dialogTarget.removeEventListener("cancel", this.onEscapeCancel)
    if (this.dialogTarget.open) this.dialogTarget.close()
  }

  open(event) {
    const index = Number(event.currentTarget.dataset.photoIndex)
    if (!Number.isInteger(index) || index < 0 || index >= this.cardTargets.length) return
    this.returnFocus = event.currentTarget
    this.currentIndex = index
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
    this.display()
    this.dialogTarget.querySelector(".pp-photos__viewer-close")?.focus()
  }

  display() {
    const card = this.cardTargets[this.currentIndex]
    const preview = card?.querySelector(".pp-photos__open img")
    if (!preview) return
    const src = preview.getAttribute("src")
    if (!src) return
    this.counterTarget.textContent = `Fotografia ${this.currentIndex + 1} de ${this.cardTargets.length} nesta página`
    this.previousTarget.disabled = this.currentIndex === 0
    this.nextTarget.disabled = this.currentIndex === this.cardTargets.length - 1
    const changed = this.imageTarget.getAttribute("src") !== src
    this.statusTarget.textContent = changed ? "Carregando fotografia…" : ""
    // The viewer never requests a new URL: it reuses the published card preview.
    if (changed) this.imageTarget.src = src
    if (this.imageTarget.complete && this.imageTarget.naturalWidth > 0) this.statusTarget.textContent = ""
  }

  previous() {
    if (this.currentIndex > 0) { this.currentIndex -= 1; this.display() }
  }

  next() {
    if (this.currentIndex < this.cardTargets.length - 1) { this.currentIndex += 1; this.display() }
  }

  close() {
    this.dialogTarget.close()
    this.imageTarget.removeAttribute("src")
    this.returnFocus?.focus()
  }

  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  onKeydown(event) {
    if (!this.dialogTarget.open) return
    if (event.key === "ArrowLeft") { event.preventDefault(); this.previous() }
    if (event.key === "ArrowRight") { event.preventDefault(); this.next() }
    // Native dialog handles Escape, including focus restoration via close event.
  }
}
