import { Controller } from "stimulus"

let contractTypesAnalysisPlanChart;
let contractTypesAnalysisWorkingDrawingChart;

export default class extends Controller {
  connect() {
    contractTypesAnalysisPlanChart = echarts.init(document.getElementById('contract-types-analysis-plan-chart'));
    contractTypesAnalysisWorkingDrawingChart = echarts.init(document.getElementById('contract-types-analysis-working-drawing-chart'));

    const planAxis = JSON.parse(this.data.get("plan_axis"));
    const planAmount = JSON.parse(this.data.get("plan_amount"));
    const workingDrawingAxis = JSON.parse(this.data.get("working_drawing_axis"));
    const workingDrawingAmount = JSON.parse(this.data.get("working_drawing_amount"));

    function mapPlan2PieDoughnut(amount, index) {
      return { value: amount, name: planAxis[index] };
    }

    function mapWorkingDrawing2PieDoughnut(amount, index) {
      return { value: amount, name: workingDrawingAxis[index] };
    }

    const planData = planAmount.map(mapPlan2PieDoughnut);
    const workingDrawingData = workingDrawingAmount.map(mapWorkingDrawing2PieDoughnut);

    const plan_option = {
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
          orient: 'vertical',
          left: 10,
          data: planAxis
      },
      series: [
          {
              name: '访问来源',
              type: 'pie',
              radius: ['40%', '70%'],
              avoidLabelOverlap: false,
              label: {
                  show: true
              },
              emphasis: {
                  label: {
                      show: true,
                      fontSize: '30',
                      fontWeight: 'bold'
                  }
              },
              labelLine: {
                  show: false
              },
              data: planData
          }
      ]
    };

    const working_drawing_option = {
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
          orient: 'vertical',
          right: 10,
          data: workingDrawingAxis
      },
      series: [
          {
              name: '访问来源',
              type: 'pie',
              radius: ['40%', '70%'],
              avoidLabelOverlap: false,
              label: {
                  show: true
              },
              emphasis: {
                  label: {
                      show: true,
                      fontSize: '30',
                      fontWeight: 'bold'
                  }
              },
              labelLine: {
                  show: false
              },
              data: workingDrawingData
          }
      ]
    };

    contractTypesAnalysisPlanChart.setOption(plan_option, false);
    contractTypesAnalysisWorkingDrawingChart.setOption(working_drawing_option, false);

    setTimeout(() => {
      contractTypesAnalysisPlanChart.resize();
      contractTypesAnalysisWorkingDrawingChart.resize();
    }, 200);
  }

  layout() {
    contractTypesAnalysisPlanChart.resize();
    contractTypesAnalysisWorkingDrawingChart.resize();
  }

  disconnect() {
    contractTypesAnalysisPlanChart.dispose();
    contractTypesAnalysisWorkingDrawingChart.dispose();
  }
}
