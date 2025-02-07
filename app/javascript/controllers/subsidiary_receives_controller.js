import { Controller } from "stimulus"

let subsidiaryRealReceivesChart;
let subsidiaryNeedReceivesChart;
let subsidiaryRealReceivesStaffChart;
let subsidiaryNeedReceivesStaffChart;

export default class extends Controller {
  static values = { endOfDate: String }

  connect() {
    const sumOrgNames = JSON.parse(this.data.get("sum_org_names"));
    const inIFrame = this.data.get("in_iframe");

    subsidiaryRealReceivesChart = echarts.init(document.getElementById('subsidiary-real-receives-chart'));

    const realXAxisData = JSON.parse(this.data.get("real_x_axis"));
    const realReceives = JSON.parse(this.data.get("real_receives"));

    subsidiaryNeedReceivesChart = echarts.init(document.getElementById('subsidiary-need-receives-chart'));

    const needXAxisData = JSON.parse(this.data.get("need_x_axis"));
    const needLongAccountReceives = JSON.parse(this.data.get("need_long_account_receives"));
    const needShortAccountReceives = JSON.parse(this.data.get("need_short_account_receives"));
    const needShouldReceives = JSON.parse(this.data.get("need_should_receives"));

    subsidiaryRealReceivesStaffChart = echarts.init(document.getElementById('subsidiary-real-receives-staff-chart'));

    const realReceivesPerWorker = JSON.parse(this.data.get("real_receives_per_worker"));
    const realReceivesPerStaff = JSON.parse(this.data.get("real_receives_per_staff"));
    const realReceivesGap = JSON.parse(this.data.get("real_receives_gap"));

    subsidiaryNeedReceivesStaffChart = echarts.init(document.getElementById('subsidiary-need-receives-staff-chart'));

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
          text: '本年累计实收款(包括市场费)'
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
          barMaxWidth: 48,
          label: {
            show: true,
            position: 'top',
            color: '#171717'
          }
        }]
    };

    let labelBizReceivables;

    if (Date.parse(this.endOfDateValue+"T00:00:00") < Date.parse('2021-03-01T00:00:00')) {
      labelBizReceivables = '业务应收款';
    } else {
      labelBizReceivables = '扣除财务应收的业务应收款';
    }

    const need_option = {
        title: {
          text: '应收款（财务+业务）'
        },
        legend: {
            data: ['超长帐龄','扣除超长帐龄以外的财务应收',labelBizReceivables],
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
            formatter: '{value}百万'
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
            show: true,
            position: 'insideTop'
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
            show: true,
            position: 'insideTop'
          }
        },{
          name: labelBizReceivables,
          type: 'bar',
          stack: '应收',
          data: needShouldReceives,
          itemStyle: {
            color: '#738496'
          },
          barMaxWidth: 48,
          label: {
            show: true,
            position: 'top'
          }
        }]
    };

    const real_staff_option = {
        title: {
          text: '人均实收款'
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
          data: realReceivesPerWorker,
          itemStyle: {
            color: '#DDDDDD'
          },
          barWidth: 20,
          label: {
            show: true,
            color: '#353535',
            position: 'top'
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
            show: true,
            position: 'insideTop',
            fontWeight: 'bold',
            color: '#000000'
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
            show: false
          }
        }]
    };

    const need_staff_option = {
        title: {
          text: '一线人均应收款（财务+业务）及本年回款率'
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
          min: 0,
          max: 100,
          interval: Math.ceil(100 / 5),
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
          barMaxWidth: 48,
          label: {
            show: true,
            position: 'top',
            color: '#3E3E3E'
          }
        },{
          name: '本年回款率',
          type: 'line',
          yAxisIndex: 1,
          symbol: 'circle',
          symbolSize: 8,
          data: paybackRatesWithColor,
          barMaxWidth: 48,
          label: {
            show: true,
            position: 'top',
            distance: 20,
            formatter: '{c}%'
          }
        }]
    };

    function drill_down_real_receives_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const series_company = realXAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          let url;
          if(sumOrgNames.indexOf(series_company) > -1) {
            if (inIFrame == "true") {
              url = "/report/subsidiary_receive?in_iframe=true";
            } else {
              url = "/report/subsidiary_receive";
            }
          } else {
            if (inIFrame == "true") {
              url = "/report/subsidiary_department_receive?in_iframe=true&view_deptcode_sum=true";
            } else {
              url = "/report/subsidiary_department_receive?view_deptcode_sum=true";
            }
          }

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(series_company) + '&month_name=' + encodeURIComponent(month_name);
          } else {
            url += '?company_name=' + encodeURIComponent(series_company) + '&month_name=' + encodeURIComponent(month_name);
          }
          Turbolinks.visit(url);
        }
      }
    }

    function drill_down_need_receives_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          const series_company = needXAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          let url;
          if(sumOrgNames.indexOf(series_company) > -1) {
            if (inIFrame == "true") {
              url = "/report/subsidiary_receive?in_iframe=true";
            } else {
              url = "/report/subsidiary_receive";
            }
          } else {
            if (inIFrame == "true") {
              url = "/report/subsidiary_department_receive?in_iframe=true&view_deptcode_sum=true";
            } else {
              url = "/report/subsidiary_department_receive?view_deptcode_sum=true";
            }
          }

          if (url.indexOf('?') > -1) {
            url += '&company_name=' + encodeURIComponent(series_company) + '&month_name=' + encodeURIComponent(month_name);
          } else {
            url += '?company_name=' + encodeURIComponent(series_company) + '&month_name=' + encodeURIComponent(month_name);
          }
          Turbolinks.visit(url);
        }
      }
    }

    function drill_down_need_receives_staff_on_click(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'line') {
          const company_name = realXAxisData[params.dataIndex];
          const month_name = $('#month_name').val();
          const drill_down_url = '/report/subsidiary_receive/need_receives_staff_drill_down';
          const sent_data = {
            company_name,
            month_name
          };
          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        }
      }
    }

    subsidiaryRealReceivesChart.setOption(real_option, false);
    subsidiaryRealReceivesChart.on('click', drill_down_real_receives_on_click);

    subsidiaryNeedReceivesChart.setOption(need_option, false);
    subsidiaryNeedReceivesChart.on('click', drill_down_need_receives_on_click);

    subsidiaryRealReceivesStaffChart.setOption(real_staff_option, false);

    subsidiaryNeedReceivesStaffChart.setOption(need_staff_option, false);
    subsidiaryNeedReceivesStaffChart.on('click', drill_down_need_receives_staff_on_click);

    setTimeout(() => {
      subsidiaryRealReceivesChart.resize();
      subsidiaryNeedReceivesChart.resize();
      subsidiaryRealReceivesStaffChart.resize();
      subsidiaryNeedReceivesStaffChart.resize();
    }, 200);
  }

  layout() {
    subsidiaryRealReceivesChart.resize();
    subsidiaryNeedReceivesChart.resize();
    subsidiaryRealReceivesStaffChart.resize();
    subsidiaryNeedReceivesStaffChart.resize();
  }

  disconnect() {
    subsidiaryRealReceivesChart.dispose();
    subsidiaryNeedReceivesChart.dispose();
    subsidiaryRealReceivesStaffChart.dispose();
    subsidiaryNeedReceivesStaffChart.dispose();
  }
}
