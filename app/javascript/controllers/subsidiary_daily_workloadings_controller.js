import { Controller } from "stimulus"

let subsidiaryWorkloadingsJobDayChart;
let subsidiaryWorkloadingsPlanningDayChart;
let subsidiaryWorkloadingsBuildingDayChart;
let isNonConstruction;

export default class extends Controller {
  connect() {
    isNonConstruction = this.data.get("is_non_construction") == 'true';
    subsidiaryWorkloadingsJobDayChart = echarts.init(document.getElementById('subsidiary-workloadings-job-day-chart'));

    if (!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart = echarts.init(document.getElementById('subsidiary-workloadings-planning-day-chart'));
      subsidiaryWorkloadingsBuildingDayChart = echarts.init(document.getElementById('subsidiary-workloadings-building-day-chart'));
    }

    const xAxisJobCode = JSON.parse(this.data.get("x_axis_job_code"));
    const xAxisJob = JSON.parse(this.data.get("x_axis_job"));
    const xAxisBluePrintCode = JSON.parse(this.data.get("x_axis_blue_print_code"));
    const xAxisBluePrint = JSON.parse(this.data.get("x_axis_blue_print"));
    const xAxisConstructionCode = JSON.parse(this.data.get("x_axis_construction_code"));
    const xAxisConstruction = JSON.parse(this.data.get("x_axis_construction"));
    const view_deptcode_sum = this.data.get("view_deptcode_sum") == "true";
    const companyCode = this.data.get("company_code");
    const dayRateData = JSON.parse(this.data.get("day_rate"));
    const planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
    const buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));

    const option1 = {
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
          symbolSize: 10,
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
          }
        }]
    };

    const option2 = {
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
          symbolSize: 10,
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
          }
        }]
    };

    const option3 = {
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
          symbolSize:  10,
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
          }
        }]
    };

    function drill_down_model_show(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'line') {
          let department_code;
          switch (params.seriesName) {
            case '工作填报率':
              department_code = xAxisJobCode[params.dataIndex]
              break;
            case '方案饱和度':
              department_code = xAxisBluePrintCode[params.dataIndex]
              break;
            case '施工图饱和度':
              department_code = xAxisConstructionCode[params.dataIndex]
              break;
          }
          const begin_date = $('#begin_date').val();
          const end_date = $('#end_date').val();
          const sent_data = {
            company_code: companyCode,
            view_deptcode_sum,
            department_code,
            begin_date,
            end_date,
          };
          let drill_down_url;
          switch (params.seriesName) {
            case '工作填报率':
              drill_down_url = '/report/subsidiary_daily_workloading/day_rate_drill_down';
              break;
            case '方案饱和度':
              drill_down_url = '/report/subsidiary_daily_workloading/planning_day_rate_drill_down';
              break;
            case '施工图饱和度':
              drill_down_url = '/report/subsidiary_daily_workloading/building_day_rate_drill_down';
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


    console.log('isNonConstruction', isNonConstruction);

    subsidiaryWorkloadingsJobDayChart.setOption(option1, false);
    subsidiaryWorkloadingsJobDayChart.on('click', drill_down_model_show);
    if(!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart.setOption(option2, false);
      subsidiaryWorkloadingsPlanningDayChart.on('click', drill_down_model_show);
      subsidiaryWorkloadingsBuildingDayChart.setOption(option3, false);
      subsidiaryWorkloadingsBuildingDayChart.on('click', drill_down_model_show);
    }
    setTimeout(() => {
      subsidiaryWorkloadingsJobDayChart.resize();
      if(!isNonConstruction) {
        subsidiaryWorkloadingsPlanningDayChart.resize();
        subsidiaryWorkloadingsBuildingDayChart.resize();
      }
    }, 200);
  }

  layout() {
    subsidiaryWorkloadingsJobDayChart.resize();
    if(!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart.resize();
      subsidiaryWorkloadingsBuildingDayChart.resize();
    }
  }

  disconnect() {
    subsidiaryWorkloadingsJobDayChart.dispose();
    if(!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart.dispose();
      subsidiaryWorkloadingsBuildingDayChart.dispose();
    }
  }
}
