import { Controller } from "stimulus"

import { mapProvinceSum2MapData } from "../echart-helper";

let contractGeographicalAnalysisChinaChart;
let contractGeographicalAnalysisYearCitylevelStackChart;
let contractGeographicalAnalysisAreaBarChart;

export default class extends Controller {
  connect() {
    contractGeographicalAnalysisChinaChart = echarts.init(document.getElementById('contract-geographical-analysis-china-chart'));
    contractGeographicalAnalysisYearCitylevelStackChart = echarts.init(document.getElementById('contract-geographical-analysis-year-citylevel-stack-chart'));
    contractGeographicalAnalysisAreaBarChart = echarts.init(document.getElementById('contract-geographical-analysis-area-bar-chart'));

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
    const provinceSum = JSON.parse(this.data.get("province_sum"));

    function buildAreaBarSeries(year, index) {
      const series = [southWestChinaYears[index], eastChinaYears[index],southChinaYears[index],centreChinaYears[index],northEastChinaYears[index],northChinaYears[index],northWestChinaYears[index]]
      return {
          name: year.toString(),
          type: 'bar',
          barGap: 0,
          label: {
            show: true,
            position: 'insideTop'
          },
          data: series,
          barMaxWidth: 20
        };
    }
    const areaBarSeries = yearCategory.reverse().map(buildAreaBarSeries);

    const map_data = provinceSum.map(mapProvinceSum2MapData);

    const percentFormater = p => {
      let sum = 0;
      for (let i = 0; i < year_city_level_stack_option.series.length; i++) {
        sum += year_city_level_stack_option.series[i].data[p.dataIndex];
      }
      return `${p.data}\n${(p.data/sum * 100).toFixed(0)}%`;
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
        min: Math.min(...provinceSum)*0.05,
        max: Math.max(...provinceSum),
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
        map: 'china',
        roam: false,
        emphasis: {
          label: { show:true }
        },
        data: map_data
      }],
    };

    const year_city_level_stack_option = {
      title: {
        text: '合同额 按城市类型',
        left: 'center'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
            pixelRatio: 2
          }
        }
      },
      legend: {
        data: ['一线', '二线', '非一二线'],
        left: 'center',
        top: '33'
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: yearCategory,
      },
      yAxis: {
        type: 'value',
        name: '百万元',
      },
      series: [{
          name: '一线',
          type: 'bar',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsFirstLevelSum,
          barMaxWidth: 38
        },{
          name: '二线',
          type: 'bar',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsSecondLevelSum,
          barMaxWidth: 38
        },{
          name: '非一二线',
          type: 'bar',
          label: {
            show: true,
            position: 'insideTop',
            formatter: percentFormater
          },
          data: yearsThirdFourthLevelSum,
          barMaxWidth: 38
        }
      ]
    };

    const area_bar_option = {
      title: {
        text: '合同额 按区域',
        left: 'center'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
              pixelRatio: 2
          }
        }
      },
      legend: {
        data: yearCategory.map(String),
        left: 'center',
        top: '33'
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
        type: 'value',
        name: '百万元',
      },
      series: areaBarSeries
    };

    const mapFeatures = echarts.getMap('china');

    if (mapFeatures === null) {
      $.get('/china.geojson', function (chinaJson) {
        echarts.registerMap('china', chinaJson);
        contractGeographicalAnalysisChinaChart.setOption(map_option, false);
      });
    } else {
      contractGeographicalAnalysisChinaChart.setOption(map_option, false);
    }
    contractGeographicalAnalysisYearCitylevelStackChart.setOption(year_city_level_stack_option, false);
    contractGeographicalAnalysisAreaBarChart.setOption(area_bar_option, false);

    setTimeout(() => {
      contractGeographicalAnalysisChinaChart.resize();
      contractGeographicalAnalysisYearCitylevelStackChart.resize();
      contractGeographicalAnalysisAreaBarChart.resize();
    }, 200);
  }

  layout() {
    contractGeographicalAnalysisChinaChart.resize();
    contractGeographicalAnalysisYearCitylevelStackChart.resize();
    contractGeographicalAnalysisAreaBarChart.resize();
  }

  disconnect() {
    contractGeographicalAnalysisChinaChart.dispose();
    contractGeographicalAnalysisYearCitylevelStackChart.dispose();
    contractGeographicalAnalysisAreaBarChart.dispose();
  }
}
