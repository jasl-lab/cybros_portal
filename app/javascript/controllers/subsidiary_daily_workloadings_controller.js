import { Controller } from "stimulus"

let subsidiaryWorkloadingsChart1;
let subsidiaryWorkloadingsChart2;
let subsidiaryWorkloadingsChart3;
let isNonConstruction;

export default class extends Controller {
  connect() {
    isNonConstruction = this.data.get("is_non_construction") == 'true';
    subsidiaryWorkloadingsChart1 = echarts.init(document.getElementById('subsidiary-workloadings-chart1'));

    if (!isNonConstruction) {
      subsidiaryWorkloadingsChart2 = echarts.init(document.getElementById('subsidiary-workloadings-chart2'));
      subsidiaryWorkloadingsChart3 = echarts.init(document.getElementById('subsidiary-workloadings-chart3'));
    }

    const xAxisJob = JSON.parse(this.data.get("x_axis_job"));
    const xAxisBluePrint = JSON.parse(this.data.get("x_axis_blue_print"));
    const xAxisConstruction = JSON.parse(this.data.get("x_axis_construction"));
    const companyName = this.data.get("company_name");
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
          let department_name;
          switch (params.seriesName) {
            case '工作填报率':
              department_name = xAxisJob[params.dataIndex]
              break;
            case '方案饱和度':
              department_name = xAxisBluePrint[params.dataIndex]
              break;
            case '施工图饱和度':
              department_name = xAxisConstruction[params.dataIndex]
              break;
          }
          const begin_month_name = $('#begin_month_name').val();
          const end_month_name = $('#end_month_name').val();
          const sent_data = {
            company_name: companyName,
            department_name,
            begin_month_name,
            end_month_name,
          };
          let drill_down_url;
          switch (params.seriesName) {
            case '工作填报率':
              drill_down_url = '/report/subsidiary_workloading/day_rate_drill_down';
              break;
            case '方案饱和度':
              drill_down_url = '/report/subsidiary_workloading/planning_day_rate_drill_down';
              break;
            case '施工图饱和度':
              drill_down_url = '/report/subsidiary_workloading/building_day_rate_drill_down';
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

    subsidiaryWorkloadingsChart1.setOption(option1, false);
    subsidiaryWorkloadingsChart1.on('click', drill_down_model_show);
    if(!isNonConstruction) {
      subsidiaryWorkloadingsChart2.setOption(option2, false);
      subsidiaryWorkloadingsChart2.on('click', drill_down_model_show);
      subsidiaryWorkloadingsChart3.setOption(option3, false);
      subsidiaryWorkloadingsChart3.on('click', drill_down_model_show);
    }
    setTimeout(() => {
      subsidiaryWorkloadingsChart1.resize();
      if(!isNonConstruction) {
        subsidiaryWorkloadingsChart2.resize();
        subsidiaryWorkloadingsChart3.resize();
      }
    }, 200);
  }

  layout() {
    subsidiaryWorkloadingsChart1.resize();
    if(!isNonConstruction) {
      subsidiaryWorkloadingsChart2.resize();
      subsidiaryWorkloadingsChart3.resize();
    }
  }

  disconnect() {
    subsidiaryWorkloadingsChart1.dispose();
    if(!isNonConstruction) {
      subsidiaryWorkloadingsChart2.dispose();
      subsidiaryWorkloadingsChart3.dispose();
    }
  }
}
