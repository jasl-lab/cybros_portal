import { Controller } from "stimulus"

let projectTypeSaturationDashboard;

export default class extends Controller {
  connect() {
    projectTypeSaturationDashboard = echarts.init(document.getElementById('project-type-saturation-dashboard'));

    console.log('projectTypeSaturationDashboard');

    setTimeout(() => {
      projectTypeSaturationDashboard.resize();
    }, 200);
  }

  layout() {
    projectTypeSaturationDashboard.resize();
  }

  disconnect() {
    projectTypeSaturationDashboard.dispose();
  }
}
