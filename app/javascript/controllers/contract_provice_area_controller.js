import { Controller } from "stimulus"

import { mapProvinceSum2MapData } from "../echart-helper";

let contractProviceAreaChinaChart;

export default class extends Controller {
  connect() {
    contractProviceAreaChinaChart = echarts.init(document.getElementById('contract-provice-area-china-chart'));

    const provinceSum = JSON.parse(this.data.get("province_sum"));
    const yearRateSum = JSON.parse(this.data.get("year_rate_sum"));
    const previousYearRateSum = JSON.parse(this.data.get("previous_year_rate_sum"));

    const map_data = provinceSum.map(mapProvinceSum2MapData);

    const mapFeatures = echarts.getMap('china').geoJson.features;

    let geoCoordMap = {};

    mapFeatures.forEach(function(v) {
      // 地区名称
      var name = v.properties.name;
      // 地区经纬度
      geoCoordMap[name] = v.properties.cp;
    });

    function convertData(data) {
      var res = [];
      for (var i = 0; i < data.length; i++) {
        var geoCoord = geoCoordMap[data[i].name];
        if (geoCoord) {
          console.log(data[i]);
          console.log(geoCoord);
          res.push({
            name: data[i].name,
            value: geoCoord.concat([yearRateSum[i], previousYearRateSum[i]])
          });
        }
      }
      return res;
    }

    const scatter_data = convertData(map_data);
    console.log(scatter_data);
    const map_option = {
      title: [{
        text: '全国开工面积 省份分布',
        subtext: '单位：元/万平米',
        sublink: '',
        left: 'right'
      },{
        text: '新开工面积（万㎡）',
        textStyle: {
          color: '#2D3E53',
          fontSize: 18
        },
        right: '2%',
        top: '90%'
      },{
        text: '市场占有率（%）',
        textStyle: {
          color: '#2D3E53',
          fontSize: 12
        },
        right: '68%',
        top: '70%'
      },{
        text: '>= 10% ●',
        textStyle: {
          color: '#441704',
          fontSize: 12
        },
        right: '72%',
        top: '73%'
      },{
        text: '>= 5% ●',
        textStyle: {
          color: '#C14107',
          fontSize: 12
        },
        right: '73%',
        top: '76%'
      },{
        text: '>= 3% ●',
        textStyle: {
          color: '#F87235',
          fontSize: 12
        },
        right: '73%',
        top: '79%'
      },{
        text: '>= 1% ●',
        textStyle: {
          color: '#F87235',
          fontSize: 12
        },
        right: '73%',
        top: '82%'
      }],
      grid: {
        left: '0',
        right: '0'
      },
      tooltip: {
        trigger: 'item',
        showDelay: 30,
        transitionDuration: 0.2,
        formatter: function (params) {
          var value = (params.value + '').split('.');
          value = value[0].replace(/(\d{1,3})(?=(?:\d{3})+(?!\d))/g, '$1,');
          return params.name + ': ' + value;
        }
      },
      visualMap: {
        show: true,
        left: 'right',
        min: Math.min(...provinceSum)*0.05,
        max: Math.max(...provinceSum),
        inRange: {
          color: ['#04387b', '#467bc0'] // 蓝绿
        },
        seriesIndex: [1],
        calculable: true
      },
      toolbox: {
        show: true,
        left: 'left',
        top: 'top',
        feature: {
          dataView: { readOnly: false },
          restore: {},
          saveAsImage: {}
        }
      },
      geo: {
          show: true,
          map: 'china',
          label: {
              normal: {
                  show: false
              },
              emphasis: {
                  show: false,
              }
          },
          roam: false,
          itemStyle: {
              normal: {
                  areaColor: '#023677',
                  borderColor: '#1180c7',
              },
              emphasis: {
                  areaColor: '#4499d0',
              }
          }
      },
      series: [{
        name: '占有率',
        type: 'scatter',
        coordinateSystem: 'geo',
        data: scatter_data,
        symbolSize: 10,
        label: {
          normal: {
            formatter: '{b}',
            position: 'right',
            color: 'black',
            show: true
          },
          emphasis: {
            color: 'red',
            show: true
          }
        },
        itemStyle: {
          normal: {
            color: function(p) {
              var rate = p.value[2];
              if (rate >= 10) {
                return '#441704';
              } else if (rate >= 5) {
                return '#C14107';
              } else if (rate >= 3) {
                return '#F87235';
              } else if (rate >= 1) {
                return '#F87235';
              } else {
                return '#FFFFFF';
              }
            }
          }
        },
        tooltip: {
          formatter: function ( p ) { 
            return `${p.seriesName}：${p.value[2]}%<br />上年同期：${p.value[3]}%`;
          },
        }
      },{
          type: 'map',
          map: 'china',
          geoIndex: 0,
          aspectScale: 0.75, //长宽比
          showLegendSymbol: false, // 存在legend时显示
          label: {
            normal: {
              show: true
            },
            emphasis: {
              show: false
            }
          },
          roam: true,
          itemStyle: {
            normal: {
              areaColor: '#031525',
              borderColor: '#3B5077',
            },
            emphasis: {
              areaColor: '#2B91B7'
            }
          },
          animation: false,
          data: map_data
        }],
    };

    contractProviceAreaChinaChart.setOption(map_option, false);

    setTimeout(() => {
      contractProviceAreaChinaChart.resize();
    }, 200);
  }

  layout() {
    contractProviceAreaChinaChart.resize();
  }

  disconnect() {
    contractProviceAreaChinaChart.dispose();
  }
}
