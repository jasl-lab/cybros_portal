import { Controller } from "stimulus"

let contractSigningsChart;

export default class extends Controller {
  connect() {
    contractSigningsChart = echarts.init(document.getElementById('contract-signings-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var sumContractAmounts = JSON.parse(this.data.get("sum_contract_amounts"));
var avgPeriodMean = JSON.parse(this.data.get("avg_period_mean"));
var avgPeriodMeanMax = JSON.parse(this.data.get("avg_period_mean_max"));
var periodMeanRef = this.data.get("period_mean_ref");

var option = {
    legend: {
        data: ['本年累计合同额', '签约周期'],
        align: 'left'
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      }
    },
    grid: {
      left: 70,
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
      name: '本年累计合同额（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      }
    },{
      type: 'value',
      name: '签约周期（天）',
      position: 'right',
      min: 0,
      max: avgPeriodMeanMax,
      axisLine: {
        lineStyle: {
          color: '#675BBA'
        }
      },
      axisLabel: {
        formatter: '{value}天'
      }
    }],
    series: [{
      name: '本年累计合同额',
      type: 'bar',
      data: sumContractAmounts
    },{
      name: '签约周期',
      type: 'line',
      yAxisIndex: 1,
      symbol: 'circle',
      symbolSize: 8,
      data: avgPeriodMean,
      markLine: {
        label: {
          formatter: '签约周期{c}天线'
        },
        lineStyle: {
          type: 'solid',
          width: 1
        },
        data: [
          {
            yAxis: periodMeanRef
          }
        ]
      }
    }]
};

    contractSigningsChart.setOption(option, false);
    setTimeout(() => {
      contractSigningsChart.resize();
    }, 200);
  }

  layout() {
    contractSigningsChart.resize();
  }

  disconnect() {
    contractSigningsChart.dispose();
  }
}
