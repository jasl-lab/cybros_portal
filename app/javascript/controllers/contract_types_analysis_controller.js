import { Controller } from "stimulus"

let contractTypesAnalysisPlanChart;
let contractTypesAnalysisWorkingDrawingChart;
let contractTypesAnalysisYearCategoryStackChart;

export default class extends Controller {
  connect() {
    contractTypesAnalysisPlanChart = echarts.init(document.getElementById('contract-types-analysis-plan-chart'));
    contractTypesAnalysisWorkingDrawingChart = echarts.init(document.getElementById('contract-types-analysis-working-drawing-chart'));
    contractTypesAnalysisYearCategoryStackChart = echarts.init(document.getElementById('contract-types-analysis-year-category-stack-chart'));

    const planAxis = JSON.parse(this.data.get("plan_axis"));
    const planAmount = JSON.parse(this.data.get("plan_amount"));
    const workingDrawingAxis = JSON.parse(this.data.get("working_drawing_axis"));
    const workingDrawingAmount = JSON.parse(this.data.get("working_drawing_amount"));
    const yearsCategory = JSON.parse(this.data.get("years_category"));
    const yearsResidentialPlanAmount = JSON.parse(this.data.get("years_residential_plan"));
    const yearsResidentialConstructionAmount = JSON.parse(this.data.get("years_residential_construction"));
    const yearsPublicPlanAmount = JSON.parse(this.data.get("years_public_plan"));
    const yearsPublicConstructionAmount = JSON.parse(this.data.get("years_public_construction"));

    function mapPlan2PieDoughnut(amount, index) {
      return { value: amount, name: planAxis[index] };
    }

    function mapWorkingDrawing2PieDoughnut(amount, index) {
      return { value: amount, name: workingDrawingAxis[index] };
    }

    const planData = planAmount.map(mapPlan2PieDoughnut);
    const workingDrawingData = workingDrawingAmount.map(mapWorkingDrawing2PieDoughnut);

    const plan_option = {
      title: {
        text: '方案',
        left: 'center',
      },
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'horizontal',
        bottom: 20,
        data: planAxis
      },
      series: [
          {
              name: '访问来源',
              type: 'pie',
              radius: ['30%', '60%'],
              avoidLabelOverlap: true,
              label: {
                  show: true
              },
              emphasis: {
                  label: {
                      show: true,
                      fontSize: '22',
                      fontWeight: 'bold'
                  }
              },
              labelLine: {
                  show: true
              },
              data: planData
          }
      ]
    };

    const working_drawing_option = {
      title: {
        text: '施工图',
        left: 'center',
      },
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'horizontal',
        bottom: 20,
        data: workingDrawingAxis
      },
      series: [
          {
              name: '访问来源',
              type: 'pie',
              radius: ['30%', '60%'],
              avoidLabelOverlap: true,
              label: {
                  show: true
              },
              emphasis: {
                  label: {
                      show: true,
                      fontSize: '22',
                      fontWeight: 'bold'
                  }
              },
              labelLine: {
                  show: true
              },
              data: workingDrawingData
          }
      ]
    };

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
        data: ['住宅方案', '住宅施工图', '公建方案', '公建施工图']
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
        data: yearsCategory
      },
      series: [{
          name: '住宅方案',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsResidentialPlanAmount
        },{
          name: '住宅施工图',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsResidentialConstructionAmount
        },{
          name: '公建方案',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsPublicPlanAmount
        },{
          name: '公建施工图',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsPublicConstructionAmount
        }
      ]
    };

    contractTypesAnalysisPlanChart.setOption(plan_option, false);
    contractTypesAnalysisWorkingDrawingChart.setOption(working_drawing_option, false);
    contractTypesAnalysisYearCategoryStackChart.setOption(year_category_stack_option, false);

    setTimeout(() => {
      contractTypesAnalysisPlanChart.resize();
      contractTypesAnalysisWorkingDrawingChart.resize();
      contractTypesAnalysisYearCategoryStackChart.resize();
    }, 200);
  }

  layout() {
    contractTypesAnalysisPlanChart.resize();
    contractTypesAnalysisWorkingDrawingChart.resize();
    contractTypesAnalysisYearCategoryStackChart.resize();
  }

  disconnect() {
    contractTypesAnalysisPlanChart.dispose();
    contractTypesAnalysisWorkingDrawingChart.dispose();
    contractTypesAnalysisYearCategoryStackChart.dispose();
  }
}
