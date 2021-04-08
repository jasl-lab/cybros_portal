import { Controller } from "stimulus"

let orgDesignCashFlowChart;

export default class extends Controller {
  connect() {
    orgDesignCashFlowChart = echarts.init(document.getElementById('org-design-cash-flow-chart'));

    const orgNames = JSON.parse(this.data.get("org_names"));
    const orgRate = JSON.parse(this.data.get("org_rate"));

    function rejectInvalidRate(v) {
      if (v == null) {
        return 0.01;
      } else {
        return v;
      }
    }

    const orgRateValid = orgRate.map(rejectInvalidRate);

    const company_options = {
      legend: {
          data: ['公司','折算月份'],
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
        boundaryGap: true,
        axisLabel: {
          interval: 0,
          rotate: -40
        },
        data: orgNames
      },
      yAxis: [{
          type: 'value',
          name: '折算月份',
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
          name: '折算月份',
          type: 'bar',
          data: orgRateValid,
          color: '#738496',
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        }]
    };

    orgDesignCashFlowChart.setOption(company_options, false);

    setTimeout(() => {
      orgDesignCashFlowChart.resize();
    }, 200);
  }

  layout() {
    orgDesignCashFlowChart.resize();
  }

  disconnect() {
    orgDesignCashFlowChart.dispose();
  }
}
