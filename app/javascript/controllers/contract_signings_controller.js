import { Controller } from "stimulus"

let contractSigningsChart;

export default class extends Controller {
  connect() {
    contractSigningsChart = echarts.init(document.getElementById('contract-signings-chart'));

var xAxisData = JSON.parse(this.data.get("x_axis"));
var currentUserCompaniesShortNames = JSON.parse(this.data.get("current_user_companies_short_names"));
var companyName = this.data.get("company_name");
var secondLevelDrill = this.data.get("second_level_drill");
var sumContractAmounts = JSON.parse(this.data.get("sum_contract_amounts"));
var sumContractAmountMax = JSON.parse(this.data.get("sum_contract_amount_max"));
var avgPeriodMean = JSON.parse(this.data.get("avg_period_mean"));
var avgPeriodMeanMax = JSON.parse(this.data.get("avg_period_mean_max"));
var periodMeanRef = this.data.get("period_mean_ref");

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
      color: '#334B5C',
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

    function drill_down_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          if (secondLevelDrill === 'true') {
            let series_department = xAxisData[params.dataIndex]
            const month_name = $('#month_name').val();
            const sent_data = {
              company_name: companyName,
              department_name: series_department,
              month_name: month_name };
            let drill_down_url = '/report/contract_signing/drill_down'
            $.ajax(drill_down_url, {
              data: sent_data,
              dataType: 'script'
            });
          } else {
            let url = window.location.href;
            let series_company = xAxisData[params.dataIndex]
            if (url.indexOf('?') > -1) {
              url += '&company_name=' + encodeURIComponent(series_company);
            } else {
              url += '?company_name=' + encodeURIComponent(series_company);
            }
            if (currentUserCompaniesShortNames.indexOf(series_company) > -1 || currentUserCompaniesShortNames.indexOf('上海天华') > -1) {
              window.location.href = url;
            }
          }
        }
      }
    }

    contractSigningsChart.setOption(option, false);
    contractSigningsChart.on('click', drill_down_on_click);
    setTimeout(() => {
      contractSigningsChart.resize();
    }, 200);
  }

  layout() {
    contractSigningsChart.resize();
  }

  disconnect() {
    contractSigningsChart.dispose();
  }
}
