import { Controller } from "stimulus"

let demoChart

export default class extends Controller {
  connect() {
    demoChart = echarts.init(document.getElementById('demo-chart'));

    let option = {
        title: {
          text: 'ECharts 入门示例'
        },
        tooltip: {},
        legend: {
          data:['销量']
        },
        xAxis: {
          data: ["衬衫","羊毛衫","雪纺衫","裤子","高跟鞋","袜子"]
        },
        yAxis: {},
        series: [{
          name: '销量',
          type: 'bar',
          data: [5, 20, 36, 10, 10, 20]
        }]
    };

    demoChart.setOption(option);
    setInterval(() => {
      demoChart.resize()
    }, 30)
  }

  layout() {
    demoChart.resize()
  }
}
