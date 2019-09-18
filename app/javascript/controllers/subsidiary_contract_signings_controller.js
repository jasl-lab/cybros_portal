import { Controller } from "stimulus"

let subsidiaryContractSigningsChart;
let subsidiaryContractSigningsAvgChart;

export default class extends Controller {
  connect() {
    subsidiaryContractSigningsChart = echarts.init(document.getElementById('subsidiary-contract-signings-chart'));
    subsidiaryContractSigningsAvgChart = echarts.init(document.getElementById('subsidiary-contract-signings-avg-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var currentUserCompaniesShortNames = JSON.parse(this.data.get("current_user_companies_short_names"));
var companyName = this.data.get("company_name");
var sumContractAmounts = JSON.parse(this.data.get("sum_contract_amounts"));
var sumContractAmountMax = JSON.parse(this.data.get("sum_contract_amount_max"));
var avgPeriodMean = JSON.parse(this.data.get("avg_period_mean"));
var avgPeriodMeanMax = JSON.parse(this.data.get("avg_period_mean_max"));
var contractAmountsPerStaff = JSON.parse(this.data.get("contract_amounts_per_staff"));
var periodMeanRef = this.data.get("period_mean_ref");
var contractAmountsPerStaffRef = this.data.get("contract_amounts_per_staff_ref");

function differentColor(amount) {
  let color;

  if(contractAmountsPerStaffRef > amount) {
    color = '#BB332E';
  } else {
    color = '#7E91A5';
  }

  return { value: amount, itemStyle: { color: color }}
}

var contractAmountsPerStaffWithColor = contractAmountsPerStaff.map(differentColor);

var option = {
    legend: {
        data: ['签约周期','本年累计合同额'],
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
      name: '本年累计合同额（万元）',
      position: 'left',
      min: 0,
      max: sumContractAmountMax,
      interval: Math.ceil(sumContractAmountMax / 5),
      axisLabel: {
        formatter: '{value}万'
      }
    },{
      type: 'value',
      name: '签约周期（天）',
      position: 'right',
      min: 0,
      max: avgPeriodMeanMax,
      interval: Math.ceil(avgPeriodMeanMax / 5),
      axisLine: {
        lineStyle: {
          color: '#675BBA'
        }
      },
      axisLabel: {
        formatter: '{value}天'
      }
    }],
    series: [{
      name: '签约周期',
      type: 'line',
      yAxisIndex: 1,
      symbol: 'circle',
      symbolSize: 8,
      data: avgPeriodMean,
      color: '#675BBA',
      label: {
        normal: {
          show: true,
          position: 'top'
        }
      },
      markLine: {
        label: {
          formatter: '签约周期{c}天线'
        },
        lineStyle: {
          type: 'solid',
          width: 1
        },
        data: [
          {
            yAxis: periodMeanRef
          }
        ]
      }
    },{
      name: '本年累计合同额',
      type: 'bar',
      data: sumContractAmounts,
      color: '#738496',
      barMaxWidth: 80,
      label: {
        normal: {
          show: true,
          position: 'top'
        }
      }
    }]
};

var option_avg = {
    legend: {
        data: ['本年累计人均合同额'],
        align: 'left'
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      }
    },
    grid: {
      left: 80,
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
      name: '本年累计人均合同额（万元）',
      position: 'left',
      axisLabel: {
        formatter: '{value}万'
      }
    }],
    series: [{
      name: '本年累计人均合同额',
      type: 'bar',
      data: contractAmountsPerStaffWithColor,
      barMaxWidth: 80,
      label: {
        normal: {
          show: true,
          position: 'top'
        }
      },
      markLine: {
        label: {
          formatter: '人均合同额预警'
        },
        lineStyle: {
          type: 'solid',
          width: 1
        },
        data: [
          {
            yAxis: contractAmountsPerStaffRef
          }
        ]
      }
    }]
};
    function drill_down_on_click(params) {
      if (params.componentType === 'series') {
        const series_department = xAxisData[params.dataIndex]
        const month_name = $('#month_name').val();
        const sent_data = {
          company_name: companyName,
          department_name: series_department,
          month_name: month_name };
        let drill_down_url;
        if (params.seriesType === 'bar') {
          drill_down_url = '/report/subsidiary_contract_signing/drill_down_amount'
        } else if (params.seriesType === 'line') {
          drill_down_url = '/report/subsidiary_contract_signing/drill_down_date'
        }
        $.ajax(drill_down_url, {
          data: sent_data,
          dataType: 'script'
        });
      }
    }

    subsidiaryContractSigningsChart.setOption(option, false);
    subsidiaryContractSigningsChart.on('click', drill_down_on_click);

    subsidiaryContractSigningsAvgChart.setOption(option_avg, false);
    setTimeout(() => {
      subsidiaryContractSigningsChart.resize();
      subsidiaryContractSigningsAvgChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryContractSigningsChart.resize();
    subsidiaryContractSigningsAvgChart.resize();
  }

  disconnect() {
    subsidiaryContractSigningsChart.dispose();
    subsidiaryContractSigningsAvgChart.dispose();
  }
}
