import { Controller } from "stimulus"

let realAmountChart;
let contractAmountChart;

export default class extends Controller {
  connect() {
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));
    contractAmountChart = echarts.init(document.getElementById('contract-amount-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const realAmount = JSON.parse(this.data.get("real_amount"));
    const contractAmount = JSON.parse(this.data.get("contract_amount"));
    const avgWorkNo = JSON.parse(this.data.get("avg_work_no"));
    const avgStaffNo = JSON.parse(this.data.get("avg_staff_no"));

    const option_real_amount = {
        legend: {
            data: ['商务合同额'],
            align: 'left'
        },
        grid: {
          left: 150,
          right: 110,
          top: 60,
          bottom: 125
        },
        toolbox: {
          feature: {
            dataView: {},
            saveAsImage: {
                pixelRatio: 2
            }
          }
        },
        tooltip: {},
        xAxis: {
          data: xAxisData,
          silent: true,
          axisLabel: {
            interval: 0
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value} 百万'
          }
        },
        series: [{
          name: '商务合同额',
          type: 'bar',
          data: contractAmount,
          itemStyle: {
            color: '#738496'
          }
        }]
    };

    const option_contract_amount = {
        legend: {
            data: ['实收款'],
            align: 'left'
        },
        grid: {
          left: 150,
          right: 110,
          top: 60,
          bottom: 125
        },
        toolbox: {
          feature: {
            dataView: {},
            saveAsImage: {
                pixelRatio: 2
            }
          }
        },
        tooltip: {},
        xAxis: {
          data: xAxisData,
          silent: true,
          axisLabel: {
            interval: 0
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value} 百万'
          }
        },
        series: [{
          name: '实收款',
          type: 'bar',
          data: realAmount,
          itemStyle: {
            color: '#738496'
          }
        }]
    };

    realAmountChart.setOption(option_real_amount, false);
    contractAmountChart.setOption(option_contract_amount, false);

    setTimeout(() => {
      realAmountChart.resize();
      contractAmountChart.resize();
    }, 200);
  }

  layout() {
    realAmountChart.resize();
    contractAmountChart.resize();
  }

  disconnect() {
    realAmountChart.dispose();
    contractAmountChart.dispose();
  }
}
