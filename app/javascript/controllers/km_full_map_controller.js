import { Controller } from "stimulus"

window.initKmFullMap = function () {
  const mapPoint = $('#full-map').data("contracts-full-map-map_point");

  const center = new TMap.LatLng(30.576473,112.224908);
  const zoom = 4;


  window.full_map = new TMap.Map("km-full-map", {
    center,
    zoom
  });

  const geometries = mapPoint.map(function(m) {
    const properties = {
      title: m.title,
      project_frame_name: m.project_frame_name,
      project_code: m.project_code,
      trace_state: m.trace_state,
      scale_area: m.scale_area,
      province: m.province,
      city: m.city,
      project_items: m.project_items
    }
    return { styleId: 'marker',
      position: new TMap.LatLng(m.lat, m.lng),
      properties
    };
  });

  var marker = new TMap.MultiMarker({
    id: 'marker-layer',
    map: window.full_map,
    styles: {
      "marker": new TMap.MarkerStyle({
          "width": 18,
          "height": 27,
          "anchor": { x: 12, y: 24 },
          "src": "/images/marker_default.png"
      })
    },
    geometries: geometries
  });

  marker.on("click", function (evt) {

  })
}

export default class extends Controller {
  connect() {
    if (typeof TMap != 'object') {
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "https://map.qq.com/api/gljs?v=1.exp&key=EJPBZ-7TEKU-DLQVP-2K6EE-XZ6O6-NWBKM&callback=initKmFullMap";
      document.body.appendChild(script);
    } else {
      window.initKmFullMap();
    }
  }

  disconnect() {
    window.full_map.destroy();
    window.full_map = null;
  }
}
