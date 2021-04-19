import { Controller } from "stimulus"

let crmYearReportChart;

export default class extends Controller {
  connect() {
    crmYearReportChart = echarts.init(document.getElementById('crm-year-report-chart'));

    const xAxis = JSON.parse(this.data.get("x_axis"));
    const top20s = JSON.parse(this.data.get("top20s"));
    const top20to50 = JSON.parse(this.data.get("top20to50s"));
    const gt50s = JSON.parse(this.data.get("gt50s"));
    const others = JSON.parse(this.data.get("others"));

    const option = {
      legend: {
        data: ['TOP 20 房企','TOP 20-50 房企','非 TOP 50 大客户','其他'],
        align: 'left'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'cross'
        }
      },
      grid: {
        left: 65,
        right: 0,
        top: 50,
        bottom: 60
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
        data: xAxis,
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
        position: 'left',
        axisLabel: {
          formatter: '{value}百万'
        }
      }],
      series: [{
        name: 'TOP 20 房企',
        type: 'bar',
        stack: '生产合同额',
        data: top20s,
        itemStyle: {
          color: '#4F81BE'
        },
        label: {
          normal: {
            show: true,
            position: 'inside'
          }
        }
      },{
        name: 'TOP 20-50 房企',
        type: 'bar',
        stack: '生产合同额',
        data: top20to50,
        itemStyle: {
          color: '#8FB4E3'
        },
        label: {
          normal: {
            show: true,
            position: 'inside'
          }
        }
      },{
        name: '非 TOP 50 大客户',
        type: 'bar',
        stack: '生产合同额',
        data: gt50s,
        itemStyle: {
          color: '#94CCDD'
        }
      },{
        name: '其他',
        type: 'bar',
        stack: '生产合同额',
        data: others,
        itemStyle: {
          color: '#94CCDD'
        },
        label: {
          normal: {
            show: true,
            position: 'inside'
          }
        }
      }]
    };

    crmYearReportChart.setOption(option, false);

    setTimeout(() => {
      crmYearReportChart.resize();
    }, 200);
  }

  layout() {
    crmYearReportChart.resize();
  }

  disconnect() {
    crmYearReportChart.dispose();
  }
}
