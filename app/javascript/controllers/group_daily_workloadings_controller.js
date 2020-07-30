import { Controller } from "stimulus"

let groupDailyWorkloadingsDayChart;
let groupDailyWorkloadingsPlanningDayChart;
let groupDailyWorkloadingsBuildingDayChart;
let groupDailyWorkloadingsNonConstructionDayChart;

export default class extends Controller {
  connect() {
    groupDailyWorkloadingsDayChart = echarts.init(document.getElementById('group-daily-workloadings-day-chart'));
    groupDailyWorkloadingsPlanningDayChart = echarts.init(document.getElementById('group-daily-workloadings-planning-day-chart'));
    groupDailyWorkloadingsBuildingDayChart = echarts.init(document.getElementById('group-daily-workloadings-building-day-chart'));
    groupDailyWorkloadingsNonConstructionDayChart = echarts.init(document.getElementById('group-daily-workloadings-non-construction-day-chart'));

    const beginDate = this.data.get("begin_date");
    const endDate = this.data.get("end_date");
    const xAxisJob = JSON.parse(this.data.get("x_axis_job"));
    const xAxisBluePrint = JSON.parse(this.data.get("x_axis_blue_print"));
    const xAxisConstruction = JSON.parse(this.data.get("x_axis_construction"));
    const xAxisNonConstruction = JSON.parse(this.data.get("x_axis_non_construction"));
    const currentUserCompaniesShortNames = JSON.parse(this.data.get("current_user_companies_short_names"));
    const dayRateData = JSON.parse(this.data.get("day_rate"));
    const dayRateDataRef = this.data.get("day_rate_ref");
    const planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
    const planningDayRateDataRef = this.data.get("planning_day_rate_ref");
    const buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
    const buildingDayRateDataRef = this.data.get("building_day_rate_ref");
    const nonConstructionDayRateData = JSON.parse(this.data.get("non_construction_day_rate"));

    const day_option = {
        title: {
          text: '工作填报率'
        },
        grid: {
          left: 50,
          right: 110,
          top: 60,
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
        tooltip: {},
        xAxis: {
          data: xAxisJob,
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
            interval: 'auto',
            formatter: '{value} %'
          }
        },
        series: [{
          name: '工作填报率',
          type: 'line',
          symbol: 'triangle',
          symbolSize: function(val, params) {
            if (val < dayRateDataRef) {
              return 8;
            } else {
              return 16;
            }
          },
          data: dayRateData,
          itemStyle: {
            color: '#738496'
          },
          label: {
            normal: {
              show: true,
              position: 'top',
              formatter: '{c}%'
            }
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

    const planning_day_option = {
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
          data: xAxisBluePrint,
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
            interval: 'auto',
            formatter: '{value} %'
          }
        },
        series: [{
          name: '方案饱和度',
          type: 'line',
          symbol: 'circle',
          symbolSize: function(val, params) {
            if (val < planningDayRateDataRef) {
              return 8;
            } else {
              return 16;
            }
          },
          data: planningDayRateData,
          itemStyle: {
            color: '#334B5C'
          },
          label: {
            normal: {
              show: true,
              position: 'top',
              formatter: '{c}%'
            }
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

    const building_day_option = {
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
          data: xAxisConstruction,
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
            interval: 'auto',
            formatter: '{value} %'
          }
        },
        series: [{
          name: '施工图饱和度',
          type: 'line',
          symbol: 'square',
          symbolSize:  function(val, params) {
            if (val < buildingDayRateDataRef) {
              return 8;
            } else {
              return 16;
            }
          },
          data: buildingDayRateData,
          itemStyle: {
            color: '#6AB0B8'
          },
          label: {
            normal: {
              show: true,
              position: 'top',
              formatter: '{c}%'
            }
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

    const non_construction_option = {
        title: {
          text: '非建筑类工作填报率'
        },
        grid: {
          left: 50,
          right: 110,
          top: 60,
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
        tooltip: {},
        xAxis: {
          data: xAxisNonConstruction,
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
            interval: 'auto',
            formatter: '{value} %'
          }
        },
        series: [{
          name: '工作填报率',
          type: 'line',
          symbol: 'triangle',
          data: nonConstructionDayRateData,
          itemStyle: {
            color: '#738496'
          },
          label: {
            normal: {
              show: true,
              position: 'top',
              formatter: '{c}%'
            }
          }
        }]
    };

    function drill_down_subsidiary(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'line') {
          let company_name;
          switch (params.seriesName) {
            case '工作填报率':
              company_name = xAxisJob[params.dataIndex]
              break;
            case '方案饱和度':
              company_name = xAxisBluePrint[params.dataIndex]
              break;
            case '施工图饱和度':
              company_name = xAxisConstruction[params.dataIndex]
              break;
          }

          let url = '/report/subsidiary_daily_workloading';

          url += '?company_name=' + encodeURIComponent(company_name) + '&begin_date=' + beginDate + '&end_date='+ endDate + '&view_deptcode_sum=true';

          if (currentUserCompaniesShortNames.indexOf(company_name) > -1 || currentUserCompaniesShortNames.indexOf('上海天华') > -1) {
            Turbolinks.visit(url);
          }
        }
      }
    }

    groupDailyWorkloadingsDayChart.setOption(day_option, false);
    groupDailyWorkloadingsDayChart.on('click', drill_down_subsidiary);
    groupDailyWorkloadingsPlanningDayChart.setOption(planning_day_option, false);
    groupDailyWorkloadingsPlanningDayChart.on('click', drill_down_subsidiary);
    groupDailyWorkloadingsBuildingDayChart.setOption(building_day_option, false);
    groupDailyWorkloadingsBuildingDayChart.on('click', drill_down_subsidiary);
    groupDailyWorkloadingsNonConstructionDayChart.setOption(non_construction_option, false);
    groupDailyWorkloadingsNonConstructionDayChart.on('click', drill_down_subsidiary);
    setTimeout(() => {
      groupDailyWorkloadingsDayChart.resize();
      groupDailyWorkloadingsPlanningDayChart.resize();
      groupDailyWorkloadingsBuildingDayChart.resize();
      groupDailyWorkloadingsNonConstructionDayChart.resize();
    }, 200);
  }

  layout() {
    groupDailyWorkloadingsDayChart.resize();
    groupDailyWorkloadingsPlanningDayChart.resize();
    groupDailyWorkloadingsBuildingDayChart.resize();
    groupDailyWorkloadingsNonConstructionDayChart.resize();
  }

  disconnect() {
    groupDailyWorkloadingsDayChart.dispose();
    groupDailyWorkloadingsPlanningDayChart.dispose();
    groupDailyWorkloadingsBuildingDayChart.dispose();
    groupDailyWorkloadingsNonConstructionDayChart.dispose();
  }
}
