import { Controller } from "stimulus"

let demoChart

export default class extends Controller {
  connect() {
    demoChart = echarts.init(document.getElementById('demo-chart'), null, {renderer: 'svg'});

var xAxisData = JSON.parse(this.data.get("x_axis"));
var dayRateData = JSON.parse(this.data.get("day_rate"));
var planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
var buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));

var option = {
    legend: {
        data: ['工作填报率', '方案饱和度', '施工图饱和度'],
        align: 'left'
    },
    grid: {
      bottom: 120
    },
    toolbox: {
        // y: 'bottom',
        feature: {
            magicType: {
                type: ['stack', 'tiled']
            },
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
        data: dayRateData
    }, {
        name: '方案饱和度',
        type: 'bar',
        data: planningDayRateData
    }, {
        name: '施工图饱和度',
        type: 'bar',
        data: buildingDayRateData
    }]
};

    demoChart.setOption(option, false);
    setInterval(() => {
      demoChart.resize()
    }, 30)
  }

  layout() {
    demoChart.resize()
  }
}
