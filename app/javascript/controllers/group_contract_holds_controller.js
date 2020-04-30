import { Controller } from "stimulus"

let groupContractHoldChart;
let groupContractHoldPerDeptChart;

export default class extends Controller {
  connect() {
    groupContractHoldChart = echarts.init(document.getElementById('group-contract-hold-chart'));
    groupContractHoldPerDeptChart = echarts.init(document.getElementById('group-contract-hold-per-dept-chart'));

    var companyCodes = JSON.parse(this.data.get("company_codes"));
    var companyShortNames = JSON.parse(this.data.get("company_short_names"));
    const currentUserCompaniesShortNames = JSON.parse(this.data.get("current_user_companies_short_names"));
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
          data: companyShortNames,
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
          barWidth: 20,
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
          barWidth: 20,
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
          barWidth: 20,
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
        data: companyShortNames,
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
        barWidth: 20,
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
          const company_name = companyShortNames[params.dataIndex];
          const company_code = companyCodes[params.dataIndex];
          const month_name = $('#month_name').val();
          const view_deptcode_sum = $('#view_deptcode_sum').val();
          let url;
          url = '/report/contract_hold?view_deptcode_sum=true&org_code=' + company_code;
          if (currentUserCompaniesShortNames.indexOf(company_name) > -1 || currentUserCompaniesShortNames.indexOf('上海天华') > -1) {
            window.location.href = url;
          }
        }
      }
    }
    groupContractHoldChart.setOption(option, false);
    groupContractHoldChart.on('click', drill_down_contract_hold_detail);
    groupContractHoldPerDeptChart.setOption(dept_option, false);

    setTimeout(() => {
      groupContractHoldChart.resize();
      groupContractHoldPerDeptChart.resize();
    }, 200);
  }

  layout() {
    groupContractHoldChart.resize();
    groupContractHoldPerDeptChart.resize();
  }

  disconnect() {
    groupContractHoldChart.dispose();
    groupContractHoldPerDeptChart.dispose();
  }
}
