import { Controller } from "stimulus"

let realAmountChart;
let avgRealAmountChart;
let contractAmountChart;
let avgContractAmountChart;

export default class extends Controller {
  connect() {
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));
    avgRealAmountChart = echarts.init(document.getElementById('real-amount-avg-chart'));
    contractAmountChart = echarts.init(document.getElementById('contract-amount-chart'));
    avgContractAmountChart = echarts.init(document.getElementById('contract-amount-avg-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const realAmount = JSON.parse(this.data.get("real_amount"));
    const contractAmount = JSON.parse(this.data.get("contract_amount"));
    const avgStaffRealAmount = JSON.parse(this.data.get("avg_staff_real_amount"));
    const avgWorkRealAmount = JSON.parse(this.data.get("avg_work_real_amount"));
    const avgStaffContractAmount = JSON.parse(this.data.get("avg_staff_contract_amount"));
    const avgWorkContractAmount = JSON.parse(this.data.get("avg_work_contract_amount"));

    const option_real_amount = {
        legend: {
            data: ['商务合同额'],
            align: 'left'
        },
        grid: {
          left: 130,
          right: 50,
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
            interval: 0
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value} 百万'
          }
        },
        series: [{
          name: '商务合同额',
          type: 'bar',
          data: contractAmount,
          barWidth: 30,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#738496'
          }
        }]
    };

    const option_avg_real_amount = {
        legend: {
            data: ['一线人均商务合同额','全员人均商务合同额'],
            align: 'left'
        },
        grid: {
          left: 130,
          right: 50,
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
            interval: 0
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value} 万'
          }
        },
        series: [{
          name: '一线人均商务合同额',
          type: 'bar',
          data: avgWorkRealAmount,
          barWidth: 30,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#738496'
          }
        },{
          name: '全员人均商务合同额',
          type: 'bar',
          data: avgStaffRealAmount,
          barWidth: 30,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#6AB0B8'
          }
        }]
    };

    const option_contract_amount = {
        legend: {
            data: ['实收款'],
            align: 'left'
        },
        grid: {
          left: 130,
          right: 50,
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
            interval: 0
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value} 百万'
          }
        },
        series: [{
          name: '实收款',
          type: 'bar',
          data: realAmount,
          barWidth: 30,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#738496'
          }
        }]
    };

    const option_avg_contract_amount = {
        legend: {
            data: ['一线人均实收款','全员人均实收款'],
            align: 'left'
        },
        grid: {
          left: 130,
          right: 50,
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
            interval: 0
          },
          splitLine: {
              show: false
          }
        },
        yAxis: {
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value} 万'
          }
        },
        series: [{
          name: '一线人均实收款',
          type: 'bar',
          data: avgWorkContractAmount,
          barWidth: 30,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#738496'
          }
        },{
          name: '全员人均实收款',
          type: 'bar',
          data: avgStaffContractAmount,
          barWidth: 30,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          },
          itemStyle: {
            color: '#6AB0B8'
          }
        }]
    };

    realAmountChart.setOption(option_real_amount, false);
    avgRealAmountChart.setOption(option_avg_real_amount, false);
    contractAmountChart.setOption(option_contract_amount, false);
    avgContractAmountChart.setOption(option_avg_contract_amount, false);

    setTimeout(() => {
      realAmountChart.resize();
      avgRealAmountChart.resize();
      contractAmountChart.resize();
      avgContractAmountChart.resize();
    }, 200);
  }

  layout() {
    realAmountChart.resize();
    avgRealAmountChart.resize();
    contractAmountChart.resize();
    avgContractAmountChart.resize();
  }

  disconnect() {
    realAmountChart.dispose();
    avgRealAmountChart.dispose();
    contractAmountChart.dispose();
    avgContractAmountChart.dispose();
  }
}
