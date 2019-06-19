import { Controller } from "stimulus"

let subsidiaryRealReceivesChart;
let subsidiaryNeedReceivesChart;

export default class extends Controller {
  connect() {
    subsidiaryRealReceivesChart = echarts.init(document.getElementById('subsidiary-real-receives-chart'));

var realXAxisData = JSON.parse(this.data.get("real_x_axis"));
var realReceives = JSON.parse(this.data.get("real_receives"));
var staffRealReceiveRef = this.data.get("staff_real_receive_ref");

    subsidiaryNeedReceivesChart = echarts.init(document.getElementById('subsidiary-need-receives-chart'));

var needXAxisData = JSON.parse(this.data.get("need_x_axis"));
var needLongAccountReceives = JSON.parse(this.data.get("need_long_account_receives"));
var needShortAccountReceives = JSON.parse(this.data.get("need_short_account_receives"));
var needShouldReceives = JSON.parse(this.data.get("need_should_receives"));

var real_option = {
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
      data: realXAxisData,
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

var need_option = {
    legend: {
        data: ['超长帐龄','扣除超长帐龄以外的财务应收','业务应收款'],
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
      data: needXAxisData,
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
      name: '应收款（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '超长帐龄',
      type: 'bar',
      stack: '应收',
      data: needLongAccountReceives,
      itemStyle: {
        color: '#FA9291'
      },
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '扣除超长帐龄以外的财务应收',
      type: 'bar',
      stack: '应收',
      data: needShortAccountReceives,
      itemStyle: {
        color: '#A1D189'
      },
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '业务应收款',
      type: 'bar',
      stack: '应收',
      data: needShouldReceives,
      itemStyle: {
        color: '#738496'
      },
      label: {
        normal: {
          show: true,
          position: 'top'
        }
      }
    }]
};

    subsidiaryRealReceivesChart.setOption(real_option, false);
    subsidiaryNeedReceivesChart.setOption(need_option, false);
    setTimeout(() => {
      subsidiaryRealReceivesChart.resize();
      subsidiaryNeedReceivesChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryRealReceivesChart.resize();
    subsidiaryNeedReceivesChart.resize();
  }

  disconnect() {
    subsidiaryRealReceivesChart.dispose();
    subsidiaryNeedReceivesChart.dispose();
  }
}
