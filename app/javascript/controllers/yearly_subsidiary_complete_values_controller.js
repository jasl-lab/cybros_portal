import { Controller } from "stimulus"

let yearlySubsidiaryCompleteValueChart;

export default class extends Controller {
  connect() {
    yearlySubsidiaryCompleteValueChart = echarts.init(document.getElementById('yearly-subsidiary-complete-value-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const selectedCompanyName = this.data.get("selected_company_name");
    const completeValueTotals = JSON.parse(this.data.get("complete_value_totals"));
    const completeValueRef = this.data.get("complete_value_ref");

    const option = {
        legend: {
            data: ['累计完成产值'],
            align: 'left'
        },
        grid: {
          left: 80,
          right: 110,
          top: 60,
          bottom: 125
        },
        toolbox: {
          feature: {
            dataView: {},
            saveAsImage: {
                pixelRatio: 2
            }
          }
        },
        tooltip: {},
        xAxis: {
          data: xAxisData,
          silent: true,
          axisLabel: {
            interval: 0,
            rotate: -40
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value}万'
          }
        },
        series: [{
          name: '累计完成产值',
          type: 'line',
          symbol: 'triangle',
          symbolSize: 10,
          data: completeValueTotals,
          itemStyle: {
            color: '#738496'
          },
          markLine: {
            label: {
              formatter: '{c} （万元）'
            },
            lineStyle: {
              type: 'solid',
              width: 1
            },
            data: [
              {
                yAxis: completeValueRef
              }
            ]
          }
        }]
    };

    yearlySubsidiaryCompleteValueChart.setOption(option, false);
    setTimeout(() => {
      yearlySubsidiaryCompleteValueChart.resize();
    }, 200);
  }

  layout() {
    yearlySubsidiaryCompleteValueChart.resize();
  }

  disconnect() {
    yearlySubsidiaryCompleteValueChart.dispose();
  }
}
