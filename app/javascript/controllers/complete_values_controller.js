import { Controller } from "stimulus"

let completeValuesTotalChart;
let completeValuesStaffChart;

export default class extends Controller {
  connect() {
    completeValuesTotalChart = echarts.init(document.getElementById('complete-values-total-chart'));
    completeValuesStaffChart = echarts.init(document.getElementById('complete-values-staff-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const inIFrame = this.data.get("in_iframe");
    const sumOrgNames = JSON.parse(this.data.get("sum_org_names"));
    const completeValueTotals = JSON.parse(this.data.get("complete_value_totals"));
    const completeValueYearTotals = JSON.parse(this.data.get("complete_value_year_totals"));
    const completeValueYearTotalsRemain = JSON.parse(this.data.get("complete_value_year_totals_remain"));
    const completeValueTotalsPerStaff = JSON.parse(this.data.get("complete_value_totals_per_staff"));
    const completeValueGapPerStaff = JSON.parse(this.data.get("complete_value_gap_per_staff"));
    const completeValueYearTotalsPerStaff = JSON.parse(this.data.get("complete_value_year_totals_per_staff"));

    const option_total = {
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
          barWidth: 20,
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
          barWidth: 20,
          itemStyle: {
            color: '#DDDDDD'
          }
        }]
    };

    const option_staff = {
        legend: {
            data: ['预计全年人均完成产值（万元）','本年累计人均完成产值（万元）'],
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
          name: '预计全年人均完成产值（万元）',
          type: 'bar',
          barWidth: '30%',
          barGap: '-100%',
          data: completeValueYearTotalsPerStaff,
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
        },{
          name: '本年累计人均完成产值（万元）',
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
              position: 'insideTop',
              fontWeight: 'bold',
              color: '#000000'
            }
          }
        },{
          name: '预计人均将完成产值（万元）',
          type: 'bar',
          stack: '人均',
          data: completeValueGapPerStaff,
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

    function drill_down_complete_value_total(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          let series_company = xAxisData[params.dataIndex]
          let url;
          if(sumOrgNames.indexOf(series_company) > -1) {
            url = window.location.href;
          } else {
            url = "/report/subsidiary_complete_value";
          }

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(series_company);
          } else {
            url += '?company_name=' + encodeURIComponent(series_company);
          }

          if (inIFrame != "true") {
            window.location.href = url;
          }
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
