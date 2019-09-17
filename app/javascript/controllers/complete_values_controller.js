import { Controller } from "stimulus"

let completeValuesTotalChart;
let completeValuesStaffChart;

export default class extends Controller {
  connect() {
    completeValuesTotalChart = echarts.init(document.getElementById('complete-values-total-chart'));
    completeValuesStaffChart = echarts.init(document.getElementById('complete-values-staff-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var completeValueTotals = JSON.parse(this.data.get("complete_value_totals"));
var completeValueYearTotals = JSON.parse(this.data.get("complete_value_year_totals"));
var completeValueYearTotalsRemain = JSON.parse(this.data.get("complete_value_year_totals_remain"));
var completeValueTotalsPerStaff = JSON.parse(this.data.get("complete_value_totals_per_staff"));
var completeValueYearTotalsPerStaff = JSON.parse(this.data.get("complete_value_year_totals_per_staff"));

var option_total = {
    legend: {
        data: ['本年累计完成产值（百万元）','预计全年完成产值（百万元）'],
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
      name: '累计完成产值（百万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}百万'
      }
    }],
    series: [{
      name: '预计全年完成产值（百万元）',
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
          position: 'top',
          fontWeight: 'bold',
          fontSize: 15,
          color: '#000000'
        }
      }
    },{
      name: '本年累计完成产值（百万元）',
      type: 'bar',
      stack: '总量',
      data: completeValueTotals,
      itemStyle: {
        color: '#738496'
      },
      label: {
        normal: {
          show: true,
          position: 'inside'
        }
      }
    },{
      name: '全年剩余需完成产值（百万元）',
      type: 'bar',
      stack: '总量',
      data: completeValueYearTotalsRemain,
      barWidth: 26,
      itemStyle: {
        color: '#DDDDDD'
      },
      label: {
        normal: {
          show: true,
          position: 'inside',
          color: '#353535'
        }
      }
    }]
};

var option_staff = {
    legend: {
        data: ['本年累计人均完成产值（万元）','预计全年人均完成产值（万元）'],
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
      offset: 16,
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
      name: '人均完成产值（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '本年累计人均完成产值（万元）',
      type: 'bar',
      stack: '人均',
      data: completeValueTotalsPerStaff,
      itemStyle: {
        color: '#60A0A8'
      },
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '预计全年人均完成产值（万元）',
      type: 'bar',
      stack: '人均',
      data: completeValueYearTotalsPerStaff,
      itemStyle: {
        color: '#DDDDDD'
      },
      barWidth: 26,
      label: {
        normal: {
          show: true,
          position: 'top',
          fontWeight: 'bold',
          color: '#000000'
        }
      }
    }]
};

    function drill_down_complete_value_total(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const department_name = xAxisData[params.dataIndex];
          let url = "/report/subsidiary_complete_value";
          let series_company = xAxisData[params.dataIndex]
          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(series_company);
          } else {
            url += '?company_name=' + encodeURIComponent(series_company);
          }
          window.location.href = url;
        }
      }
    }
    completeValuesTotalChart.setOption(option_total, false);
    completeValuesTotalChart.on('click', drill_down_complete_value_total);
    completeValuesStaffChart.setOption(option_staff, false);
    setTimeout(() => {
      completeValuesTotalChart.resize();
      completeValuesStaffChart.resize();
    }, 200);
  }

  layout() {
    completeValuesTotalChart.resize();
    completeValuesStaffChart.resize();
  }

  disconnect() {
    completeValuesTotalChart.dispose();
    completeValuesStaffChart.dispose();
  }
}
