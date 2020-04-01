import { Controller } from "stimulus"

let deptValueChart;
let contractAmountChart;
let realAmountChart;

function set_chart(chart, amounts, amounts_names, x_axis) {
  const predefine_color = ['#738496','#675BBA','#FA9291','#A1D189'];

  function build_serial(year, index) {
    console.log(year, index)
    return {
        name: amounts_names[index] + '实收款',
        type: 'bar',
        data: amounts[year],
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

  function build_legend(year, index) {
    return amounts_names[index] + '实收款';
  }

  const series = amounts_names.map(build_serial);

  const legend = amounts_names.map(build_legend);

  const option_amounts = {
      legend: {
          data: legend,
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
        data: x_axis,
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
      series: series
  };


  chart.setOption(option_amounts, false);
}

export default class extends Controller {
  connect() {
    deptValueChart = echarts.init(document.getElementById('dept-value-chart'));
    contractAmountChart = echarts.init(document.getElementById('contract-amount-chart'));
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const yearsDeptValues = JSON.parse(this.data.get("years_dept_values"));
    const yearsContractAmounts = JSON.parse(this.data.get("years_contract_amounts"));
    const yearsRealAmounts = JSON.parse(this.data.get("years_real_amounts"));

    const yearsDeptValues_names = Object.keys(yearsDeptValues)
    const yearsContractAmounts_names = Object.keys(yearsContractAmounts)
    const yearsRealAmounts_names = Object.keys(yearsRealAmounts)

    set_chart(deptValueChart, yearsDeptValues, yearsDeptValues_names, xAxisData);
    set_chart(contractAmountChart, yearsContractAmounts, yearsContractAmounts_names, xAxisData);
    set_chart(realAmountChart, yearsRealAmounts, yearsRealAmounts_names, xAxisData);

    setTimeout(() => {
      deptValueChart.resize();
      contractAmountChart.resize();
      realAmountChart.resize();
    }, 200);
  }

  layout() {
    deptValueChart.resize();
    contractAmountChart.resize();
    realAmountChart.resize();
  }

  disconnect() {
    deptValueChart.dispose();
    contractAmountChart.dispose();
    realAmountChart.dispose();
  }
}
