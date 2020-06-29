import { Controller } from "stimulus"

let contractTypesAnalysisPlanChart;
let contractTypesAnalysisWorkingDrawingChart;
let contractTypesResidentialPublicDrawingChart;

export default class extends Controller {
  connect() {
    contractTypesAnalysisPlanChart = echarts.init(document.getElementById('contract-types-analysis-plan-chart'));
    contractTypesAnalysisWorkingDrawingChart = echarts.init(document.getElementById('contract-types-analysis-working-drawing-chart'));
    contractTypesResidentialPublicDrawingChart = echarts.init(document.getElementById('contract-types-analysis-residential-public-chart'));

    const planAxis = JSON.parse(this.data.get("plan_axis"));
    const planAmount = JSON.parse(this.data.get("plan_amount"));
    const workingDrawingAxis = JSON.parse(this.data.get("working_drawing_axis"));
    const workingDrawingAmount = JSON.parse(this.data.get("working_drawing_amount"));
    const residentialPublicAxis = JSON.parse(this.data.get("residential_public_axis"));
    const residentialPublicAmount = JSON.parse(this.data.get("residential_public_amount"));

    function mapPlan2PieDoughnut(amount, index) {
      return { value: amount, name: planAxis[index] };
    }

    function mapWorkingDrawing2PieDoughnut(amount, index) {
      return { value: amount, name: workingDrawingAxis[index] };
    }

    function mapResidentialPublic2PieDoughnut(amount, index) {
      return { value: amount, name: residentialPublicAxis[index] };
    }

    const planData = planAmount.map(mapPlan2PieDoughnut);
    const workingDrawingData = workingDrawingAmount.map(mapWorkingDrawing2PieDoughnut);
    const residentialPublicData = residentialPublicAmount.map(mapResidentialPublic2PieDoughnut);

    const plan_option = {
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
          orient: 'horizontal',
          top: 10,
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
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
          orient: 'horizontal',
          top: 10,
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

    const residential_public_option = {
      tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
          orient: 'horizontal',
          data: residentialPublicAxis
      },
      series: [
          {
              name: '住宅公建比例',
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
              data: residentialPublicData
          }
      ]
    };

    contractTypesAnalysisPlanChart.setOption(plan_option, false);
    contractTypesAnalysisWorkingDrawingChart.setOption(working_drawing_option, false);
    contractTypesResidentialPublicDrawingChart.setOption(residential_public_option, false);

    setTimeout(() => {
      contractTypesAnalysisPlanChart.resize();
      contractTypesAnalysisWorkingDrawingChart.resize();
      contractTypesResidentialPublicDrawingChart.resize();
    }, 200);
  }

  layout() {
    contractTypesAnalysisPlanChart.resize();
    contractTypesAnalysisWorkingDrawingChart.resize();
    contractTypesResidentialPublicDrawingChart.resize();
  }

  disconnect() {
    contractTypesAnalysisPlanChart.dispose();
    contractTypesAnalysisWorkingDrawingChart.dispose();
    contractTypesResidentialPublicDrawingChart.dispose();
  }
}
