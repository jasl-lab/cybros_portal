import { Controller } from "stimulus"

let companyDesignCashFlowChart;
let subsidiaryDesignCashFlowChart;

export default class extends Controller {
  connect() {
    companyDesignCashFlowChart = echarts.init(document.getElementById('company-design-cash-flow-chart'));
    subsidiaryDesignCashFlowChart = echarts.init(document.getElementById('subsidiary-design-cash-flow-chart'));

    const orgCheckdate = JSON.parse(this.data.get("org_checkdate"));
    const orgMoney = JSON.parse(this.data.get("org_endmoney"));
    const orgRate = JSON.parse(this.data.get("org_rate"));

    function rejectInvalidRate(v) {
      if (v < 0) {
        return 0;
      } else if (v > 20) {
        return 20;
      } else {
        return v;
      }
    }

    const orgRateValid = orgRate.map(rejectInvalidRate);

    const deptMoney = JSON.parse(this.data.get("dept_endmoney"));
    const deptShortNames = JSON.parse(this.data.get("dept_short_names"));

    function buildSeries(v, index) {
      return {
        name: deptShortNames[index],
        type: 'line',
        stack: '总量',
        data: v
      };
    }

    const seriesData = deptMoney.map(buildSeries);

    const company_options = {
      legend: {
          data: ['折算月份','现金流'],
          align: 'left'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'cross'
        }
      },
      grid: {
        left: '13',
        right: '3%',
        bottom: '3%',
        containLabel: true
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {}
        }
      },
      xAxis: {
        type: 'category',
        silent: true,
        boundaryGap: false,
        data: orgCheckdate,
        axisLabel: {
          formatter: '{value}月'
        },
      },
      yAxis: [{
          type: 'value',
          name: '万元',
          position: 'left',
          min: 0,
          max: 5000,
          interval: 1000,
          axisLabel: {
            formatter: '{value}万'
          }
        },{
          type: 'value',
          name: '折算月份',
          position: 'right',
          min: 0,
          max: 20,
          interval: 4,
          axisLine: {
            lineStyle: {
              color: '#675BBA'
            }
          },
          axisLabel: {
            formatter: '{value}月'
          }
        }],
      series: [{
          name: '现金流',
          type: 'line',
          symbol: 'circle',
          symbolSize: 8,
          data: orgMoney,
          color: '#675BBA',
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        },{
          name: '折算月份',
          type: 'bar',
          yAxisIndex: 1,
          data: orgRateValid,
          color: '#738496',
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        }]
    };

    const subsidiary_options = {
      tooltip: {
        trigger: 'axis'
      },
      legend: {
        data: deptShortNames
      },
      grid: {
        left: '3%',
        right: '3%',
        top: '130px',
        bottom: '0%',
        containLabel: true
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {}
        }
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: orgCheckdate,
        axisLabel: {
          formatter: '{value}月'
        },
      },
      yAxis: {
        type: 'value',
        name: '万元',
      },
      series: seriesData
    };

    companyDesignCashFlowChart.setOption(company_options, false);
    subsidiaryDesignCashFlowChart.setOption(subsidiary_options, false);

    setTimeout(() => {
      companyDesignCashFlowChart.resize();
      subsidiaryDesignCashFlowChart.resize();
    }, 200);
  }

  layout() {
    companyDesignCashFlowChart.resize();
    subsidiaryDesignCashFlowChart.resize();
  }

  disconnect() {
    companyDesignCashFlowChart.dispose();
    subsidiaryDesignCashFlowChart.dispose();
  }
}
