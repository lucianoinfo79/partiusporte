import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "route"]

  connect() {
    this.selectIndex(0)
  }

  select(event) {
    const index = Number(event.currentTarget.dataset.routeIndex)
    this.selectIndex(index)
  }

  selectIndex(index) {
    this.routeTargets.forEach((route) => {
      route.hidden = Number(route.dataset.routeIndex) !== index
    })
    this.tabTargets.forEach((tab, tabIndex) => {
      const selected = tabIndex === index
      tab.setAttribute("aria-pressed", selected ? "true" : "false")
      tab.classList.toggle("is-selected", selected)
    })
  }
}
