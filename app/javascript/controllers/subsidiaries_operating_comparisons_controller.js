import { Controller } from "stimulus"

let realAmountChart;

export default class extends Controller {
  connect() {
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const yearsRealAmounts = JSON.parse(this.data.get("years_real_amounts"));

    console.log(yearsRealAmounts);

    setTimeout(() => {
      realAmountChart.resize();
    }, 200);
  }

  layout() {
    realAmountChart.resize();
  }

  disconnect() {
    realAmountChart.dispose();
  }
}
