import { Controller } from "stimulus"

let predictContractChart;

export default class extends Controller {
  connect() {
    predictContractChart = echarts.init(document.getElementById('predict-contract-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var contractConvert = JSON.parse(this.data.get("contract_convert"));
var convertRealAmount = JSON.parse(this.data.get("convert_real_amount"));
var contractConvertTotals = JSON.parse(this.data.get("contract_convert_totals"));

var option = {
    legend: {
        data: ['跟踪合同额','成功率<80%的合同额（万元）','成功率=80%的合同额（万元）'],
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
      name: '跟踪合同额（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '跟踪合同额（万元）',
      type: 'bar',
      barWidth: '30%',
      barGap: '-100%',
      data: contractConvertTotals,
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
      name: '成功率<80%的合同额（万元）',
      type: 'bar',
      stack: '总量',
      data: contractConvert,
      itemStyle: {
        color: '#DDDDDD'
      },
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '成功率=80%的合同额（万元）',
      type: 'bar',
      stack: '总量',
      data: convertRealAmount,
      barMaxWidth: 90,
      itemStyle: {
        color: '#738496'
      },
      label: {
        normal: {
          show: false
        }
      }
    }]
};

    function drill_down_contract_detail(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const department_name = xAxisData[params.dataIndex];
          const sent_data = { department_name: department_name };
          let drill_down_url
          console.log(params.seriesName);
          switch (params.seriesName) {
            case '成功率<80%的合同额（万元）':
              drill_down_url = '/report/predict_contract/opportunity_detail_drill_down';
              break;
            case '成功率=80%的合同额（万元）':
              drill_down_url = '/report/predict_contract/signing_detail_drill_down';
              break;
          }
          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        }
      }
    }

    predictContractChart.setOption(option, false);
    predictContractChart.on('click', drill_down_contract_detail);

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
