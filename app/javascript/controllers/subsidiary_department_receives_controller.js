import { Controller } from "stimulus"

let departmentRealReceivesChart;
let departmentNeedReceivesChart;
let departmentRealReceivesStaffChart;
let departmentNeedReceivesStaffChart;

export default class extends Controller {
  connect() {
    const sumDeptNames = JSON.parse(this.data.get("sum_dept_names"));
    const inIFrame = this.data.get("in_iframe");
    const viewDeptcodeSum = this.data.get("view_deptcode_sum") == "true";
    const companyName = this.data.get("company_name");

    departmentRealReceivesChart = echarts.init(document.getElementById('department-real-receives-chart'));

    const realXAxisCode = JSON.parse(this.data.get("real_x_axis_code"));
    const realXAxisData = JSON.parse(this.data.get("real_x_axis"));
    const realReceives = JSON.parse(this.data.get("real_receives"));

    departmentNeedReceivesChart = echarts.init(document.getElementById('department-need-receives-chart'));

    const needXAxisCode = JSON.parse(this.data.get("need_x_axis_code"));
    const needXAxisData = JSON.parse(this.data.get("need_x_axis"));
    const needLongAccountReceives = JSON.parse(this.data.get("need_long_account_receives"));
    const needShortAccountReceives = JSON.parse(this.data.get("need_short_account_receives"));
    const needShouldReceives = JSON.parse(this.data.get("need_should_receives"));

    departmentRealReceivesStaffChart = echarts.init(document.getElementById('department-real-receives-staff-chart'));

    const realReceivesPerWorker = JSON.parse(this.data.get("real_receives_per_worker"));
    const realReceivesPerStaff = JSON.parse(this.data.get("real_receives_per_staff"));
    const realReceivesGap = JSON.parse(this.data.get("real_receives_gap"));

    const realReceivePerStaffRef = this.data.get("real_receive_per_staff_ref");

    departmentNeedReceivesStaffChart = echarts.init(document.getElementById('department-need-receives-staff-chart'));

    const needShouldReceivesPerStaff = JSON.parse(this.data.get("need_should_receives_per_staff"));
    const needShouldReceivesPerStaffMax = JSON.parse(this.data.get("need_should_receives_per_staff_max"));

    const paybackRates = JSON.parse(this.data.get("payback_rates"));

    function realReceivePerWorkerRefColor(amount) {
      let color;

      if(amount <= realReceivePerStaffRef) {
        color = '#BB332E';
      } else {
        color = '#7E91A5';
      }

      return { value: amount, itemStyle: { color: color }}
    }

    const realReceivesPerWorkerWithColor = realReceivesPerWorker.map(realReceivePerWorkerRefColor);

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
          text: '本年累计实收款',
          textStyle: {
            fontSize: 12,
          }
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
          stack: '总量',
          data: realReceives,
          itemStyle: {
            color: '#738496'
          },
          label: {
            normal: {
              show: true,
              position: 'inside'
            }
          }
        }]
    };

    const need_option = {
        title: {
          text: '应收款（财务+业务）',
          textStyle: {
            fontSize: 12,
          }
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
        text: '人均实收款',
        textStyle: {
          fontSize: 12,
        }
      },
      legend: {
          data: ['一线人均实收款（万元）','全员人均实收款（万元）'],
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
        name: '一线人均实收款（万元）',
        type: 'bar',
        barWidth: '30%',
        barGap: '-100%',
        data: realReceivesPerWorkerWithColor,
        itemStyle: {
          color: '#DDDDDD'
        },
        barWidth: 20,
        label: {
          normal: {
            show: true,
            color: '#353535',
            position: 'top'
          }
        },
        markLine: {
          label: {
            formatter: '{c}万元预警线'
          },
          lineStyle: {
            type: 'solid',
            width: 1
          },
          data: [
            {
              yAxis: realReceivePerStaffRef
            }
          ]
        }
      },{
        name: '全员人均实收款（万元）',
        type: 'bar',
        stack: '实收',
        data: realReceivesPerStaff,
        itemStyle: {
          color: '#60A0A8'
        },
        barWidth: 20,
        label: {
          normal: {
            show: true,
            position: 'insideTop',
            fontWeight: 'bold',
            color: '#000000'
          }
        }
      },{
        name: '一线全员差额（万元）',
        type: 'bar',
        stack: '实收',
        data: realReceivesGap,
        itemStyle: {
          color: '#DDDDDD'
        },
        barWidth: 20,
        label: {
          normal: {
            show: false
          }
        }
      }]
    };

    const need_staff_option = {
        title: {
          text: '一线人均应收款（财务+业务）及本年回款率',
          textStyle: {
            fontSize: 12,
          }
        },
        legend: {
            data: ['人均应收款（财务+业务）（万元）'],
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
          name: '人均应收款',
          position: 'left',
          min: 0,
          max: needShouldReceivesPerStaffMax,
          interval: Math.ceil(needShouldReceivesPerStaffMax / 5),
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
          max: 200,
          interval: Math.ceil(200 / 5),
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
          const department_code = realXAxisCode[params.dataIndex];
          const month_name = $('#month_name').val();

          if(sumDeptNames.indexOf(department_name) > -1) {
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

            if (viewDeptcodeSum) {
              url += '&view_deptcode_sum=true';
            }

            window.location.href = url;
          }
        }
      }
    }

    function drill_down_need_receives_staff_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'line') {
          const department_name = needXAxisData[params.dataIndex];
          const department_code = needXAxisCode[params.dataIndex];
          const month_name = $('#month_name').val();
          const drill_down_url = '/report/subsidiary_department_receive/need_receives_pay_rates_drill_down';
          const sent_data = {
            company_name: companyName,
            department_name,
            department_code,
            month_name
          };
          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        }
      }
    }

    departmentRealReceivesChart.setOption(real_option, false);
    departmentRealReceivesChart.on('click', drill_down_real_receives_on_click);

    departmentNeedReceivesChart.setOption(need_option, false);
    departmentRealReceivesStaffChart.setOption(real_staff_option, false);

    departmentNeedReceivesStaffChart.setOption(need_staff_option, false);
    departmentNeedReceivesStaffChart.on('click', drill_down_need_receives_staff_on_click);

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
