import { Controller } from "stimulus"

let customerActualPaymentChart;

export default class extends Controller {
  static values = { pageLength: Number }

  connect() {
    customerActualPaymentChart = echarts.init(document.getElementById('customer-actual-payment-chart'));

    const xAxis = JSON.parse(this.data.get("x_axis"));
    const top20s = JSON.parse(this.data.get("top20s"));
    const top20to50 = JSON.parse(this.data.get("top20to50s"));
    const gt50s = JSON.parse(this.data.get("gt50s"));
    const others = JSON.parse(this.data.get("others"));

    const option = {
      legend: {
        data: ['TOP 20 房企','TOP 20-50 房企','非 TOP 50 大客户','其他'],
        align: 'left'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'cross'
        }
      },
      grid: {
        left: 65,
        right: 0,
        top: 48,
        bottom: 60
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
              pixelRatio: 2
          }
        }
      },
      xAxis: {
        data: xAxis,
        silent: true,
        axisLabel: {
          interval: 0,
          rotate: -40
        },
        splitLine: {
            show: false
        }
      },
      yAxis: [{
        type: 'value',
        position: 'left',
        axisLabel: {
          formatter: '{value}百万'
        }
      }],
      series: [{
        name: 'TOP 20 房企',
        type: 'bar',
        stack: '生产合同额',
        data: top20s,
        label: {
          show: true,
          position: 'inside'
        }
      },{
        name: 'TOP 20-50 房企',
        type: 'bar',
        stack: '生产合同额',
        data: top20to50,
        label: {
          show: true,
          position: 'inside'
        }
      },{
        name: '非 TOP 50 大客户',
        type: 'bar',
        stack: '生产合同额',
        data: gt50s,
      },{
        name: '其他',
        type: 'bar',
        stack: '生产合同额',
        data: others,
        label: {
          show: true,
          position: 'inside'
        }
      }]
    };

    customerActualPaymentChart.setOption(option, false);
  }

  layout() {
    customerActualPaymentChart.resize();
  }

  disconnect() {
    customerActualPaymentChart.dispose();
  }
}
