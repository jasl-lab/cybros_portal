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

    function yearsCategorySum(res_value, index) {
      return parseInt(res_value + yearsResidentialConstructionAmount[index] + yearsPublicPlanAmount[index] + yearsPublicConstructionAmount[index]);
    }

    const yearsCategoryTotals = yearsResidentialPlanAmount.map(yearsCategorySum);

    function mapPlan2PieDoughnut(amount, index) {
      return { value: amount, name: planAxis[index] };
    }

    function mapWorkingDrawing2PieDoughnut(amount, index) {
      return { value: amount, name: workingDrawingAxis[index] };
    }

    const planData = planAmount.map(mapPlan2PieDoughnut);

    const workingDrawingData = workingDrawingAmount.map(mapWorkingDrawing2PieDoughnut);

    function piePercentFormater(p) {
      return `${p.percent.toFixed(1)}%`;
    }

    const plan_option = {
      title: {
        text: '子公司前端合同额占比',
        subtext:'单位:百万元',
        left: 'center',
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
              pixelRatio: 2
          }
        }
      },
      tooltip: {
        trigger: 'item',
        formatter: '{a} {b}: {c} ({d}%)'
      },
      series: [{
        name: '前端合同额',
        type: 'pie',
        radius: ['30%', '60%'],
        avoidLabelOverlap: true,
        label: {
          formatter: '{b|{b}} {c}',
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
      },{
        name: '前端合同额',
        type: 'pie',
        radius: ['30%', '60%'],
        avoidLabelOverlap: true,
        label: {
          formatter: piePercentFormater,
          position: 'inner'
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
      }]
    };

    const working_drawing_option = {
      title: {
        text: '子公司后端合同额占比',
        subtext:'单位:百万元',
        left: 'center',
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
              pixelRatio: 2
          }
        }
      },
      tooltip: {
          trigger: 'item',
          formatter: '{a} {b}: {c} ({d}%)'
      },
      series: [{
        name: '后端合同额',
        type: 'pie',
        radius: ['30%', '60%'],
        avoidLabelOverlap: true,
        label: {
          formatter: '{b|{b}} {c}',
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
      },{
        name: '后端合同额',
        type: 'pie',
        radius: ['30%', '60%'],
        avoidLabelOverlap: true,
        label: {
          formatter: piePercentFormater,
          position: 'inner'
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
      }]
    };

    function stackPercentFormater(p) {
      const dataIndex = p.dataIndex
      let sum = 0;
      sum += year_category_stack_option.series[1].data[dataIndex];
      sum += year_category_stack_option.series[2].data[dataIndex];
      sum += year_category_stack_option.series[3].data[dataIndex];
      sum += year_category_stack_option.series[4].data[dataIndex];
      return `${p.data}\n${(p.data / sum * 100.0).toFixed(1)}%`;
    }

    const year_category_stack_option = {
      title: {
        text: '历年土建项目各业务类型合同额占比',
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
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
              pixelRatio: 2
          }
        }
      },
      xAxis: {
        type: 'value'
      },
      yAxis: {
        type: 'category',
        data: yearsCategory
      },
      series: [{
          name: '四项合计',
          type: 'bar',
          barGap: '-100%',
          data: yearsCategoryTotals,
          itemStyle: {
            color: '#DDDDDD'
          },
          label: {
            show: true,
            color: '#353535',
            position: 'right'
          }
        },{
          name: '住宅前端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: stackPercentFormater
          },
          data: yearsResidentialPlanAmount
        },{
          name: '住宅后端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: stackPercentFormater
          },
          data: yearsResidentialConstructionAmount
        },{
          name: '公建前端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: stackPercentFormater
          },
          data: yearsPublicPlanAmount
        },{
          name: '公建后端',
          type: 'bar',
          stack: '总量',
          label: {
            show: true,
            position: 'insideRight',
            formatter: stackPercentFormater
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
