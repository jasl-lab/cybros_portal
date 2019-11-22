import { Controller } from "stimulus"

window.initFullMap = function () {
  const mapPoint = $('#full-map').data("full-map-map_point");
  const avgLat = $('#full-map').data("full-map-avg_lat");
  const avgLng = $('#full-map').data("full-map-avg_lng");

  const center = new TMap.LatLng(avgLat,avgLng); // 设置中心点坐标

  window.full_map = new TMap.Map("full-map", {
    center
  });

  const geometries = mapPoint.map(function(m) {
    return { styleId: 'marker',
      position: new TMap.LatLng(m.lat, m.lng),
      properties: {
        title: m.title,
        owner: m.owner,
        contracts: m.contracts
      }
    };
  });

  var marker = new TMap.MultiMarker({
    id: 'marker-layer',
    map: window.full_map,
    styles: {
      "marker": new TMap.MarkerStyle({
          "width": 25,
          "height": 35,
          "anchor": { x: 16, y: 32 },
          "src": '/images/marker_default.png'
      })
    },
    geometries: geometries
  });

  var infoWindow = new TMap.InfoWindow({
    map: window.full_map,
    position: new TMap.LatLng(31.228177,121.487003),
    offset: { x: -8, y: -32 } // 设置信息窗相对position偏移像素
  });
  infoWindow.close();// 初始关闭信息窗关闭

  marker.on("click", function (evt) {
    infoWindow.open();
    infoWindow.setPosition(evt.geometry.position);
    const links = evt.geometry.properties.contracts.map(function(m) {
      return `<a href='${m.url}' target='_blank'>${m.docname}</a>`
    }).join("<br />");
    infoWindow.setContent(evt.geometry.properties.title.toString() + '<br />' + evt.geometry.properties.owner.toString() + '<br />' + links);
  })
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
