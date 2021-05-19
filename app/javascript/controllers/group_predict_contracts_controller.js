import { Controller } from "stimulus"

let groupPredictContractChart;

export default class extends Controller {
  connect() {
    groupPredictContractChart = echarts.init(document.getElementById('group-predict-contract-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const orgCodes = JSON.parse(this.data.get("org_codes"));
    const contractConvert = JSON.parse(this.data.get("contract_convert"));
    const convertRealAmount = JSON.parse(this.data.get("convert_real_amount"));
    const contractConvertTotals = JSON.parse(this.data.get("contract_convert_totals"));

    const option = {
      legend: {
        data: ['跟踪合同额（万元）','跟踪合同额（成功率小于80%）','流转中合同额（成功率等于80%）'],
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
        itemStyle: {
          color: '#DDDDDD'
        },
        label: {
          show: true,
          color: '#353535',
          position: 'top'
        }
      },{
        name: '跟踪合同额（成功率小于80%）',
        type: 'bar',
        stack: '总量',
        data: contractConvert,
        barWidth: 20,
        itemStyle: {
          color: '#738496'
        },
        label: {
          show: true,
          position: 'insideTop'
        }
      },{
        name: '流转中合同额（成功率等于80%）',
        type: 'bar',
        stack: '总量',
        data: convertRealAmount,
        barWidth: 20,
        itemStyle: {
          color: '#334B5C'
        },
        label: {
          show: false
        }
      }]
    };

    function drill_down_contract_detail(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const org_code = orgCodes[params.dataIndex];
          const month_name = $('#month_name').val();
          let url;
          url = '/report/predict_contract?view_deptcode_sum=true&org_code=' + org_code + '&month_name=' + encodeURIComponent(month_name);
          Turbolinks.visit(url);
        }
      }
    }

    groupPredictContractChart.setOption(option, false);
    groupPredictContractChart.on('click', drill_down_contract_detail);

    setTimeout(() => {
      groupPredictContractChart.resize();
    }, 200);
  }

  layout() {
    groupPredictContractChart.resize();
  }

  disconnect() {
    groupPredictContractChart.dispose();
  }
}
