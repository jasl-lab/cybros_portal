import { Controller } from "stimulus"

let majorCustomerContractsDashboard;

export default class extends Controller {
  connect() {
    majorCustomerContractsDashboard = echarts.init(document.getElementById('major-customer-contracts-dashboard'));

    console.log('majorCustomerContractsDashboard');

    setTimeout(() => {
      majorCustomerContractsDashboard.resize();
    }, 200);
  }

  layout() {
    majorCustomerContractsDashboard.resize();
  }

  disconnect() {
    majorCustomerContractsDashboard.dispose();
  }
}
