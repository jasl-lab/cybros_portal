import { Controller } from "stimulus"

let contractHoldChart;

export default class extends Controller {
  connect() {
    contractHoldChart = echarts.init(document.getElementById('contract-hold-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var bizRetentContract = JSON.parse(this.data.get("biz_retent_contract"));
var bizRetentNoContract = JSON.parse(this.data.get("biz_retent_no_contract"));
var bizRetentTotals = JSON.parse(this.data.get("biz_retent_totals"));

var option = {
    legend: {
        data: ['已签约的合同保有量（万元）','未签约的合同保有量（万元）'],
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
      top: 50,
      bottom: 100
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
        rotate: -40,
        margin: 24
      },
      splitLine: {
          show: false
      }
    },
    yAxis: [{
      type: 'value',
      name: '合同保有量（万元）',
      position: 'left',
      min: 0,
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '合同保有量合计（万元）',
      type: 'bar',
      barWidth: '30%',
      barGap: '-100%',
      data: bizRetentTotals,
      itemStyle: {
        color: '#DDDDDD'
      },
      label: {
        normal: {
          show: true,
          color: '#353535',
          position: 'top'
        }
      }
      }, {
      name: '已签约的合同保有量',
      type: 'bar',
      stack: '总量',
      data: bizRetentContract,
      itemStyle: {
        color: '#738496'
      },
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '未签约的合同保有量',
      type: 'bar',
      stack: '总量',
      data: bizRetentNoContract,
      barMaxWidth: 90,
      itemStyle: {
        color: '#DDDDDD'
      },
      label: {
        normal: {
          show: false
        }
      }
    }]
};

    contractHoldChart.setOption(option, false);
    setTimeout(() => {
      contractHoldChart.resize();
    }, 200);
  }

  layout() {
    contractHoldChart.resize();
  }

  disconnect() {
    contractHoldChart.dispose();
  }
}
