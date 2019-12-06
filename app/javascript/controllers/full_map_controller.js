import { Controller } from "stimulus"

window.initFullMap = function () {
  function chunkString(str, length) {
    return str.match(new RegExp('.{1,' + length + '}', 'g'));
  }

  const mapPoint = $('#full-map').data("full-map-map_point");
  const needLocateToShanghai = $('#full-map').data("full-map-need_locate_to_shanghai");
  const needLocateToChina = $('#full-map').data("full-map-need_locate_to_china");
  const allowDownload = $('#full-map').data("full-map-allow_download");
  const avgLat = $('#full-map').data("full-map-avg_lat");
  const avgLng = $('#full-map').data("full-map-avg_lng");

  let center;
  let zoom;

  if (needLocateToShanghai) {
    center = new TMap.LatLng(31.228177,121.487003);
    zoom = 9;
  } else if (needLocateToChina) {
    center = new TMap.LatLng(30.576473,112.224908);
    zoom = 4;
  } else {
    center = new TMap.LatLng(avgLat,avgLng); // 设置中心点坐标
    zoom = 11;
  }

  window.full_map = new TMap.Map("full-map", {
    center,
    zoom
  });

  const geometries = mapPoint.map(function(m) {
    const properties = {
      title: m.title,
      developer_company: m.developer_company,
      project_code: m.project_code,
      trace_state: m.trace_state,
      scale_area: m.scale_area,
      province: m.province,
      city: m.city,
      big_stage: m.big_stage,
      project_items: m.project_items,
      contracts: allowDownload ? m.contracts : []
    }
    switch (m.trace_state) {
      case '跟踪中':
        return { styleId: 'marker_processing',
          position: new TMap.LatLng(m.lat, m.lng),
          properties
        };
      case '跟踪失败':
        return { styleId: 'marker_failure',
          position: new TMap.LatLng(m.lat, m.lng),
          properties
        };
      default:
        return { styleId: 'marker',
          position: new TMap.LatLng(m.lat, m.lng),
          properties
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
    const allowDownload = $('#full-map').data("full-map-allow_download");
    infoWindow.open();
    infoWindow.setPosition(evt.geometry.position);
    const props = evt.geometry.properties;

    const project_items = props.project_items.map(function(p) {
      return chunkString(`${p.deptname}（${p.project_type}）`,17).join('<br />');
    }).join("<br />");

    const links = props.contracts.map(function(m) {
      return `<a href='${m.url}' target='_blank'>${m.docname}</a>`
    }).join("<br />");

    let content;
    if(allowDownload == true) {
      content = `
    <ul class="nav nav-tabs" role="tablist">
      <li class="nav-item">
        <a class="nav-link active" id="brief-tab" data-toggle="tab" href="#brief" role="tab" aria-controls="brief" aria-selected="true">介绍</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" id="contract-tab" data-toggle="tab" href="#contract" role="tab" aria-controls="contract" aria-selected="false">合同下载</a>
      </li>
    </ul>
    <div class="tab-content">
      <div class="tab-pane active" id="brief" role="tabpanel" aria-labelledby="brief-tab">
        <table class="table table-striped">
        <tbody>
          <tr>
            <td>工程<br />编号</td>
            <td>${props.project_code}<br />${props.trace_state} ${props.province}-${props.city}</td>
          </tr>
          <tr>
            <td>工程<br />名称</td>
            <td>${chunkString(props.title, 17).join('<br />')}</td>
          </tr>
          <tr>
            <td>甲方<br />集团</td>
            <td>${chunkString(props.developer_company, 17).join('<br />')}</td>
          </tr>
          <tr>
            <td>生产<br />主责</td>
            <td>${project_items}</td>
          </tr>
        </tbody>
        </table>
      </div>
      <div class="tab-pane" id="contract" role="tabpanel" aria-labelledby="contract-tab">
        <p>${links}</p>
      </div>
    </div>
    `;
    } else {
      content = `
        <table class="table table-striped">
        <tbody>
          <tr>
            <td>工程<br />编号</td>
            <td>${props.project_code}<br />${props.trace_state} ${props.province}-${props.city}</td>
          </tr>
          <tr>
            <td>工程<br />名称</td>
            <td>${chunkString(props.title, 17).join('<br />')}</td>
          </tr>
          <tr>
            <td>甲方<br />集团</td>
            <td>${chunkString(props.developer_company, 17).join('<br />')}</td>
          </tr>
          <tr>
            <td>生产<br />主责</td>
            <td>${project_items}</td>
          </tr>
        </tbody>
        </table>
    `;
    }
    infoWindow.dom.children[0].style["text-align"] = "left";
    infoWindow.dom.children[0].style["line-height"] = "1";
    infoWindow.dom.children[0].style["padding"] = "unset";
    infoWindow.setContent(content);
    if (allowDownload == true) {
      $('#brief-tab').on('click', function(e) {
        e.preventDefault();
        $(this).tab('show');
      });
      $('#contract-tab').on('click', function(e) {
        e.preventDefault();
        $(this).tab('show');
      });
    }
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
    const asideShowTime = parseInt(localStorage.getItem('map-aside-show-time') || '0', 10);
    if(asideShowTime <= 2) {
      localStorage.setItem('map-aside-show-time', asideShowTime + 1);
      setTimeout(function(){
        $('#aside-menu-toggler').click();
      }, 500);
    }
  }

  disconnect() {
    window.full_map.destroy();
    window.full_map = null;
  }
}
