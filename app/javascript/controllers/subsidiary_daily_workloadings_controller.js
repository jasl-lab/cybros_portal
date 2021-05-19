import { Controller } from "stimulus"

let subsidiaryWorkloadingsJobDayChart;
let subsidiaryWorkloadingsPlanningDayChart;
let subsidiaryWorkloadingsBuildingDayChart;
let subsidiaryWorkloadingsNonConstructionDayChart;
let isNonConstruction;

export default class extends Controller {
  connect() {
    isNonConstruction = this.data.get("is_non_construction") == 'true';
    subsidiaryWorkloadingsJobDayChart = echarts.init(document.getElementById('subsidiary-workloadings-job-day-chart'));

    if (!isNonConstruction) {
      if (document.getElementById('subsidiary-workloadings-planning-day-chart')) {
        subsidiaryWorkloadingsPlanningDayChart = echarts.init(document.getElementById('subsidiary-workloadings-planning-day-chart'));
      } else {
        subsidiaryWorkloadingsPlanningDayChart = null;
      }
      if (document.getElementById('subsidiary-workloadings-building-day-chart')) {
        subsidiaryWorkloadingsBuildingDayChart = echarts.init(document.getElementById('subsidiary-workloadings-building-day-chart'));
      } else {
        subsidiaryWorkloadingsBuildingDayChart = null;
      }
    } else {
      if (document.getElementById('subsidiary-workloadings-non-construction-day-chart')) {
        subsidiaryWorkloadingsNonConstructionDayChart = echarts.init(document.getElementById('subsidiary-workloadings-non-construction-day-chart'));
      } else {
        subsidiaryWorkloadingsNonConstructionDayChart = null;
      }
    }

    const xAxisJobCode = JSON.parse(this.data.get("x_axis_job_code"));
    const xAxisJob = JSON.parse(this.data.get("x_axis_job"));
    const xAxisBluePrintCode = JSON.parse(this.data.get("x_axis_blue_print_code"));
    const xAxisBluePrint = JSON.parse(this.data.get("x_axis_blue_print"));
    const xAxisConstructionCode = JSON.parse(this.data.get("x_axis_construction_code"));
    const xAxisConstruction = JSON.parse(this.data.get("x_axis_construction"));
    const xAxisNonConstructionCode = JSON.parse(this.data.get("x_axis_non_construction_code"));
    const xAxisNonConstruction = JSON.parse(this.data.get("x_axis_non_construction"));
    const view_deptcode_sum = this.data.get("view_deptcode_sum") == "true";
    const companyCode = this.data.get("company_code");
    const dayRateData = JSON.parse(this.data.get("day_rate"));
    const planningDayUnapprovedRateData = JSON.parse(this.data.get("planning_day_unapproved_rate"));
    const planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
    const buildingDayUnapprovedRateData = JSON.parse(this.data.get("building_day_unapproved_rate"));
    const buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
    const nonConstructionDayUnapprovedRateData = JSON.parse(this.data.get("non_construction_day_unapproved_rate"));
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
          triggerEvent: true,
          data: xAxisJob,
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
          },
          max: function (value) {
            return value.max >= 100 ? value.max : 100;
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
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        }]
    };

    const planning_option = {
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
          triggerEvent: true,
          data: xAxisBluePrint,
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
          },
          max: function (value) {
            return value.max >= 100 ? value.max : 100;
          }
        },
        legend: {
            data: ['未确认方案饱和度','方案饱和度'],
            align: 'left'
        },
        series: [{
          name: '未确认方案饱和度',
          type: 'line',
          symbol: 'circle',
          symbolSize: 10,
          data: planningDayUnapprovedRateData,
          itemStyle: {
            color: '#69B0B8'
          },
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        },{
          name: '方案饱和度',
          type: 'line',
          symbol: 'circle',
          symbolSize: 10,
          data: planningDayRateData,
          itemStyle: {
            color: '#334B5C'
          },
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        }]
    };

    const building_option = {
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
          triggerEvent: true,
          data: xAxisConstruction,
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
          },
          max: function (value) {
            return value.max >= 100 ? value.max : 100;
          }
        },
        legend: {
            data: ['未确认施工图饱和度','施工图饱和度'],
            align: 'left'
        },
        series: [{
          name: '未确认施工图饱和度',
          type: 'line',
          symbol: 'square',
          symbolSize:  10,
          data: buildingDayUnapprovedRateData,
          itemStyle: {
            color: '#69B0B8'
          },
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        },{
          name: '施工图饱和度',
          type: 'line',
          symbol: 'square',
          symbolSize:  10,
          data: buildingDayRateData,
          itemStyle: {
            color: '#334B5C'
          },
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        }]
    };

    const non_construction_option = {
        title: {
          text: '饱和度'
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
          triggerEvent: true,
          data: xAxisNonConstruction,
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
          },
          max: function (value) {
            return value.max >= 100 ? value.max : 100;
          }
        },
        legend: {
            data: ['未确认饱和度','饱和度'],
            align: 'left'
        },
        series: [{
          name: '未确认饱和度',
          type: 'line',
          symbol: 'square',
          symbolSize:  10,
          data: nonConstructionDayUnapprovedRateData,
          itemStyle: {
            color: '#69B0B8'
          },
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        },{
          name: '饱和度',
          type: 'line',
          symbol: 'square',
          symbolSize:  10,
          data: nonConstructionDayRateData,
          itemStyle: {
            color: '#334B5C'
          },
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        }]
    };

    function drill_down_model_show(x_name, x_code) {
      function drill_down(params) {
        const begin_date = $('#datetimepicker_start_date').datetimepicker('date').format("YYYY-MM-DD");
        const end_date = $('#datetimepicker_end_date').datetimepicker('date').format("YYYY-MM-DD");

        if (params.componentType === 'xAxis') {
          const deptIndex = x_name.indexOf(params.value);
          const department_code = x_code[deptIndex];
          const sent_data = {
            company_code: companyCode,
            view_deptcode_sum,
            department_code,
            begin_date,
            end_date,
          };
          const drill_down_url = '/report/subsidiary_daily_workloading/day_rate_drill_down';
          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        } else if (params.componentType === 'series' && params.componentSubType === 'line') {
          const company_code = companyCode;
          const department_code = x_code[params.dataIndex];
          let url
          if (view_deptcode_sum) {
            url = `/report/subsidiary_people_workloading?view_deptcode_sum=true&company_code=${company_code}&dept_code=${department_code}&begin_date=${begin_date}&end_date=${end_date}`;
          } else {
            url = `/report/subsidiary_people_workloading?company_code=${company_code}&dept_code=${department_code}&begin_date=${begin_date}&end_date=${end_date}`;
          }
          Turbolinks.visit(url);
        }
      }
      return drill_down;
    }

    subsidiaryWorkloadingsJobDayChart.setOption(day_option, false);
    subsidiaryWorkloadingsJobDayChart.on('click', drill_down_model_show(xAxisJob, xAxisJobCode));
    if(!isNonConstruction) {
      if (subsidiaryWorkloadingsPlanningDayChart) {
        subsidiaryWorkloadingsPlanningDayChart.setOption(planning_option, false);
        subsidiaryWorkloadingsPlanningDayChart.on('click', drill_down_model_show(xAxisBluePrint, xAxisBluePrintCode));
      }
      if (subsidiaryWorkloadingsBuildingDayChart) {
        subsidiaryWorkloadingsBuildingDayChart.setOption(building_option, false);
        subsidiaryWorkloadingsBuildingDayChart.on('click', drill_down_model_show(xAxisConstruction, xAxisConstructionCode));
      }
    } else {
      if (subsidiaryWorkloadingsNonConstructionDayChart) {
        subsidiaryWorkloadingsNonConstructionDayChart.setOption(non_construction_option, false);
        subsidiaryWorkloadingsNonConstructionDayChart.on('click', drill_down_model_show(xAxisNonConstruction, xAxisNonConstructionCode));
      }
    }

    setTimeout(() => {
      subsidiaryWorkloadingsJobDayChart.resize();
      if(!isNonConstruction) {
        if (subsidiaryWorkloadingsPlanningDayChart) {
          subsidiaryWorkloadingsPlanningDayChart.resize();
        }
        if (subsidiaryWorkloadingsBuildingDayChart) {
          subsidiaryWorkloadingsBuildingDayChart.resize();
        }
      } else {
        if (subsidiaryWorkloadingsBuildingDayChart) {
          subsidiaryWorkloadingsNonConstructionDayChart.resize();
        }
      }
    }, 200);
  }

  layout() {
    subsidiaryWorkloadingsJobDayChart.resize();
    if(!isNonConstruction) {
      if (subsidiaryWorkloadingsPlanningDayChart) {
        subsidiaryWorkloadingsPlanningDayChart.resize();
      }
      if (subsidiaryWorkloadingsBuildingDayChart) {
        subsidiaryWorkloadingsBuildingDayChart.resize();
      }
    } else {
      if (subsidiaryWorkloadingsNonConstructionDayChart) {
        subsidiaryWorkloadingsNonConstructionDayChart.resize();
      }
    }
  }

  disconnect() {
    subsidiaryWorkloadingsJobDayChart.dispose();
    if(!isNonConstruction) {
      if (subsidiaryWorkloadingsPlanningDayChart) {
        subsidiaryWorkloadingsPlanningDayChart.dispose();
      }
      if (subsidiaryWorkloadingsBuildingDayChart) {
        subsidiaryWorkloadingsBuildingDayChart.dispose();
      }
    } else {
      if (subsidiaryWorkloadingsNonConstructionDayChart) {
        subsidiaryWorkloadingsNonConstructionDayChart.dispose();
      }
    }
  }
}
