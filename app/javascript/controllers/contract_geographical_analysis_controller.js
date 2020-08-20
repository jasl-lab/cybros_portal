import { Controller } from "stimulus"

import { mapProvinceSum2MapData } from "../echart-helper";

let contractGeographicalAnalysisChinaChart;
let contractGeographicalAnalysisYearCitylevelStackChart;
let contractGeographicalAnalysisAreaBarChart;
let contractGeographicalAnalysisYearAreaStackChart;

export default class extends Controller {
  connect() {
    contractGeographicalAnalysisChinaChart = echarts.init(document.getElementById('contract-geographical-analysis-china-chart'));
    contractGeographicalAnalysisYearCitylevelStackChart = echarts.init(document.getElementById('contract-geographical-analysis-year-citylevel-stack-chart'));
    contractGeographicalAnalysisAreaBarChart = echarts.init(document.getElementById('contract-geographical-analysis-area-bar-chart'));
    contractGeographicalAnalysisYearAreaStackChart = echarts.init(document.getElementById('contract-geographical-analysis-year-area-stack-chart'));

    const yearCategory = JSON.parse(this.data.get("year_names"));
    const yearsFirstLevelSum = JSON.parse(this.data.get("first_level_sum"));
    const yearsSecondLevelSum = JSON.parse(this.data.get("second_level_sum"));
    const yearsThirdFourthLevelSum = JSON.parse(this.data.get("thirdfourth_level_sum"));

    const southWestChinaYears = JSON.parse(this.data.get("south_west_china_years"));
    const eastChinaYears = JSON.parse(this.data.get("east_china_years"));
    const southChinaYears = JSON.parse(this.data.get("south_china_years"));
    const centreChinaYears = JSON.parse(this.data.get("centre_china_years"));
    const northEastChinaYears = JSON.parse(this.data.get("north_east_china_years"));
    const northChinaYears = JSON.parse(this.data.get("north_china_years"));
    const northWestChinaYears = JSON.parse(this.data.get("north_west_china_years"));

    function buildAreaBarSeries(year, index) {
      const series = [southWestChinaYears[index], eastChinaYears[index],southChinaYears[index],centreChinaYears[index],northEastChinaYears[index],northChinaYears[index],northWestChinaYears[index]]
      return {
          name: year,
          type: 'bar',
          barGap: 0,
          label: {
            show: true,
            position: 'insideTop'
          },
          data: series
        };
    }
    const areaBarSeries = yearCategory.reverse().map(buildAreaBarSeries);

    const provinceSum = JSON.parse(this.data.get("province_sum"));

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
        text: '全国合同额 省份分布',
        subtext: '单位：百万元',
        sublink: '',
        left: 'right'
      },
      tooltip: {
        trigger: 'item',
        showDelay: 0,
        transitionDuration: 0.2,
        formatter: function (params) {
          var value = params.value + '';
          return params.name + ': ' + value;
        }
      },
      visualMap: {
        left: 'right',
        min: 1,
        max: 10000,
        inRange: {
          color: ['#F2F2F2', '#DFF0FA', '#9ED3EF','#9ED3EF','#17628A','#092838']
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
        data: ['一线', '二线', '非一二线']
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
          name: '非一二线',
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

    const area_bar_option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        data: yearCategory.reverse()
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        axisTick: { show: false },
        data: ['西南区域', '华东区域', '华南区域', '华中区域', '东北区域', '华北区域', '西北区域']
      },
      yAxis: {
        type: 'value'
      },
      series: areaBarSeries
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
      xAxis: [{
        type: 'value'
      }],
      yAxis: [{
        type: 'category',
        data: yearCategory.reverse()
      }],
      series: [{
          name: '西南区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: southWestChinaYears
        },{
          name: '华东区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: eastChinaYears
        },{
          name: '华南区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: southChinaYears
        },{
          name: '华中区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: centreChinaYears
        },{
          name: '东北区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: northEastChinaYears
        },{
          name: '华北区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideBottom',
            formatter: percentFormater
          },
          data: northChinaYears
        },{
          name: '西北区域',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: northWestChinaYears
        }
      ]
    };

    contractGeographicalAnalysisChinaChart.setOption(map_option, false);
    contractGeographicalAnalysisYearCitylevelStackChart.setOption(year_city_level_stack_option, false);
    contractGeographicalAnalysisAreaBarChart.setOption(area_bar_option, false);
    contractGeographicalAnalysisYearAreaStackChart.setOption(year_area_stack_option, false);

    setTimeout(() => {
      contractGeographicalAnalysisChinaChart.resize();
      contractGeographicalAnalysisYearCitylevelStackChart.resize();
      contractGeographicalAnalysisAreaBarChart.resize();
      contractGeographicalAnalysisYearAreaStackChart.resize();
    }, 200);
  }

  layout() {
    contractGeographicalAnalysisChinaChart.resize();
    contractGeographicalAnalysisYearCitylevelStackChart.resize();
    contractGeographicalAnalysisAreaBarChart.resize();
    contractGeographicalAnalysisYearAreaStackChart.resize();
  }

  disconnect() {
    contractGeographicalAnalysisChinaChart.dispose();
    contractGeographicalAnalysisYearCitylevelStackChart.dispose();
    contractGeographicalAnalysisAreaBarChart.dispose();
    contractGeographicalAnalysisYearAreaStackChart.dispose();
  }
}
