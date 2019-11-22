import { Controller } from "stimulus"

window.initFullMap = function () {
  const minLat = $('#full-map').data("full-map-min_lat");
  const maxLat = $('#full-map').data("full-map-max_lat");
  const minLng = $('#full-map').data("full-map-min_lng");
  const maxLng = $('#full-map').data("full-map-max_lng");

  const sw = new TMap.LatLng(minLat, minLng);
  const ne = new TMap.LatLng(maxLat, maxLng);
  const map_bound = new TMap.LatLngBounds(sw, ne);

  window.full_map = new TMap.Map("full-map", {
    boundary: map_bound
  });
}

export default class extends Controller {
  connect() {
    if (typeof TMap != 'object') {
      //创建script标签，并设置src属性添加到body中
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "https://map.qq.com/api/gljs?v=1.exp&key=EJPBZ-7TEKU-DLQVP-2K6EE-XZ6O6-NWBKM&callback=initFullMap";
      document.body.appendChild(script);
    } else {
      window.initFullMap();
    }
  }

  disconnect() {
    window.full_map.destroy();
    window.full_map = null;
  }
}
