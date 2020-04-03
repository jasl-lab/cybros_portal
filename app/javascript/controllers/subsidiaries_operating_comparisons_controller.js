import { Controller } from "stimulus"

let deptValueChart;
let avgStaffDeptValueChart;
let avgWorkDeptValueChart;
let contractAmountChart;
let avgStaffContractAmountChart;
let avgWorkContractAmountChart;
let realAmountChart;
let avgStaffRealAmountChart;
let avgWorkRealAmountChart;

function set_chart(chart, amounts, amounts_names, head_count_title, head_count, title, x_axis) {
  const predefine_color = ['#8d6e6d','#6ab0b8','#738496','#004080'];

  function build_serial(year, index) {
    return {
        name: amounts_names[index] + title,
        type: 'bar',
        data: amounts[year],
        label: {
          normal: {
            show: true,
            position: 'top'
          }
        },
        itemStyle: {
          color: predefine_color[index%4]
        }
      }
  }

  function build_legend(year, index) {
    return amounts_names[index] + title;
  }

  function build_x_axis(company_name, index) {
    return company_name + '(' + head_count[index] + ')';
  }

  let series = amounts_names.map(build_serial);
  let y_axis = [{
          type: 'value',
          name: title,
          position: 'left',
          axisLabel: {
            formatter: '{value}百万'
          }
        }];
  let legend = amounts_names.map(build_legend);
  if(head_count) {
    series.unshift({
            name: head_count_title,
            type: 'scatter',
            yAxisIndex: 1,
            symbol: 'circle',
            symbolSize: 4,
            data: head_count,
            color: '#5993d2'
          });
    x_axis = x_axis.map(build_x_axis);
    y_axis.push({
          type: 'value',
          name: '人数',
          position: 'right',
          nameGap: 3,
          axisLine: {
            lineStyle: {
              color: '#5993d2'
            }
          },
          splitLine: {
            show: false
          },
          axisLabel: {
            formatter: '{value}人'
          }
        });
    legend.push(head_count_title);
  }

  const option_amounts = {
      legend: {
          data: legend,
          align: 'left'
      },
      grid: {
        left: 70,
        right: 50,
        top: 40,
        bottom: 80
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
        data: x_axis,
        silent: true,
        axisLabel: {
          interval: 0,
          rotate: -40
        },
        splitLine: {
            show: false
        }
      },
      yAxis: y_axis,
      series: series
  };


  chart.setOption(option_amounts, false);
}

