import { Controller } from "stimulus"

let companyDesignCashFlowChart;
let companyDesignRateFlowChart;
let subsidiaryDesignCashFlowChart;

export default class extends Controller {
  connect() {
    companyDesignCashFlowChart = echarts.init(document.getElementById('company-design-cash-flow-chart'));
    companyDesignRateFlowChart = echarts.init(document.getElementById('company-design-rate-flow-chart'));
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
      tooltip: {
        trigger: 'axis'
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
      series: {
        type: 'line',
        data: orgMoney,
        symbol: 'circle',
        symbolSize: 8,
        color: '#675BBA',
      }
    };

    const rate_options = {
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '70',
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
        boundaryGap: false,
        data: orgCheckdate,
        axisLabel: {
          formatter: '{value}月'
        },
      },
      yAxis: {
        type: 'value',
        name: '折算月份',
        position: 'right',
      },
      series: {
        type: 'bar',
        data: orgRateValid,
        barWidth: 20,
        color: '#7E91A5'
      }
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
    companyDesignRateFlowChart.setOption(rate_options, false);
    subsidiaryDesignCashFlowChart.setOption(subsidiary_options, false);

    setTimeout(() => {
      companyDesignCashFlowChart.resize();
      companyDesignRateFlowChart.resize();
      subsidiaryDesignCashFlowChart.resize();
    }, 200);
  }

  layout() {
    companyDesignCashFlowChart.resize();
    companyDesignRateFlowChart.resize();
    subsidiaryDesignCashFlowChart.resize();
  }

  disconnect() {
    companyDesignCashFlowChart.dispose();
    companyDesignRateFlowChart.dispose();
    subsidiaryDesignCashFlowChart.dispose();
  }
}
