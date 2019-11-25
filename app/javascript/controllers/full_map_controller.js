import { Controller } from "stimulus"

window.initFullMap = function () {
  const mapPoint = $('#full-map').data("full-map-map_point");
  const avgLat = $('#full-map').data("full-map-avg_lat");
  const avgLng = $('#full-map').data("full-map-avg_lng");

  const center = new TMap.LatLng(avgLat,avgLng); // 设置中心点坐标

  window.full_map = new TMap.Map("full-map", {
    center,
    zoom: 11
  });

  const geometries = mapPoint.map(function(m) {
    switch (m.trace_state) {
      case '跟踪中':
        return { styleId: 'marker_processing',
          position: new TMap.LatLng(m.lat, m.lng),
          properties: {
            title: m.title,
            owner: m.owner,
            developer_company: m.developer_company,
            project_code: m.project_code,
            trace_state: m.trace_state,
            scale_area: m.scale_area,
            province: m.province,
            city: m.city,
            project_type: m.project_type,
            big_stage: m.big_stage,
            contracts: m.contracts
          }
        };
      case '跟踪失败':
        return { styleId: 'marker_failure',
          position: new TMap.LatLng(m.lat, m.lng),
          properties: {
            title: m.title,
            owner: m.owner,
            developer_company: m.developer_company,
            project_code: m.project_code,
            trace_state: m.trace_state,
            scale_area: m.scale_area,
            province: m.province,
            city: m.city,
            project_type: m.project_type,
            big_stage: m.big_stage,
            contracts: m.contracts
          }
        };
      default:
        return { styleId: 'marker',
          position: new TMap.LatLng(m.lat, m.lng),
          properties: {
            title: m.title,
            owner: m.owner,
            developer_company: m.developer_company,
            project_code: m.project_code,
            trace_state: m.trace_state,
            scale_area: m.scale_area,
            province: m.province,
            city: m.city,
            project_type: m.project_type,
            big_stage: m.big_stage,
            contracts: m.contracts
          }
        };
    }
  });

  var marker = new TMap.MultiMarker({
    id: 'marker-layer',
    map: window.full_map,
    styles: {
      "marker_failure": new TMap.MarkerStyle({
          "width": 18,
          "height": 27,
          "anchor": { x: 12, y: 24 },
          "src": "/images/marker_failure.png"
      }),
      "marker_processing": new TMap.MarkerStyle({
          "width": 18,
          "height": 27,
          "anchor": { x: 12, y: 24 },
          "src": "/images/marker_processing.png"
      }),
      "marker": new TMap.MarkerStyle({
          "width": 18,
          "height": 27,
          "anchor": { x: 12, y: 24 },
          "src": "/images/marker_default.png"
      })
    },
    geometries: geometries
  });

  var infoWindow = new TMap.InfoWindow({
    map: window.full_map,
    position: new TMap.LatLng(31.228177,121.487003),
    offset: { x: -3, y: -14 } // 设置信息窗相对position偏移像素
  });
  infoWindow.close();// 初始关闭信息窗关闭

  marker.on("click", function (evt) {
    infoWindow.open();
    infoWindow.setPosition(evt.geometry.position);
    const props = evt.geometry.properties
    const links = props.contracts.map(function(m) {
      return `<a href='${m.url}' target='_blank'>${m.docname}</a>`
    }).join("<br />");
    const content = `
<h5>工程编号：${props.project_code} | 商机状态：${props.trace_state}</h5>
<p>工程名称：${props.title}</p>
<p>甲方集团：${props.developer_company}</p>
<p>包含项目类型：${props.project_type}</p>
<p>所在地：${props.province}-${props.city}</p>
<p>生产主责公司部门：${props.owner}</p>
`;
    infoWindow.dom.children[0].style["text-align"] = "left";
    infoWindow.dom.children[0].style["line-height"] = "1";
    infoWindow.setContent(content + '<p>包含合同: ' + links + '</p>');
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
