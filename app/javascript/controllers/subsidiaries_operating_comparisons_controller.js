import { Controller } from "stimulus"

let realAmountChart;

export default class extends Controller {
  connect() {
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));

    const predefine_color = ['#738496','#675BBA','#FA9291','#A1D189'];

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const yearsRealAmounts = JSON.parse(this.data.get("years_real_amounts"));

    const yearsRealAmounts_names = Object.keys(yearsRealAmounts)
    function build_real_amount_serail(year, index) {
      console.log(year, index)
      return {
          name: yearsRealAmounts_names[index] + '实收款',
          type: 'bar',
          data: yearsRealAmounts[year],
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: predefine_color[index%3]
          }
        }
    }

    function build_real_amount_legend(year, index) {
      return yearsRealAmounts_names[index] + '实收款';
    }

    const yearsRealAmount_series = yearsRealAmounts_names.map(build_real_amount_serail);

    const yearsRealAmount_legend = yearsRealAmounts_names.map(build_real_amount_legend);

    const option_years_real_amounts = {
        legend: {
            data: yearsRealAmount_legend,
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
        series: yearsRealAmount_series
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
