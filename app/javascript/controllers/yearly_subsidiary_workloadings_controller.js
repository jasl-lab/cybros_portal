import { Controller } from "stimulus"

let yearlySubsidiaryWorkloadingsChart1;
let yearlySubsidiaryWorkloadingsChart2;
let yearlySubsidiaryWorkloadingsChart3;

export default class extends Controller {
  connect() {
    yearlySubsidiaryWorkloadingsChart1 = echarts.init(document.getElementById('yearly-subsidiary-workloadings-chart1'));
    yearlySubsidiaryWorkloadingsChart2 = echarts.init(document.getElementById('yearly-subsidiary-workloadings-chart2'));
    yearlySubsidiaryWorkloadingsChart3 = echarts.init(document.getElementById('yearly-subsidiary-workloadings-chart3'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var selectedCompanyName = this.data.get("selected_company_name");
var dayRateData = JSON.parse(this.data.get("day_rate"));
var dayRateDataRef = this.data.get("day_rate_ref");
var planningDayRateData = JSON.parse(this.data.get("planning_day_rate"));
var planningDayRateDataRef = this.data.get("planning_day_rate_ref");
var buildingDayRateData = JSON.parse(this.data.get("building_day_rate"));
var buildingDayRateDataRef = this.data.get("building_day_rate_ref");

var option1 = {
    legend: {
        data: ['工作填报率'],
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
    yAxis: {
      min: 0,
      max: 120,
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

var option2 = {
    legend: {
        data: ['方案饱和度'],
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
    yAxis: {
      min: 0,
      max: 120,
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

var option3 = {
    legend: {
        data: ['施工图饱和度'],
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
    yAxis: {
      min: 0,
      max: 120,
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
      symbolSize: 10,
      data: buildingDayRateData,
      itemStyle: {
        color: '#6AB0B8'
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

    function drill_down_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'line') {
          let url = '/report/subsidiary_workloading';
          let month_name = xAxisData[params.dataIndex]
          url += '?company_name=' + encodeURIComponent(selectedCompanyName);
          url += '&begin_month_name=' + encodeURIComponent(month_name) + '&end_month_name=' + encodeURIComponent(month_name);
          Turbolinks.visit(url);
        }
      }
    }

    yearlySubsidiaryWorkloadingsChart1.setOption(option1, false);
    yearlySubsidiaryWorkloadingsChart1.on('click', drill_down_on_click);
    yearlySubsidiaryWorkloadingsChart2.setOption(option2, false);
    yearlySubsidiaryWorkloadingsChart2.on('click', drill_down_on_click);
    yearlySubsidiaryWorkloadingsChart3.setOption(option3, false);
    yearlySubsidiaryWorkloadingsChart3.on('click', drill_down_on_click);
    setTimeout(() => {
      yearlySubsidiaryWorkloadingsChart1.resize();
      yearlySubsidiaryWorkloadingsChart2.resize();
      yearlySubsidiaryWorkloadingsChart3.resize();
    }, 200);
  }

  layout() {
    yearlySubsidiaryWorkloadingsChart1.resize();
    yearlySubsidiaryWorkloadingsChart2.resize();
    yearlySubsidiaryWorkloadingsChart3.resize();
  }

  disconnect() {
    yearlySubsidiaryWorkloadingsChart1.dispose();
    yearlySubsidiaryWorkloadingsChart2.dispose();
    yearlySubsidiaryWorkloadingsChart3.dispose();
  }
}
