import { Controller } from "stimulus"

let receiveAmountDashboard;

export default class extends Controller {
  connect() {
    receiveAmountDashboard = echarts.init(document.getElementById('receive-amount-dashboard'));

    console.log('Hello receiveAmountDashboard');
    setTimeout(() => {
      receiveAmountDashboard.resize();
    }, 200);
  }

  layout() {
    receiveAmountDashboard.resize();
  }

  disconnect() {
    receiveAmountDashboard.dispose();
  }
}
