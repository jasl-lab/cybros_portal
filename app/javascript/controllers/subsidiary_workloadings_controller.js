import { Controller } from "stimulus"

let subsidiaryWorkloadingsChart1
let subsidiaryWorkloadingsChart2
let subsidiaryWorkloadingsChart3

export default class extends Controller {
  connect() {
    subsidiaryWorkloadingsChart1 = echarts.init(document.getElementById('subsidiary-workloadings-chart1'));
    subsidiaryWorkloadingsChart2 = echarts.init(document.getElementById('subsidiary-workloadings-chart2'));
    subsidiaryWorkloadingsChart3 = echarts.init(document.getElementById('subsidiary-workloadings-chart3'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var dayRateData = JSON.parse(this.data.get("day_rate"));
var dayRateDataRef = this.data.get("day_rate_ref");
var planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
var planningDayRateDataRef = this.data.get("planning_day_rate_ref");
var buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
var buildingDayRateDataRef = this.data.get("building_day_rate_ref");

var option1 = {
    title: {
      text: '工作填报率'
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
      itemStyle: {
        color: '#C23631'
      },
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
    }]
};

var option2 = {
    title: {
      text: '方案饱和度'
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
      min: 0,
      max: 100,
      axisLabel: {
        show: true,
        interval: 'auto',
        formatter: '{value} %'
      }
    },
    series: [{
      name: '方案饱和度',
      type: 'bar',
      data: planningDayRateData,
      itemStyle: {
        color: '#334B5C'
      },
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
    }]
};

var option3 = {
    title: {
      text: '施工图饱和度'
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
      min: 0,
      max: 100,
      axisLabel: {
        show: true,
        interval: 'auto',
        formatter: '{value} %'
      }
    },
    series: [{
      name: '施工图饱和度',
      type: 'bar',
      data: buildingDayRateData,
      itemStyle: {
        color: '#6AB0B8'
      },
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

    subsidiaryWorkloadingsChart1.setOption(option1, false);
    subsidiaryWorkloadingsChart2.setOption(option2, false);
    subsidiaryWorkloadingsChart3.setOption(option3, false);
    setTimeout(() => {
      subsidiaryWorkloadingsChart1.resize();
      subsidiaryWorkloadingsChart2.resize();
      subsidiaryWorkloadingsChart3.resize();
    }, 200);
  }

  layout() {
    subsidiaryWorkloadingsChart1.resize();
    subsidiaryWorkloadingsChart2.resize();
    subsidiaryWorkloadingsChart3.resize();
  }

  disconnect() {
    subsidiaryWorkloadingsChart1.dispose();
    subsidiaryWorkloadingsChart2.dispose();
    subsidiaryWorkloadingsChart3.dispose();
  }
}
