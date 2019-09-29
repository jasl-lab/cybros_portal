import { Controller } from "stimulus"

let departmentRealReceivesChart;
let departmentNeedReceivesChart;
let departmentRealReceivesStaffChart;
let departmentNeedReceivesStaffChart;

export default class extends Controller {
  connect() {
    departmentRealReceivesChart = echarts.init(document.getElementById('department-real-receives-chart'));

    const realXAxisData = JSON.parse(this.data.get("real_x_axis"));
    const realReceives = JSON.parse(this.data.get("real_receives"));

    const real_option = {
        title: {
          text: '本年累计实收款'
        },
        legend: {
            data: ['本年累计实收款（百万元）'],
            align: 'left'
        },
        grid: {
          left: 70,
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
          data: realXAxisData,
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
            formatter: '{value}百万'
          }
        },
        series: [{
          name: '本年累计实收款（百万元）',
          type: 'bar',
          data: realReceives,
          color: '#738496',
          barMaxWidth: 38,
          label: {
            normal: {
              show: true,
              position: 'top',
              color: '#171717'
            }
          }
        }]
    };

    function drill_down_real_receives_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const series_company = realXAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          let url;
          url = "/report/subsidiary_department_receive";

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(series_company) + '&month_name=' + encodeURIComponent(month_name);
          } else {
            url += '?company_name=' + encodeURIComponent(series_company) + '&month_name=' + encodeURIComponent(month_name);
          }

          window.location.href = url;
        }
      }
    }

    departmentRealReceivesChart.on('click', drill_down_real_receives_on_click);
    departmentRealReceivesChart.setOption(real_option, false);

    setTimeout(() => {
      departmentRealReceivesChart.resize();
    }, 200);
  }

  layout() {
    departmentRealReceivesChart.resize();
  }

  disconnect() {
    departmentRealReceivesChart.dispose();
  }
}
