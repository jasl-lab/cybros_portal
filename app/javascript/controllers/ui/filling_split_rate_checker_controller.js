import { Controller } from "stimulus"

function ifAddTo100(usc_id, index, is100) {
  const textFields = document.querySelectorAll(`.js-user-salary-classification-${usc_id}`);
  let sum = 0;
  for (let i = 0; i < textFields.length; i++) {
    let item = textFields[i];
    sum += parseFloat(item.value);
  }
  sum = Math.round((sum + Number.EPSILON) * 100) / 100
  document.getElementById(`sum-user-salary-classification-${usc_id}`).innerHTML = `${sum}%`
  is100[index] = sum;
}

export default class extends Controller {
  static values = { uscIds: Array };

  connect() {
    this.check_all_text_fields();
  }

  change(event) {
    this.check_all_text_fields();
  }

  check_all_text_fields() {
    const is100 = Array(this.uscIdsValue.length);
    this.uscIdsValue.forEach(function(usec_id, index) { ifAddTo100(usec_id, index, is100) });
    if(is100.every(function(v) { return v === 100 })) {
      document.getElementById('submit-button').disabled = false;
    } else {
      document.getElementById('submit-button').disabled = true;
    }
  }
}
