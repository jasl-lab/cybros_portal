import { Controller } from "stimulus"

let companyDesignCashFlowChart;
let subsidiaryDesignCashFlowChart;

export default class extends Controller {
  connect() {
    companyDesignCashFlowChart = echarts.init(document.getElementById('company-design-cash-flow-chart'));
    subsidiaryDesignCashFlowChart = echarts.init(document.getElementById('subsidiary-design-cash-flow-chart'));

    const orgCheckdate = JSON.parse(this.data.get("org_checkdate"));
    const orgOpeningMoney = JSON.parse(this.data.get("org_openingmoney"));
    const deptOpeningMoney = JSON.parse(this.data.get("dept_openingmoney"));
    const deptShortNames = JSON.parse(this.data.get("dept_short_names"));

    function buildSeries(v, index) {
      return {
        name: deptShortNames[index],
        type: 'line',
        stack: '总量',
        data: v
      };
    }

    const seriesData = deptOpeningMoney.map(buildSeries);

    const company_options = {
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '3%',
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
        data: orgOpeningMoney
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
