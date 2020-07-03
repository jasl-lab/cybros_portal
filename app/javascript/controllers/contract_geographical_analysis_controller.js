import { Controller } from "stimulus"

let contractGeographicalAnalysisYearCategoryStackChart;

export default class extends Controller {
  connect() {
    contractGeographicalAnalysisYearCategoryStackChart = echarts.init(document.getElementById('contract-geographical-analysis-year-category-stack-chart'));

    const yearCategory = JSON.parse(this.data.get("year_names"));
    const yearsFirstLevelSum = JSON.parse(this.data.get("first_level_sum"));
    const yearsSecondLevelSum = JSON.parse(this.data.get("second_level_sum"));
    const yearsThirdFourthLevelSum = JSON.parse(this.data.get("thirdfourth_level_sum"));

    const percentFormater = p => {
      let sum = 0;
      for (let i = 0; i < year_category_stack_option.series.length; i++) {
        sum += year_category_stack_option.series[i].data[p.dataIndex];
      }
      return `${p.data}\n${(p.data/sum * 100).toFixed(1)}%`;
    }
    const year_category_stack_option = {
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
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsFirstLevelSum
        },{
          name: '二线',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsSecondLevelSum
        },{
          name: '三四线',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsThirdFourthLevelSum
        }
      ]
    };

    contractGeographicalAnalysisYearCategoryStackChart.setOption(year_category_stack_option, false);

    setTimeout(() => {
      contractGeographicalAnalysisYearCategoryStackChart.resize();
    }, 200);
  }

  layout() {
    contractGeographicalAnalysisYearCategoryStackChart.resize();
  }

  disconnect() {
    contractGeographicalAnalysisYearCategoryStackChart.dispose();
  }
}
