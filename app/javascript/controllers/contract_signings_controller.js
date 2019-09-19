import { Controller } from "stimulus"

let contractSigningsChart;
let contractSigningsAvgChart;

export default class extends Controller {
  connect() {
    contractSigningsChart = echarts.init(document.getElementById('contract-signings-chart'));
    contractSigningsAvgChart = echarts.init(document.getElementById('contract-signings-avg-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const sumOrgNames = JSON.parse(this.data.get("sum_org_names"));
    const companyName = this.data.get("company_name");
    const secondLevelDrill = this.data.get("second_level_drill");
    const sumContractAmounts = JSON.parse(this.data.get("sum_contract_amounts"));
    const sumContractAmountMax = JSON.parse(this.data.get("sum_contract_amount_max"));
    const avgPeriodMean = JSON.parse(this.data.get("avg_period_mean"));
    const avgPeriodMeanMax = JSON.parse(this.data.get("avg_period_mean_max"));
    const contractAmountsPerStaff = JSON.parse(this.data.get("contract_amounts_per_staff"));
    const periodMeanRef = this.data.get("period_mean_ref");
    const contractAmountsPerStaffRef = this.data.get("contract_amounts_per_staff_ref");

    function differentColor(amount) {
      let color;

      if(contractAmountsPerStaffRef > amount) {
        color = '#BB332E';
      } else {
        color = '#7E91A5';
      }

      return { value: amount, itemStyle: { color: color }}
    }

    const contractAmountsPerStaffWithColor = contractAmountsPerStaff.map(differentColor);

    const option = {
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
          name: '本年累计合同额（百万元）',
          position: 'left',
          min: 0,
          max: sumContractAmountMax,
          interval: Math.ceil(sumContractAmountMax / 5),
          axisLabel: {
            formatter: '{value}百万'
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

    const option_avg = {
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
        if (params.seriesType === 'bar') {
          const series_company = xAxisData[params.dataIndex];
          let url;
          if(sumOrgNames.indexOf(series_company) > -1) {
            url = "/report/contract_signing";
          } else {
            url = "/report/subsidiary_contract_signing";
          }

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(series_company);
          } else {
            url += '?company_name=' + encodeURIComponent(series_company);
          }
          window.location.href = url;
        }
      }
    }

    contractSigningsChart.setOption(option, false);
    contractSigningsChart.on('click', drill_down_on_click);

    contractSigningsAvgChart.setOption(option_avg, false);
    setTimeout(() => {
      contractSigningsChart.resize();
      contractSigningsAvgChart.resize();
    }, 200);
  }

  layout() {
    contractSigningsChart.resize();
    contractSigningsAvgChart.resize();
  }

  disconnect() {
    contractSigningsChart.dispose();
    contractSigningsAvgChart.dispose();
  }
}
