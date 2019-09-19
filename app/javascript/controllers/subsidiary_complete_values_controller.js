import { Controller } from "stimulus"

let subsidiaryCompleteValuesChart;
let subsidiaryCompleteValuesPerStaffChart;

export default class extends Controller {
  connect() {
    subsidiaryCompleteValuesChart = echarts.init(document.getElementById('subsidiary-complete-values-chart'));
    subsidiaryCompleteValuesPerStaffChart = echarts.init(document.getElementById('subsidiary-complete-values-per-staff-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var selectedCompanyName = this.data.get("selected_company_name");
var completeValueTotals = JSON.parse(this.data.get("complete_value_totals"));
var completeValueYearTotals = JSON.parse(this.data.get("complete_value_year_totals"));
var completeValueYearRemains = JSON.parse(this.data.get("complete_value_year_remains"));
var completeValueTotalsPerStaff = JSON.parse(this.data.get("complete_value_totals_per_staff"));
var completeValueYearTotalsPerStaff = JSON.parse(this.data.get("complete_value_year_totals_per_staff"));

var option_total = {
    legend: {
        data: ['预计全年完成产值（万元）','累计完成产值（万元）','预计将完成产值（万元）'],
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
      name: '累计完成产值（万元）',
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
      barWidth: 20,
      label: {
        normal: {
          show: true,
          color: '#353535',
          position: 'top'
        }
      }
      }, {
      name: '累计完成产值（万元）',
      type: 'bar',
      stack: '总量',
      data: completeValueTotals,
      itemStyle: {
        color: '#738496'
      },
      barWidth: 20,
      label: {
        normal: {
          show: true,
          position: 'insideTop'
        }
      }
    },{
      name: '预计将完成产值（万元）',
      type: 'bar',
      stack: '总量',
      data: completeValueYearRemains,
      barMaxWidth: 90,
      itemStyle: {
        color: '#DDDDDD'
      },
      barWidth: 20,
      label: {
        normal: {
          show: false
        }
      }
    }]
};

var option_staff = {
    legend: {
        data: ['人均完成产值（万元）','预计全年人均完成产值（万元）'],
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
      name: '人均完成产值（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '人均完成产值（万元）',
      type: 'bar',
      stack: '人均',
      data: completeValueTotalsPerStaff,
      itemStyle: {
        color: '#60A0A8'
      },
      barWidth: 20,
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
      barWidth: 20,
      label: {
        normal: {
          show: true,
          position: 'top',
          color: '#353535'
        }
      }
    }]
};


    function drill_down_subsidiary_complete_values_detail(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const department_name = xAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          const sent_data = { department_name, month_name, company_name: selectedCompanyName };
          let drill_down_url;
          switch (params.seriesName) {
            case '累计完成产值（万元）':
              drill_down_url = '/report/subsidiary_complete_value/drill_down';
              break;
          }

          if (drill_down_url !== undefined) {
            $.ajax(drill_down_url, {
              data: sent_data,
              dataType: 'script'
            });
          }
        }
      }
    }

    subsidiaryCompleteValuesChart.setOption(option_total, false);
    subsidiaryCompleteValuesChart.on('click', drill_down_subsidiary_complete_values_detail);
    subsidiaryCompleteValuesPerStaffChart.setOption(option_staff, false);
    setTimeout(() => {
      subsidiaryCompleteValuesChart.resize();
      subsidiaryCompleteValuesPerStaffChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryCompleteValuesChart.resize();
    subsidiaryCompleteValuesPerStaffChart.resize();
  }

  disconnect() {
    subsidiaryCompleteValuesChart.dispose();
    subsidiaryCompleteValuesPerStaffChart.dispose();
  }
}
