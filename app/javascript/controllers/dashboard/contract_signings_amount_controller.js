import { Controller } from "stimulus"

let contractSigningsAmountDashboard;

export default class extends Controller {
  connect() {
    contractSigningsAmountDashboard = echarts.init(document.getElementById('contract-signings-amount-dashboard'));
    console.log('Hello');
    setTimeout(() => {
      contractSigningsAmountDashboard.resize();
    }, 200);
  }

  layout() {
    contractSigningsAmountDashboard.resize();
  }

  disconnect() {
    contractSigningsAmountDashboard.dispose();
  }
}
