import { Controller } from "stimulus"

window.initKmFullMap = function () {
  const mapPoint = $('#km-full-map').data("km-full-map-map_point");

  const center = new TMap.LatLng(30.576473,112.224908);
  const zoom = 4;

  window.full_map = new TMap.Map("km-full-map", {
    center,
    zoom
  });

  console.log(mapPoint);

  const geometries = mapPoint.map(function(m) {
    const properties = {
      code: m.code
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
    const props = evt.geometry.properties;

    $.ajax({
      type: 'GET',
      dataType: 'script',
      url: '/company/km_map/show_model.js',
      data: { project_item_code: props.code }
    });
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
