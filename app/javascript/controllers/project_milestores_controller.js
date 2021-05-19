import { Controller } from "stimulus"

let projectMilestoreChart;

export default class extends Controller {
  connect() {
    projectMilestoreChart = echarts.init(document.getElementById('project-milestore-chart'));

    const xAxisData = JSON.parse(this.data.get("x_axis"));
    const departmentCodes = JSON.parse(this.data.get("department_codes"));
    const milestoreUpdateRate = JSON.parse(this.data.get("milestore_update_rate"));

    const option = {
        legend: {
            data: ['项目里程碑更新率'],
            align: 'left'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'cross'
          }
        },
        grid: {
          left: 50,
          right: 50,
          top: 50,
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
          name: '项目里程碑更新率',
          axisLabel: {
            formatter: '{value}%'
          }
        }],
        series: [{
          name: '项目里程碑更新率',
          type: 'line',
          data: milestoreUpdateRate,
          color: '#738496',
          symbolSize: 10,
          label: {
            show: true,
            position: 'top',
            formatter: '{c}%'
          }
        }]
    };
    function drill_down_contract_detail(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'line') {
          const department_name = xAxisData[params.dataIndex];
          const department_code = departmentCodes[params.dataIndex];
          const month_name = $('#month_name').val();
          const sent_data = { department_name, department_code, month_name };
          let drill_down_url = '/report/project_milestore/detail_drill_down';

          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        }
      }
    }

    projectMilestoreChart.on('click', drill_down_contract_detail);

    projectMilestoreChart.setOption(option, false);
    setTimeout(() => {
      projectMilestoreChart.resize();
    }, 200);
  }

  layout() {
    projectMilestoreChart.resize();
  }

  disconnect() {
    projectMilestoreChart.dispose();
  }
}
