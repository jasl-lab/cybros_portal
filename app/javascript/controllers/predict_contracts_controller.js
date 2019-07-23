import { Controller } from "stimulus"

let predictContractChart;

export default class extends Controller {
  connect() {
    predictContractChart = echarts.init(document.getElementById('predict-contract-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var contractConvert = JSON.parse(this.data.get("contract_convert"));
var contractCount = JSON.parse(this.data.get("contract_count"));

var option = {
    legend: {
        data: ['跟踪合同额（万元）','跟踪合同数目'],
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
        rotate: -40
      },
      splitLine: {
          show: false
      }
    },
    yAxis: [{
      type: 'value',
      name: '跟踪合同额（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      },
      splitLine: {
        show: false
      }
    },{
      type: 'value',
      name: '跟踪合同数目',
      position: 'right',
      axisLine: {
        lineStyle: {
          color: '#675BBA'
        }
      },
      splitLine: {
        show: false
      }
    }],
    series: [{
      name: '跟踪合同额（万元）',
      type: 'bar',
      yAxisIndex: 1,
      symbol: 'circle',
      symbolSize: 8,
      data: contractConvert,
      color: '#334B5C',
      label: {
        normal: {
          show: true,
          position: 'top',
          color: '#353535'
        }
      }
    },{
      name: '跟踪合同数目',
      type: 'line',
      data: contractCount,
      color: '#738496',
      barMaxWidth: 80,
      label: {
        normal: {
          show: true,
          position: 'top'
        }
      }
    }]
};

    predictContractChart.setOption(option, false);
    setTimeout(() => {
      predictContractChart.resize();
    }, 200);
  }

  layout() {
    predictContractChart.resize();
  }

  disconnect() {
    predictContractChart.dispose();
  }
}
