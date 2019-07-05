import { Controller } from "stimulus"

let subsidiaryCompleteValuesChart;

export default class extends Controller {
  connect() {
    subsidiaryCompleteValuesChart = echarts.init(document.getElementById('subsidiary-complete-values-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var completeValueTotals = JSON.parse(this.data.get("complete_value_totals"));
var completeValueYearTotals = JSON.parse(this.data.get("complete_value_year_totals"));
var completeValueYearRemains = JSON.parse(this.data.get("complete_value_year_remains"));

var option = {
    legend: {
        data: ['累积完成产值（万元）','预计将完成产值（万元）'],
        align: 'left'
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      }
    },
    grid: {
      left: 70,
      right: 110,
      top: 50,
      bottom: 90
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
        rotate: -40,
        margin: 24
      },
      splitLine: {
          show: false
      }
    },
    yAxis: [{
      type: 'value',
      name: '累积完成产值（万元）',
      position: 'left',
      min: 0,
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '预计全年完成产值（万元）',
      type: 'bar',
      barWidth: '30%',
      barGap: '-100%',
      data: completeValueYearTotals,
      itemStyle: {
        color: '#DDDDDD'
      },
      label: {
        normal: {
          show: true,
          color: '#353535',
          position: 'top'
        }
      }
      }, {
      name: '累积完成产值',
      type: 'bar',
      stack: '总量',
      data: completeValueTotals,
      itemStyle: {
        color: '#738496'
      },
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '预计将完成产值',
      type: 'bar',
      stack: '总量',
      data: completeValueYearRemains,
      barMaxWidth: 90,
      itemStyle: {
        color: '#DDDDDD'
      },
      label: {
        normal: {
          show: false
        }
      }
    }]
};

    subsidiaryCompleteValuesChart.setOption(option, false);
    setTimeout(() => {
      subsidiaryCompleteValuesChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryCompleteValuesChart.resize();
  }

  disconnect() {
    subsidiaryCompleteValuesChart.dispose();
  }
}
