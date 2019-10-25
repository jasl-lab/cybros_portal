import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const center = new TMap.LatLng(31.228177,121.487003); //设置中心点坐标
    //初始化地图
    const map = new TMap.Map("full-map", {
        center: center
    });
  }

  disconnect() {
  }
}
