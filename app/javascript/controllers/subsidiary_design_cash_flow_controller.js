import { Controller } from "stimulus"

let subsidiaryDesignCashFlowChart;

export default class extends Controller {
  connect() {
    subsidiaryDesignCashFlowChart = echarts.init(document.getElementById('subsidiary-design-cash-flow-chart'));

    const chartData = JSON.parse(this.data.get("chart_data"));

    const options = {
      legend: {},
      tooltip: {
        trigger: 'axis',
        showContent: false
      },
      dataset: {
        source: chartData
      },
      xAxis: { type: 'category' },
      yAxis: { gridIndex: 0 },
      grid: { top: '35%' },
      series: [
        {type: 'line', smooth: true, seriesLayoutBy: 'row'},
        {type: 'line', smooth: true, seriesLayoutBy: 'row'},
        {type: 'line', smooth: true, seriesLayoutBy: 'row'},
        {type: 'line', smooth: true, seriesLayoutBy: 'row'},
        {
          type: 'pie',
          id: 'pie',
          radius: '22%',
          center: ['50%', '25%'],
          label: {
            formatter: '{b}: {@January 2020} ({d}%)'
          },
          encode: {
            itemName: 'cash_flow',
            value: 'January 2020',
            tooltip: 'January 2020'
          }
        }
      ]
    };
    function update_point(event) {
      let xAxisInfo = event.axesInfo[0];
      if (xAxisInfo) {
        let dimension = xAxisInfo.value + 1;
        subsidiaryDesignCashFlowChart.setOption({
          series: {
            id: 'pie',
            label: {
              formatter: '{b}: {@[' + dimension + ']} ({d}%)'
            },
            encode: {
              value: dimension,
              tooltip: dimension
            }
          }
        });
      }
    }
    subsidiaryDesignCashFlowChart.on('updateAxisPointer', update_point);
    subsidiaryDesignCashFlowChart.setOption(options, false);

    setTimeout(() => {
      subsidiaryDesignCashFlowChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryDesignCashFlowChart.resize();
  }

  disconnect() {
    subsidiaryDesignCashFlowChart.dispose();
  }
}
