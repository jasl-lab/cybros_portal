import { Controller } from "stimulus"

let departmentRealReceivesChart;
let departmentNeedReceivesChart;
let departmentRealReceivesStaffChart;
let departmentNeedReceivesStaffChart;

export default class extends Controller {
  connect() {
    const inIFrame = this.data.get("in_iframe");
    const companyName = this.data.get("company_name");

    departmentRealReceivesChart = echarts.init(document.getElementById('department-real-receives-chart'));

    const realXAxisData = JSON.parse(this.data.get("real_x_axis"));
    const realReceives = JSON.parse(this.data.get("real_receives"));

    departmentNeedReceivesChart = echarts.init(document.getElementById('department-need-receives-chart'));

    const needXAxisData = JSON.parse(this.data.get("need_x_axis"));
    const needLongAccountReceives = JSON.parse(this.data.get("need_long_account_receives"));
    const needShortAccountReceives = JSON.parse(this.data.get("need_short_account_receives"));
    const needShouldReceives = JSON.parse(this.data.get("need_should_receives"));

    departmentRealReceivesStaffChart = echarts.init(document.getElementById('department-real-receives-staff-chart'));

    const realReceivesPerStaff = JSON.parse(this.data.get("real_receives_per_staff"));

    departmentNeedReceivesStaffChart = echarts.init(document.getElementById('department-need-receives-staff-chart'));

    const needShouldReceivesPerStaff = JSON.parse(this.data.get("need_should_receives_per_staff"));
    const paybackRates = JSON.parse(this.data.get("payback_rates"));

    function differentColor(amount) {
      let color;

      if(70 >= amount) {
        color = '#BB332E';
      } else {
        color = '#7E91A5';
      }

      return { value: amount, itemStyle: { color: color }}
    }

    const paybackRatesWithColor = paybackRates.map(differentColor);

    const real_option = {
        title: {
          text: '本年累计实收款'
        },
        legend: {
            data: ['本年累计实收款（万元）'],
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
            formatter: '{value}万'
          }
        },
        series: [{
          name: '本年累计实收款（万元）',
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

    const need_option = {
        title: {
          text: '应收款（财务+业务）'
        },
        legend: {
            data: ['超长帐龄','扣除超长帐龄以外的财务应收','业务应收款'],
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
          bottom: 90
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
          data: needXAxisData,
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
          position: 'left',
          axisLabel: {
            formatter: '{value}万'
          }
        }],
        series: [{
          name: '超长帐龄',
          type: 'bar',
          stack: '应收',
          data: needLongAccountReceives,
          itemStyle: {
            color: '#FA9291'
          },
          label: {
            normal: {
              show: true,
              position: 'insideTop'
            }
          }
        },{
          name: '扣除超长帐龄以外的财务应收',
          type: 'bar',
          stack: '应收',
          data: needShortAccountReceives,
          itemStyle: {
            color: '#A1D189'
          },
          label: {
            normal: {
              show: true,
              position: 'insideTop'
            }
          }
        },{
          name: '业务应收款',
          type: 'bar',
          stack: '应收',
          data: needShouldReceives,
          itemStyle: {
            color: '#738496'
          },
          barMaxWidth: 38,
          label: {
            normal: {
              show: true,
              position: 'top'
            }
          }
        }]
    };

    const real_staff_option = {
        title: {
          text: '一线人均实收款'
        },
        legend: {
            data: ['人均实收款（万元）'],
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
            formatter: '{value}万'
          }
        },
        series: [{
          name: '人均实收款（万元）',
          type: 'bar',
          data: realReceivesPerStaff,
          color: '#738496',
          barMaxWidth: 38,
          label: {
            normal: {
              show: true,
              position: 'top',
              color: '#3E3E3E'
            }
          }
        }]
    };

    const need_staff_option = {
        title: {
          text: '一线人均应收款（财务+业务）'
        },
        legend: {
            data: ['人均应收款（财务+业务）（万元）', '本年回款率'],
            align: 'left'
        },
        grid: {
          left: 60,
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
          data: needXAxisData,
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
          axisLabel: {
            show: true,
            interval: 'auto',
            formatter: '{value}万'
          }
        },{
          type: 'value',
          name: '回款率',
          position: 'right',
          min: 0,
          max: 180,
          interval: Math.ceil(180 / 6),
          axisLine: {
            lineStyle: {
              color: '#675BBA'
            }
          },
          axisLabel: {
            formatter: '{value}%'
          }
        }],
        series: [{
          name: '人均应收款（财务+业务）（万元）',
          type: 'bar',
          data: needShouldReceivesPerStaff,
          color: '#738496',
          barMaxWidth: 38,
          label: {
            normal: {
              show: true,
              position: 'top',
              color: '#3E3E3E'
            }
          }
        },{
          name: '本年回款率',
          type: 'line',
          yAxisIndex: 1,
          symbol: 'circle',
          symbolSize: 8,
          data: paybackRatesWithColor,
          barMaxWidth: 38,
          label: {
            normal: {
              show: true,
              position: 'top',
              distance: 20,
              formatter: '{c}%'
            }
          }
        }]
    };

    function drill_down_real_receives_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const department_name = realXAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          let url;
          if (inIFrame == "true") {
            url = "/report/subsidiary_department_receive?in_iframe=true";
          } else {
            url = "/report/subsidiary_department_receive";
          }

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(companyName) + '&department_name=' + encodeURIComponent(department_name) + '&month_name=' + encodeURIComponent(month_name);
          } else {
            url += '?company_name=' + encodeURIComponent(companyName) + '&department_name=' + encodeURIComponent(department_name) + '&month_name=' + encodeURIComponent(month_name);
          }

          window.location.href = url;
        }
      }
    }

    departmentRealReceivesChart.on('click', drill_down_real_receives_on_click);
    departmentRealReceivesChart.setOption(real_option, false);
    departmentNeedReceivesChart.setOption(need_option, false);
    departmentRealReceivesStaffChart.setOption(real_staff_option, false);
    departmentNeedReceivesStaffChart.setOption(need_staff_option, false);

    setTimeout(() => {
      departmentRealReceivesChart.resize();
      departmentNeedReceivesChart.resize();
      departmentRealReceivesStaffChart.resize();
      departmentNeedReceivesStaffChart.resize();
    }, 200);
  }

  layout() {
    departmentRealReceivesChart.resize();
    departmentNeedReceivesChart.resize();
    departmentRealReceivesStaffChart.resize();
    departmentNeedReceivesStaffChart.resize();
  }

  disconnect() {
    departmentRealReceivesChart.dispose();
    departmentNeedReceivesChart.dispose();
    departmentRealReceivesStaffChart.dispose();
    departmentNeedReceivesStaffChart.dispose();
  }
}
