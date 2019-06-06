import { Controller } from "stimulus"

let demoChart

export default class extends Controller {
  connect() {
    demoChart = echarts.init(document.getElementById('demo-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var dayRateData = JSON.parse(this.data.get("day_rate"));
var planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
var buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));

var option = {
    legend: {
        data: ['工作填报率', '方案饱和度', '施工图饱和度'],
        align: 'left'
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
        silent: false,
        splitLine: {
            show: false
        }
    },
    yAxis: {
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

    demoChart.setOption(option);
    setInterval(() => {
      demoChart.resize()
    }, 30)
  }

  layout() {
    demoChart.resize()
  }
}
