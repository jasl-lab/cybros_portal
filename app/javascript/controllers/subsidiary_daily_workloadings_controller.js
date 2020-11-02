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
      subsidiaryWorkloadingsPlanningDayChart = echarts.init(document.getElementById('subsidiary-workloadings-planning-day-chart'));
      subsidiaryWorkloadingsBuildingDayChart = echarts.init(document.getElementById('subsidiary-workloadings-building-day-chart'));
    } else {
      subsidiaryWorkloadingsNonConstructionDayChart = echarts.init(document.getElementById('subsidiary-workloadings-non-construction-day-chart'));
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
    const planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
    const buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
    const nonConstructionDayRateData = JSON.parse(this.data.get("non_construction_day_rate"));

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

    const option4 = {
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
          }
        },
        series: [{
          name: '饱和度',
          type: 'line',
          symbol: 'square',
          symbolSize:  10,
          data: nonConstructionDayRateData,
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

    function drill_down_model_show(x_name, x_code) {
      function drill_down(params) {
        const begin_date = $('#subsidiary-daily-workloading-begin-date').val();
        const end_date = $('#subsidiary-daily-workloading-end-date').val();

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

    subsidiaryWorkloadingsJobDayChart.setOption(option1, false);
    subsidiaryWorkloadingsJobDayChart.on('click', drill_down_model_show(xAxisJob, xAxisJobCode));
    if(!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart.setOption(option2, false);
      subsidiaryWorkloadingsPlanningDayChart.on('click', drill_down_model_show(xAxisBluePrint, xAxisBluePrintCode));
      subsidiaryWorkloadingsBuildingDayChart.setOption(option3, false);
      subsidiaryWorkloadingsBuildingDayChart.on('click', drill_down_model_show(xAxisConstruction, xAxisConstructionCode));
    } else {
      subsidiaryWorkloadingsNonConstructionDayChart.setOption(option4, false);
      subsidiaryWorkloadingsNonConstructionDayChart.on('click', drill_down_model_show(xAxisNonConstruction, xAxisNonConstructionCode));
    }
    setTimeout(() => {
      subsidiaryWorkloadingsJobDayChart.resize();
      if(!isNonConstruction) {
        subsidiaryWorkloadingsPlanningDayChart.resize();
        subsidiaryWorkloadingsBuildingDayChart.resize();
      } else {
        subsidiaryWorkloadingsNonConstructionDayChart.resize();
      }
    }, 200);
  }

  layout() {
    subsidiaryWorkloadingsJobDayChart.resize();
    if(!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart.resize();
      subsidiaryWorkloadingsBuildingDayChart.resize();
    } else {
      subsidiaryWorkloadingsNonConstructionDayChart.resize();
    }
  }

  disconnect() {
    subsidiaryWorkloadingsJobDayChart.dispose();
    if(!isNonConstruction) {
      subsidiaryWorkloadingsPlanningDayChart.dispose();
      subsidiaryWorkloadingsBuildingDayChart.dispose();
    } else {
      subsidiaryWorkloadingsNonConstructionDayChart.dispose();
    }
  }
}
