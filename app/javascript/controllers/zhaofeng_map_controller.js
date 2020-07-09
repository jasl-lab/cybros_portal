import { Controller } from "stimulus"
require("echarts/map/zhaofeng")

let zhaoFengMapChart;

export default class extends Controller {
  connect() {
    zhaoFengMapChart = echarts.init(document.getElementById('zhaofeng-map-chart'));

    const map_option = {
      title: {
        text: '测试自制地图绘制',
        subtext: '单位：0 元/平米',
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
        max: 10,
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
        mapType: 'zhaofeng',
        roam: true,
        itemStyle:{
            emphasis:{label:{show:true}}
        },
        data: [
          { name: "第六人民医院", value: 9 },
          { name: "位育学校北校区", value: 3 },
          { name: "兆丰环球大厦", value: 10 },
          { name: "光启城", value: 8 },
          { name: "装修城", value: 5 },
          { name: "刘家香", value: 2 },
          { name: "兆丰隔壁", value: 1 },
        ]
      }],
    };

    zhaoFengMapChart.setOption(map_option, false);

    setTimeout(() => {
      zhaoFengMapChart.resize();
    }, 200);
  }

  layout() {
    zhaoFengMapChart.resize();
  }

  disconnect() {
    zhaoFengMapChart.dispose();
  }
}
