import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu-btn"
export default class extends Controller {
  static targets = ["summary", "table"];

  connect() {
  }

  toggle() {
    this.tableTarget.classList.toggle("show");
  }
}
