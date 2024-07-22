import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu-btn"
export default class extends Controller {
  static targets = ["summary", "table"];

  connect() {
    console.log("Hello");
  }

  toggle() {
    console.log("Clicked");
    this.tableTarget.classList.toggle("show");
  }
}
