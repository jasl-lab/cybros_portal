import { Controller } from "stimulus"

let inIFrame;
let contractSigningsChart;
let contractProductionChart;
let contractSigningsAvgChart;

export default class extends Controller {
  connect() {
    inIFrame = this.data.get("in_iframe");

    if (inIFrame != "true") {
      contractSigningsChart = echarts.init(document.getElementById('contract-signings-chart'));
    }
    contractProductionChart = echarts.init(document.getElementById('contract-production-chart'));
    contractSigningsAvgChart = echarts.init(document.getElementById('contract-signings-avg-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const currentUserCompaniesShortNames = JSON.parse(this.data.get("current_user_companies_short_names"));
    const sumOrgNames = JSON.parse(this.data.get("sum_org_names"));
    const sumContractAmounts = JSON.parse(this.data.get("sum_contract_amounts"));
    const sumContractAmountMax = JSON.parse(this.data.get("sum_contract_amount_max"));
    const avgPeriodMean = JSON.parse(this.data.get("avg_period_mean"));
    const avgPeriodMeanMax = JSON.parse(this.data.get("avg_period_mean_max"));
    const productionAmountsPerStaff = JSON.parse(this.data.get("production_amounts_per_staff"));
    const periodMeanRef = this.data.get("period_mean_ref");
    const contractAmountsPerStaffRef = this.data.get("contract_amounts_per_staff_ref");
    const cpOrgNames = JSON.parse(this.data.get("cp_org_names"));
    const cpContractAmounts = JSON.parse(this.data.get("cp_contract_amounts"));
    const cp_PlanContractAmounts = JSON.parse(this.data.get("cp_plan_contract_amounts"));

    let myOwnCompanyIndex = [];
    for (let index = 0; index < xAxisData.length; ++index) {
        if (currentUserCompaniesShortNames.indexOf(xAxisData[index]) > -1) {
            myOwnCompanyIndex.push(index);
        }
    }

    function differentColorForContractSigning(amount, index) {
      let color;

      if (myOwnCompanyIndex.indexOf(index) > -1 || currentUserCompaniesShortNames.indexOf('上海天华') > -1) {
        color = '#334B5C';
      } else {
        color = '#8EA1B5';
      }

      return { value: amount, itemStyle: { color: color }}
    }

    const sumContractAmountsWithColor = sumContractAmounts.map(differentColorForContractSigning);

    function differentColorForAmountPerStaff(amount) {
      let color;

      if(contractAmountsPerStaffRef > amount) {
        color = '#BB332E';
      } else {
        color = '#7E91A5';
      }

      return { value: amount, itemStyle: { color: color }}
    }

    const productionAmountsPerStaffWithColor = productionAmountsPerStaff.map(differentColorForAmountPerStaff);

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
          left: 85,
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
          name: '本年合同额（百万元）',
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
          barWidth: 20,
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
          data: sumContractAmountsWithColor,
          color: '#334B5C',
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        }]
    };

    const cp_option = {
        legend: {
            data: ['本年累计生产合同额','本年计划生产合同额'],
            align: 'left'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'cross'
          }
        },
        grid: {
          left: 85,
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
          data: cpOrgNames,
          silent: true,
          axisLabel: {
            interval: 0,
            rotate: -40,
          },
          splitLine: {
              show: false
          }
        },
        yAxis: [{
          type: 'value',
          name: '本年累计生产合同额（百万元）',
          position: 'left',
          axisLabel: {
            formatter: '{value}百万'
          }
        }],
        series: [{
          name: '本年累计生产合同额',
          type: 'bar',
          stack: '生产合同',
          data: cpContractAmounts,
          color: '#334B5C',
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        },{
          name: '本年计划生产合同额',
          type: 'scatter',
          stack: '生产合同',
          data: cp_PlanContractAmounts,
          color: '#738496',
          barWidth: 20,
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
            data: ['本年累计人均生产合同额'],
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
          name: '本年累计人均生产合同额（万元）',
          position: 'left',
          axisLabel: {
            formatter: '{value}万'
          }
        }],
        series: [{
          name: '本年累计人均生产合同额',
          type: 'bar',
          data: productionAmountsPerStaffWithColor,
          barWidth: 20,
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
          if (currentUserCompaniesShortNames.indexOf(series_company) > -1 || currentUserCompaniesShortNames.indexOf('上海天华') > -1) {
            Turbolinks.visit(url);
          }
        }
      }
    }

    if (inIFrame != "true") {
      contractSigningsChart.setOption(option, false);
      contractSigningsChart.on('click', drill_down_on_click);
    }

    contractProductionChart.setOption(cp_option, false);

    contractSigningsAvgChart.setOption(option_avg, false);
    setTimeout(() => {
      if (inIFrame != "true") {
        contractSigningsChart.resize();
      }
      contractProductionChart.resize();
      contractSigningsAvgChart.resize();
    }, 200);
  }

  layout() {
    if (inIFrame != "true") {
      contractSigningsChart.resize();
    }
    contractProductionChart.resize();
    contractSigningsAvgChart.resize();
  }

  disconnect() {
    if (inIFrame != "true") {
      contractSigningsChart.dispose();
    }
    contractProductionChart.dispose();
    contractSigningsAvgChart.dispose();
  }
}
