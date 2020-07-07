import { Controller } from "stimulus"

let contractGeographicalAnalysisChinaChart;
let contractGeographicalAnalysisYearCitylevelStackChart;
let contractGeographicalAnalysisYearAreaStackChart;

export default class extends Controller {
  connect() {
    contractGeographicalAnalysisChinaChart = echarts.init(document.getElementById('contract-geographical-analysis-china-chart'));
    contractGeographicalAnalysisYearCitylevelStackChart = echarts.init(document.getElementById('contract-geographical-analysis-year-citylevel-stack-chart'));
    contractGeographicalAnalysisYearAreaStackChart = echarts.init(document.getElementById('contract-geographical-analysis-year-area-stack-chart'));

    const yearCategory = JSON.parse(this.data.get("year_names"));
    const yearsFirstLevelSum = JSON.parse(this.data.get("first_level_sum"));
    const yearsSecondLevelSum = JSON.parse(this.data.get("second_level_sum"));
    const yearsThirdFourthLevelSum = JSON.parse(this.data.get("thirdfourth_level_sum"));
    const yearsSouthWestChinaSum = JSON.parse(this.data.get("south_west_china_sum"));
    const yearsEastChinaSum = JSON.parse(this.data.get("east_china_sum"));
    const yearsSouthChinaSum = JSON.parse(this.data.get("south_china_sum"));
    const yearsCentreChinaSum = JSON.parse(this.data.get("centre_china_sum"));
    const yearsNorthEastChinaSum = JSON.parse(this.data.get("north_east_china_sum"));
    const yearsNorthChinaSum = JSON.parse(this.data.get("north_china_sum"));
    const yearsNorthWestChinaSum = JSON.parse(this.data.get("north_west_china_sum"));
    const provinceSum = JSON.parse(this.data.get("province_sum"));

    function mapProvinceSum2MapData(amount, index) {
      switch(index) {
        case 0:
          return { value: amount, name: '台湾' };
        case 1:
          return { value: amount, name: '河北' };
        case 2:
          return { value: amount, name: '山西' };
        case 3:
          return { value: amount, name: '内蒙古' };
        case 4:
          return { value: amount, name: '辽宁' };
        case 5:
          return { value: amount, name: '吉林' };
        case 6:
          return { value: amount, name: '黑龙江' };

        case 7:
          return { value: amount, name: '江苏' };
        case 8:
          return { value: amount, name: '浙江' };
        case 9:
          return { value: amount, name: '安徽' };
        case 10:
          return { value: amount, name: '福建' };
        case 11:
          return { value: amount, name: '江西' };
        case 12:
          return { value: amount, name: '山东' };
        case 13:
          return { value: amount, name: '河南' };

        case 14:
          return { value: amount, name: '湖北' };
        case 15:
          return { value: amount, name: '湖南' };
        case 16:
          return { value: amount, name: '广东' };
        case 17:
          return { value: amount, name: '广西' };
        case 18:
          return { value: amount, name: '海南' };
        case 19:
          return { value: amount, name: '四川' };
        case 20:
          return { value: amount, name: '贵州' };

        case 21:
          return { value: amount, name: '云南' };
        case 22:
          return { value: amount, name: '西藏' };
        case 23:
          return { value: amount, name: '陕西' };
        case 24:
          return { value: amount, name: '甘肃' };
        case 25:
          return { value: amount, name: '青海' };
        case 26:
          return { value: amount, name: '宁夏' };
        case 27:
          return { value: amount, name: '新疆' };

        case 28:
          return { value: amount, name: '北京' };
        case 29:
          return { value: amount, name: '天津' };
        case 30:
          return { value: amount, name: '上海' };
        case 31:
          return { value: amount, name: '重庆' };
        case 32:
          return { value: amount, name: '香港' };
        case 33:
          return { value: amount, name: '澳门' };
      }
    }

    const map_data = provinceSum.map(mapProvinceSum2MapData);

    const percentFormater = p => {
      let sum = 0;
      for (let i = 0; i < year_city_level_stack_option.series.length; i++) {
        sum += year_city_level_stack_option.series[i].data[p.dataIndex];
      }
      return `${p.data}\n${(p.data/sum * 100).toFixed(1)}%`;
    }

    const map_option = {
      title: {
        text: 'China Provice Data Show',
        subtext: 'Data from 52pojie by para',
        sublink: '',
        left: 'right'
      },
      tooltip: {
        trigger: 'item',
        showDelay: 0,
        transitionDuration: 0.2,
        formatter: function (params) {
          var value = (params.value + '').split('.');
          value = value[0].replace(/(\d{1,3})(?=(?:\d{3})+(?!\d))/g, '$1,');
          return params.name + ': ' + value;
        }
      },
      visualMap: {
        left: 'right',
        min: 1,
        max: 10000,
        inRange: {
          color: ['#313695', '#4575b4', '#74add1', '#abd9e9', '#e0f3f8', '#ffffbf', '#fee090', '#fdae61', '#f46d43', '#d73027', '#a50026']
        },
        text:['High','Low'],           // 文本，默认为数值文本
        calculable: true
      },
      toolbox: {
        show: true,
        //orient: 'vertical',
        left: 'left',
        top: 'top',
        feature: {
          dataView: {readOnly: false},
          restore: {},
          saveAsImage: {}
        }
      },
      series: [{
        type: 'map',
        mapType: 'china',
        roam: false,
        itemStyle:{
            emphasis:{label:{show:true}}
        },
        data: map_data
      }],
    };

    const year_city_level_stack_option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        data: ['一线', '二线', '三四线']
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'value'
      },
      yAxis: {
        type: 'category',
        data: yearCategory
      },
      series: [{
          name: '一线',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsFirstLevelSum
        },{
          name: '二线',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: yearsSecondLevelSum
        },{
          name: '三四线',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsThirdFourthLevelSum
        }
      ]
    };

    const year_area_stack_option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        data: ['西南区域', '华东区域', '华南区域', '华中区域', '东北区域', '华北区域', '西北区域']
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'value'
      },
      yAxis: {
        type: 'category',
        data: yearCategory
      },
      series: [{
          name: '西南区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsSouthWestChinaSum
        },{
          name: '华东区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: yearsEastChinaSum
        },{
          name: '华南区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsSouthChinaSum
        },{
          name: '华中区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: yearsCentreChinaSum
        },{
          name: '东北区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsNorthEastChinaSum
        },{
          name: '华北区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: yearsNorthChinaSum
        },{
          name: '西北区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsNorthWestChinaSum
        }
      ]
    };

    contractGeographicalAnalysisChinaChart.setOption(map_option, false);
    contractGeographicalAnalysisYearCitylevelStackChart.setOption(year_city_level_stack_option, false);
    contractGeographicalAnalysisYearAreaStackChart.setOption(year_area_stack_option, false);

    setTimeout(() => {
      contractGeographicalAnalysisChinaChart.resize();
      contractGeographicalAnalysisYearCitylevelStackChart.resize();
      contractGeographicalAnalysisYearAreaStackChart.resize();
    }, 200);
  }

  layout() {
    contractGeographicalAnalysisChinaChart.resize();
    contractGeographicalAnalysisYearCitylevelStackChart.resize();
    contractGeographicalAnalysisYearAreaStackChart.resize();
  }

  disconnect() {
    contractGeographicalAnalysisChinaChart.dispose();
    contractGeographicalAnalysisYearCitylevelStackChart.dispose();
    contractGeographicalAnalysisYearAreaStackChart.dispose();
  }
}
