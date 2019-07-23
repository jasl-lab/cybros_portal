import { Controller } from "stimulus"

let projectMilestoreChart;

export default class extends Controller {
  connect() {
    projectMilestoreChart = echarts.init(document.getElementById('project-milestore-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var milestoreUpdateRate = JSON.parse(this.data.get("milestore_update_rate"));

var option = {
    legend: {
        data: ['项目里程碑更新率'],
        align: 'left'
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      }
    },
    grid: {
      left: 50,
      right: 50,
      top: 50,
      bottom: 80
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
    yAxis: [{
      type: 'value',
      name: '项目里程碑更新率',
      axisLabel: {
        formatter: '{value}%'
      }
    }],
    series: [{
      name: '项目里程碑更新率',
      type: 'line',
      data: milestoreUpdateRate,
      color: '#738496',
      label: {
        normal: {
          show: true,
          position: 'top',
          formatter: '{c}%'
        }
      }
    }]
};

    projectMilestoreChart.setOption(option, false);
    setTimeout(() => {
      projectMilestoreChart.resize();
    }, 200);
  }

  layout() {
    projectMilestoreChart.resize();
  }

  disconnect() {
    projectMilestoreChart.dispose();
  }
}