export default class extends Controller {
  connect() {
    deptValueChart = echarts.init(document.getElementById('dept-value-chart'));
    avgStaffDeptValueChart = echarts.init(document.getElementById('avg-staff-dept-value-chart'));
    avgWorkDeptValueChart = echarts.init(document.getElementById('avg-work-dept-value-chart'));
    contractAmountChart = echarts.init(document.getElementById('contract-amount-chart'));
    avgStaffContractAmountChart = echarts.init(document.getElementById('avg-staff-contract-amount-chart'));
    avgWorkContractAmountChart = echarts.init(document.getElementById('avg-work-contract-amount-chart'));
    realAmountChart = echarts.init(document.getElementById('real-amount-chart'));
    avgStaffRealAmountChart = echarts.init(document.getElementById('avg-staff-real-amount-chart'));
    avgWorkRealAmountChart = echarts.init(document.getElementById('avg-work-real-amount-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));

    const mostRecentAvgWorkNo = JSON.parse(this.data.get("most_recent_avg_work_no"));
    const mostRecentAvgStaffNo = JSON.parse(this.data.get("most_recent_avg_staff_no"));

    const yearsDeptValues = JSON.parse(this.data.get("years_dept_values"));
    const avgStaffDeptValues = JSON.parse(this.data.get("avg_staff_dept_values"));
    const avgWorkDeptValues = JSON.parse(this.data.get("avg_work_dept_values"));

    const yearsContractAmounts = JSON.parse(this.data.get("years_contract_amounts"));
    const avgStaffContractAmounts = JSON.parse(this.data.get("avg_staff_contract_amounts"));
    const avgWorkContractAmounts = JSON.parse(this.data.get("avg_work_contract_amounts"));

    const yearsRealAmounts = JSON.parse(this.data.get("years_real_amounts"));
    const avgStaffRealAmounts = JSON.parse(this.data.get("avg_staff_real_amounts"));
    const avgWorkRealAmounts = JSON.parse(this.data.get("avg_work_real_amounts"));

    const yearsDeptValues_names = Object.keys(yearsDeptValues);
    const avgStaffDeptValues_names = Object.keys(avgStaffDeptValues);
    const avgWorkDeptValues_names = Object.keys(avgWorkDeptValues);

    const yearsContractAmounts_names = Object.keys(yearsContractAmounts);
    const avgStaffContractAmounts_names = Object.keys(avgStaffContractAmounts);
    const avgWorkContractAmounts_names = Object.keys(avgWorkContractAmounts);

    const yearsRealAmounts_names = Object.keys(yearsRealAmounts);
    const avgStaffRealAmounts_names = Object.keys(avgStaffRealAmounts);
    const avgWorkRealAmounts_names = Object.keys(avgWorkRealAmounts);

    set_chart(deptValueChart, yearsDeptValues, yearsDeptValues_names, null, null, '生产合同额', xAxisData);
    set_chart(avgStaffDeptValueChart, avgStaffDeptValues, avgStaffDeptValues_names, '全员人数', mostRecentAvgStaffNo, '全员人均生产合同额', xAxisData);
    set_chart(avgWorkDeptValueChart, avgWorkDeptValues, avgWorkDeptValues_names, '一线人数', mostRecentAvgWorkNo, '一线人均生产合同额', xAxisData);

    set_chart(contractAmountChart, yearsContractAmounts, yearsContractAmounts_names, null, null, '商务合同额', xAxisData);
    set_chart(avgStaffContractAmountChart, avgStaffContractAmounts, avgStaffContractAmounts_names, '全员人数', mostRecentAvgStaffNo, '全员人均商务合同额', xAxisData);
    set_chart(avgWorkContractAmountChart, avgWorkContractAmounts, avgWorkContractAmounts_names, '一线人数', mostRecentAvgWorkNo, '一线人均商务合同额', xAxisData);

    set_chart(realAmountChart, yearsRealAmounts, yearsRealAmounts_names, null, null, '实收款', xAxisData);
    set_chart(avgStaffRealAmountChart, avgStaffRealAmounts, avgStaffRealAmounts_names, '全员人数', mostRecentAvgStaffNo, '全员人均实收款', xAxisData);
    set_chart(avgWorkRealAmountChart, avgWorkRealAmounts, avgWorkRealAmounts_names, '一线人数', mostRecentAvgWorkNo, '一线人均实收款', xAxisData);

    setTimeout(() => {
      deptValueChart.resize();
      avgStaffDeptValueChart.resize();
      avgWorkDeptValueChart.resize();
      contractAmountChart.resize();
      avgStaffContractAmountChart.resize();
      avgWorkContractAmountChart.resize();
      realAmountChart.resize();
      avgStaffRealAmountChart.resize();
      avgWorkRealAmountChart.resize();
    }, 200);
  }

  layout() {
    deptValueChart.resize();
    avgStaffDeptValueChart.resize();
    avgWorkDeptValueChart.resize();
    contractAmountChart.resize();
    avgStaffContractAmountChart.resize();
    avgWorkContractAmountChart.resize();
    realAmountChart.resize();
    avgStaffRealAmountChart.resize();
    avgWorkRealAmountChart.resize();
  }

  disconnect() {
    deptValueChart.dispose();
    avgStaffDeptValueChart.dispose();
    avgWorkDeptValueChart.dispose();
    contractAmountChart.dispose();
    avgStaffContractAmountChart.dispose();
    avgWorkContractAmountChart.dispose();
    realAmountChart.dispose();
    avgStaffRealAmountChart.dispose();
    avgWorkRealAmountChart.dispose();
  }
}
