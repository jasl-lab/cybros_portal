import { Controller } from "stimulus"

let predictContractChart;

export default class extends Controller {
  connect() {
    predictContractChart = echarts.init(document.getElementById('predict-contract-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var deptCodes = JSON.parse(this.data.get("dept_codes_as_options"));
var contractConvert = JSON.parse(this.data.get("contract_convert"));
var convertRealAmount = JSON.parse(this.data.get("convert_real_amount"));
var contractConvertTotals = JSON.parse(this.data.get("contract_convert_totals"));

var option = {
    legend: {
        data: ['跟踪合同额','跟踪合同额（成功率小于80%）','流转中合同额（成功率等于80%）'],
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
      },
      min: 0
    }],
    series: [{
      name: '跟踪合同额（万元）',
      type: 'bar',
      barWidth: '30%',
      barGap: '-100%',
      data: contractConvertTotals,
      barMaxWidth: 90,
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
      name: '跟踪合同额（成功率小于80%）',
      type: 'bar',
      stack: '总量',
      data: contractConvert,
      barMaxWidth: 90,
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
      name: '流转中合同额（成功率等于80%）',
      type: 'bar',
      stack: '总量',
      data: convertRealAmount,
      barMaxWidth: 90,
      itemStyle: {
        color: '#334B5C'
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
          const department_code = deptCodes[params.dataIndex];
          const month_name = $('#month_name').val();
          const sent_data = { department_name, department_code, month_name };
          let drill_down_url;
          switch (params.seriesName) {
            case '跟踪合同额（成功率小于80%）':
              drill_down_url = '/report/predict_contract/opportunity_detail_drill_down';
              break;
            case '流转中合同额（成功率等于80%）':
              drill_down_url = '/report/predict_contract/signing_detail_drill_down';
              break;
          }
          if (drill_down_url !== undefined) {
            $.ajax(drill_down_url, {
              data: sent_data,
              dataType: 'script'
            });
          }
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
