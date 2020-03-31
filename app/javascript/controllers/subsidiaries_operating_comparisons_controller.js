import { Controller } from "stimulus"

let realAmountChart;

export default class extends Controller {
  connect() {
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const yearsRealAmounts = JSON.parse(this.data.get("years_real_amounts"));

    const option_years_real_amounts = {
        legend: {
            data: ['生产合同额'],
            align: 'left'
        },
        grid: {
          left: 70,
          right: 50,
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
          name: '生产合同额',
          type: 'bar',
          data: yearsRealAmounts['2018'],
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#738496'
          }
        }]
    };


    realAmountChart.setOption(option_years_real_amounts, false);

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
