import { Controller } from "stimulus"

import { mapProvinceSum2MapData } from "../echart-helper";

let contractProviceAreaChinaChart;

export default class extends Controller {
  connect() {
    contractProviceAreaChinaChart = echarts.init(document.getElementById('contract-provice-area-china-chart'));

    const provinceSum = JSON.parse(this.data.get("province_sum"));

    const map_data = provinceSum.map(mapProvinceSum2MapData);

    const map_option = {
      title: {
        text: '全国开工面积 省份分布',
        subtext: '单位：元/万平米',
        sublink: '',
        left: 'right'
      },
      grid: {
        left: '0',
        right: '0'
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
        min: Math.max(...provinceSum)*0.05,
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
        mapType: 'china',
        roam: false,
        itemStyle:{
            emphasis:{label:{show:true}}
        },
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
