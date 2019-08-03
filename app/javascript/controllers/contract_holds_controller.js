import { Controller } from "stimulus"

let contractHoldChart;
let contractHoldPerDeptChart;

export default class extends Controller {
  connect() {
    contractHoldChart = echarts.init(document.getElementById('contract-hold-chart'));
    contractHoldPerDeptChart = echarts.init(document.getElementById('contract-hold-per-dept-chart'));

    var xAxisData = JSON.parse(this.data.get("x_axis"));
    var bizRetentContract = JSON.parse(this.data.get("biz_retent_contract"));
    var bizRetentNoContract = JSON.parse(this.data.get("biz_retent_no_contract"));
    var bizRetentTotals = JSON.parse(this.data.get("biz_retent_totals"));

    var bizRetentTotalsPerDept = JSON.parse(this.data.get("biz_retent_totals_per_dept"));

    var option = {
        legend: {
            data: ['业务保有量合计（万元）','已签约的业务保有量（万元）','未签约的业务保有量（万元）'],
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
          name: '业务保有量（万元）',
          position: 'left',
          min: 0,
          axisLabel: {
            formatter: '{value}万'
          }
        }],
        series: [{
          name: '业务保有量合计（万元）',
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
          name: '已签约的业务保有量（万元）',
          type: 'bar',
          stack: '总量',
          data: bizRetentContract,
          itemStyle: {
            color: '#334B5C'
          },
          label: {
            normal: {
              show: true,
              position: 'insideTop'
            }
          }
        },{
          name: '未签约的业务保有量（万元）',
          type: 'bar',
          stack: '总量',
          data: bizRetentNoContract,
          itemStyle: {
            color: '#738496'
          },
          barMaxWidth: 90,
          label: {
            normal: {
              show: false
            }
          }
        }]
    };

    var dept_option = {
      legend: {
        data: ['人均业务保有量（万元）'],
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
        name: '人均业务保有量（万元）',
        position: 'left',
        min: 0,
        axisLabel: {
          formatter: '{value}万'
        }
      }],
      series: [{
        name: '人均业务保有量（万元）',
        type: 'bar',
        data: bizRetentTotalsPerDept,
        itemStyle: {
          color: '#334B5C'
        },
        label: {
          normal: {
            show: true,
            color: '#353535',
            position: 'top'
          }
        }
      }]
    };

    function drill_down_contract_hold_detail(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const department_name = xAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          const sent_data = { department_name, month_name };
          let drill_down_url
          switch (params.seriesName) {
            case '已签约的业务保有量（万元）':
              drill_down_url = '/report/contract_hold/sign_detail_drill_down';
              break;
            case '未签约的业务保有量（万元）':
              drill_down_url = '/report/contract_hold/unsign_detail_drill_down';
              break;
          }
          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        }
      }
    }
    contractHoldChart.setOption(option, false);
    contractHoldChart.on('click', drill_down_contract_hold_detail);
    contractHoldPerDeptChart.setOption(dept_option, false);

    setTimeout(() => {
      contractHoldChart.resize();
      contractHoldPerDeptChart.resize();
    }, 200);
  }

  layout() {
    contractHoldChart.resize();
    contractHoldPerDeptChart.resize();
  }

  disconnect() {
    contractHoldChart.dispose();
    contractHoldPerDeptChart.dispose();
  }
}
