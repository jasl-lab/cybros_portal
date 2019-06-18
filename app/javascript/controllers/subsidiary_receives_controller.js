import { Controller } from "stimulus"

let subsidiaryRealReceivesChart;

export default class extends Controller {
  connect() {
    subsidiaryRealReceivesChart = echarts.init(document.getElementById('subsidiary-real-receives-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var realReceives = JSON.parse(this.data.get("real_receives"));
var staffRealReceiveRef = this.data.get("staff_real_receive_ref");

var option = {
    legend: {
        data: ['本年累积实收款（万元）'],
        align: 'left'
    },
    grid: {
      left: 50,
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
        interval: 'auto'
      }
    },
    series: [{
      name: '本年累积实收款（万元）',
      type: 'bar',
      data: realReceives,
      color: '#738496',
      label: {
        normal: {
          show: true,
          position: 'top',
          color: '#171717'
        }
      }
    }]
};

    subsidiaryRealReceivesChart.setOption(option, false);
    setTimeout(() => {
      subsidiaryRealReceivesChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryRealReceivesChart.resize();
  }

  disconnect() {
    subsidiaryRealReceivesChart.dispose();
  }
}
