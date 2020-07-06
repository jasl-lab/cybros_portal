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

    const map_data =
    [
      {"value":16669,"name":"\u6c5f\u82cf"},
      {"value":16550,"name":"\u5e7f\u4e1c"},
      {"value":15910,"name":"\u6d59\u6c5f"},
      {"value":12081,"name":"\u5c71\u4e1c"},
      {"value":9210,"name":"\u6cb3\u5317"},
      {"value":6802,"name":"\u6cb3\u5357"},
      {"value":6351,"name":"\u56db\u5ddd"},
      {"value":5626,"name":"\u8fbd\u5b81"},
      {"value":4334,"name":"\u798f\u5efa"},
      {"value":4290,"name":"\u5b89\u5fbd"},
      {"value":4224,"name":"\u6e56\u5357"},
      {"value":4086,"name":"\u6e56\u5317"},
      {"value":3766,"name":"\u6c5f\u897f"},
      {"value":3345,"name":"\u5e7f\u897f\u58ee\u65cf\u81ea\u6cbb\u533a"},
      {"value":3134,"name":"\u5317\u4eac\u5e02"},
      {"value":3057,"name":"\u91cd\u5e86\u5e02"},
      {"value":2751,"name":"\u4e91\u5357"},
      {"value":2693,"name":"\u9ed1\u9f99\u6c5f"},
      {"value":2617,"name":"\u9655\u897f"},
      {"value":2264,"name":"\u5929\u6d25\u5e02"},
      {"value":2029,"name":"\u5409\u6797"},
      {"value":1966,"name":"\u5c71\u897f"},
      {"value":1853,"name":"\u8d35\u5dde"},
      {"value":1489,"name":"\u5185\u8499\u53e4\u81ea\u6cbb\u533a"},
      {"value":1348,"name":"\u65b0\u7586\u7ef4\u543e\u5c14\u81ea\u6cbb\u533a"},
      {"value":1097,"name":"\u7518\u8083"},
      {"value":543,"name":"\u6d77\u5357"},
      {"value":472,"name":"\u5b81\u590f\u56de\u65cf\u81ea\u6cbb\u533a"},
      {"value":374,"name":"\u9752\u6d77"},
      {"value":105,"name":"\u897f\u85cf\u81ea\u6cbb\u533a"},
      {"value":3,"name":"重庆"},
      {"value":2,"name":"\u9999\u6e2f\u7279\u522b\u884c\u653f\u533a"},
      {"value":1,"name":"\u6fb3\u95e8\u7279\u522b\u884c\u653f\u533a"}
    ]
    ;

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
