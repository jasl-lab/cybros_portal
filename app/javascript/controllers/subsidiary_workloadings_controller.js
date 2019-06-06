import { Controller } from "stimulus"

let subsidiaryWorkloadingsChart

export default class extends Controller {
  connect() {
    subsidiaryWorkloadingsChart = echarts.init(document.getElementById('subsidiary-workloadings-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var dayRateData = JSON.parse(this.data.get("day_rate"));
var dayRateDataRef = this.data.get("day_rate_ref");
var planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
var planningDayRateDataRef = this.data.get("planning_day_rate_ref");
var buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
var buildingDayRateDataRef = this.data.get("building_day_rate_ref");

var option = {
    legend: {
        data: ['工作填报率', '方案饱和度', '施工图饱和度'],
        align: 'left'
    },
    grid: {
      left: 55,
      right: 55,
      top: 60,
      bottom: 120
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
      min: 0,
      max: 100,
      axisLabel: {
        show: true,
        interval: 'auto',
        formatter: '{value} %'
      }
    },
    series: [{
      name: '工作填报率',
      type: 'bar',
      data: dayRateData,
      markLine: {
        label: {
          formatter: '{c}% 填报率及格线'
        },
        lineStyle: {
          type: 'solid',
          width: 1
        },
        data: [
          {
            yAxis: dayRateDataRef
          }
        ]
      }
    }, {
      name: '方案饱和度',
      type: 'bar',
      data: planningDayRateData,
      markLine: {
        label: {
          formatter: '{c}% 饱和度线'
        },
        lineStyle: {
          type: 'solid',
          width: 1
        },
        data: [
          {
            yAxis: planningDayRateDataRef
          }
        ]
      }
    }, {
      name: '施工图饱和度',
      type: 'bar',
      data: buildingDayRateData,
      markLine: {
        label: {
          formatter: '{c}% 饱和度线'
        },
        lineStyle: {
          type: 'solid',
          width: 1
        },
        data: [
          {
            yAxis: buildingDayRateDataRef
          }
        ]
      }
    }]
};

    subsidiaryWorkloadingsChart.setOption(option, false);
    setTimeout(() => {
      subsidiaryWorkloadingsChart.resize();
    }, 30)
  }

  layout() {
    subsidiaryWorkloadingsChart.resize();
  }

  disconnect() {
    subsidiaryWorkloadingsChart.dispose();
  }
}
