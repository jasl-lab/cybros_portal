import { Controller } from "stimulus"

let groupWorkloadingsChart1;
let groupWorkloadingsChart2;
let groupWorkloadingsChart3;

export default class extends Controller {
  connect() {
    groupWorkloadingsChart1 = echarts.init(document.getElementById('group-workloadings-chart1'));
    groupWorkloadingsChart2 = echarts.init(document.getElementById('group-workloadings-chart2'));
    groupWorkloadingsChart3 = echarts.init(document.getElementById('group-workloadings-chart3'));

    const xAxisJob = JSON.parse(this.data.get("x_axis_job"));
    const xAxisBluePrint = JSON.parse(this.data.get("x_axis_blue_print"));
    const xAxisConstruction = JSON.parse(this.data.get("x_axis_construction"));
    const currentUserCompaniesShortNames = JSON.parse(this.data.get("current_user_companies_short_names"));
    const dayRateData = JSON.parse(this.data.get("day_rate"));
    const dayRateDataRef = this.data.get("day_rate_ref");
    const planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
    const planningDayRateDataRef = this.data.get("planning_day_rate_ref");
    const buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
    const buildingDayRateDataRef = this.data.get("building_day_rate_ref");
    const inIFrame = this.data.get("in_iframe");

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

          let url;

          if(inIFrame == 'true') {
            url = '/report/subsidiary_workloading?in_iframe=true';
          } else {
            url = '/report/subsidiary_workloading';
          }

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(company_name) + '&view_deptcode_sum=true';
          } else {
            url += '?company_name=' + encodeURIComponent(company_name) + '&view_deptcode_sum=true';
          }
          if (currentUserCompaniesShortNames.indexOf(company_name) > -1 || currentUserCompaniesShortNames.indexOf('上海天华') > -1) {
            window.location.href = url;
          }
        }
      }
    }

    groupWorkloadingsChart1.setOption(option1, false);
    groupWorkloadingsChart1.on('click', drill_down_subsidiary);
    groupWorkloadingsChart2.setOption(option2, false);
    groupWorkloadingsChart2.on('click', drill_down_subsidiary);
    groupWorkloadingsChart3.setOption(option3, false);
    groupWorkloadingsChart3.on('click', drill_down_subsidiary);
    setTimeout(() => {
      groupWorkloadingsChart1.resize();
      groupWorkloadingsChart2.resize();
      groupWorkloadingsChart3.resize();
    }, 200);
  }

  layout() {
    groupWorkloadingsChart1.resize();
    groupWorkloadingsChart2.resize();
    groupWorkloadingsChart3.resize();
  }

  disconnect() {
    groupWorkloadingsChart1.dispose();
    groupWorkloadingsChart2.dispose();
    groupWorkloadingsChart3.dispose();
  }
}
