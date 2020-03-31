import { Controller } from "stimulus"

let realDeptChart;
let avgRealDeptChart;
let contractAmountChart;
let avgContractAmountChart;
let realAmountChart;
let avgRealAmountChart;

export default class extends Controller {
  connect() {
    realDeptChart = echarts.init(document.getElementById('dept-amount-chart'));
    avgRealDeptChart = echarts.init(document.getElementById('dept-amount-avg-chart'));
    contractAmountChart = echarts.init(document.getElementById('contract-amount-chart'));
    avgContractAmountChart = echarts.init(document.getElementById('contract-amount-avg-chart'));
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));
    avgRealAmountChart = echarts.init(document.getElementById('real-amount-avg-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const deptAmount = JSON.parse(this.data.get("dept_amount"));
    const realAmount = JSON.parse(this.data.get("real_amount"));
    const avgStaffDeptAmount = JSON.parse(this.data.get("avg_staff_dept_amount"));
    const avgWorkDeptAmount = JSON.parse(this.data.get("avg_work_dept_amount"));
    const contractAmount = JSON.parse(this.data.get("contract_amount"));
    const workHeadCount = JSON.parse(this.data.get("work_head_count"));
    const avgStaffRealAmount = JSON.parse(this.data.get("avg_staff_real_amount"));
    const avgWorkRealAmount = JSON.parse(this.data.get("avg_work_real_amount"));
    const avgStaffContractAmount = JSON.parse(this.data.get("avg_staff_contract_amount"));
    const avgWorkContractAmount = JSON.parse(this.data.get("avg_work_contract_amount"));

    const option_dept_amount = {
        legend: {
            data: ['生产合同额'],
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
          name: '生产合同额',
          type: 'bar',
          data: deptAmount,
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

    const option_avg_dept_amount = {
        legend: {
            data: ['一线人均生产合同额','全员人均生产合同额','一线人数'],
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
        yAxis: [{
          type: 'value',
          name: '人均生产合同额（万元）',
          position: 'left',
          axisLabel: {
            formatter: '{value}万'
          }
        },{
          type: 'value',
          name: '一线人数（人）',
          position: 'right',
          axisLine: {
            lineStyle: {
              color: '#675BBA'
            }
          },
          axisLabel: {
            formatter: '{value}人'
          }
        }],
        series: [{
          name: '一线人数',
          type: 'line',
          yAxisIndex: 1,
          symbol: 'circle',
          symbolSize: 8,
          data: workHeadCount,
          color: '#675BBA',
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        },{
          name: '一线人均生产合同额',
          type: 'bar',
          data: avgWorkDeptAmount,
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
          name: '全员人均生产合同额',
          type: 'bar',
          data: avgStaffDeptAmount,
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

    const option_avg_contract_amount = {
        legend: {
            data: ['一线人均商务合同额','全员人均商务合同额','一线人数'],
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
        yAxis: [{
          type: 'value',
          name: '人均商务合同额（万元）',
          position: 'left',
          axisLabel: {
            formatter: '{value}万'
          }
        },{
          type: 'value',
          name: '一线人数（人）',
          position: 'right',
          axisLine: {
            lineStyle: {
              color: '#675BBA'
            }
          },
          axisLabel: {
            formatter: '{value}人'
          }
        }],
        series: [{
          name: '一线人数',
          type: 'line',
          yAxisIndex: 1,
          symbol: 'circle',
          symbolSize: 8,
          data: workHeadCount,
          color: '#675BBA',
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        },{
          name: '一线人均商务合同额',
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
          name: '全员人均商务合同额',
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

    const option_real_amount = {
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

    const option_avg_real_amount = {
        legend: {
            data: ['一线人均实收款','全员人均实收款','一线人数'],
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
        yAxis: [{
          type: 'value',
          name: '人均实收款（万元）',
          position: 'left',
          axisLabel: {
            formatter: '{value}万'
          }
        },{
          type: 'value',
          name: '一线人数（人）',
          position: 'right',
          axisLine: {
            lineStyle: {
              color: '#675BBA'
            }
          },
          axisLabel: {
            formatter: '{value}人'
          }
        }],
        series: [{
          name: '一线人数',
          type: 'line',
          yAxisIndex: 1,
          symbol: 'circle',
          symbolSize: 8,
          data: workHeadCount,
          color: '#675BBA',
          barWidth: 20,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        },{
          name: '一线人均实收款',
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
          name: '全员人均实收款',
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

    realDeptChart.setOption(option_dept_amount, false);
    avgRealDeptChart.setOption(option_avg_dept_amount, false);
    contractAmountChart.setOption(option_contract_amount, false);
    avgContractAmountChart.setOption(option_avg_contract_amount, false);
    realAmountChart.setOption(option_real_amount, false);
    avgRealAmountChart.setOption(option_avg_real_amount, false);
    setTimeout(() => {
      realDeptChart.resize();
      avgRealDeptChart.resize();
      realAmountChart.resize();
      avgRealAmountChart.resize();
      contractAmountChart.resize();
      avgContractAmountChart.resize();
    }, 200);
  }

  layout() {
    realDeptChart.resize();
    avgRealDeptChart.resize();
    realAmountChart.resize();
    avgRealAmountChart.resize();
    contractAmountChart.resize();
    avgContractAmountChart.resize();
  }

  disconnect() {
    realDeptChart.dispose();
    avgRealDeptChart.dispose();
    realAmountChart.dispose();
    avgRealAmountChart.dispose();
    contractAmountChart.dispose();
    avgContractAmountChart.dispose();
  }
}
