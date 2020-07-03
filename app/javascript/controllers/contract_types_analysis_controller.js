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
        text: '子公司前端合同额占比',
        subtext:'单位:百万元',
        left: 'center',
      },
      tooltip: {
          trigger: 'item',
          formatter: '{a} {b}: {c} ({d}%)'
      },
      series: [
          {
              name: '前端合同额',
              type: 'pie',
              radius: ['30%', '60%'],
              avoidLabelOverlap: true,
              label: {
                  formatter: '{b|{b}}{c} {per|{d}%}',
                  rich: {
                      b: {
                          fontSize: 12,
                          lineHeight: 20
                      },
                      per: {
                          color: '#eee',
                          backgroundColor: '#334455',
                          padding: [1, 2],
                          borderRadius: 2
                      }
                  }
              },
              emphasis: {
                  label: {
                      show: true,
                      fontSize: '16',
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
        text: '子公司后端合同额占比',
        subtext:'单位:百万元',
        left: 'center',
      },
      tooltip: {
          trigger: 'item',
          formatter: '{a} {b}: {c} ({d}%)'
      },
      series: [
          {
              name: '后端合同额',
              type: 'pie',
              radius: ['30%', '60%'],
              avoidLabelOverlap: true,
              label: {
                  formatter: '{b|{b}}{c} {per|{d}%}',
                  rich: {
                      b: {
                          fontSize: 12,
                          lineHeight: 20
                      },
                      per: {
                          color: '#eee',
                          backgroundColor: '#334455',
                          padding: [1, 2],
                          borderRadius: 2
                      }
                  }
              },
              emphasis: {
                  label: {
                      show: true,
                      fontSize: '16',
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
      title: {
        text: '土建项目各业务类型合同额占比情况',
        subtext:'单位:百万元',
        left: 'center',
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      legend: {
        data: ['住宅前端', '住宅后端', '公建前端', '公建后端'],
        left: 'center',
        top: '50'
      },
      grid: {
        left: '3%',
        right: '4%',
        top: '80',
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
          name: '住宅前端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsResidentialPlanAmount
        },{
          name: '住宅后端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsResidentialConstructionAmount
        },{
          name: '公建前端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: percentFormater
          },
          data: yearsPublicPlanAmount
        },{
          name: '公建后端',
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
