import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "form" ]

  submit_form(event) {
    console.log("Hello submit_form");
  }
}
