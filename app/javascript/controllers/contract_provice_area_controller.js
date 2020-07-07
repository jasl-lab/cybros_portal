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
        subtext: '单位：元/平米',
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
        max: 20400000,
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
