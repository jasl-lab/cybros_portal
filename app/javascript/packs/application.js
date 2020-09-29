// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

const importAll = (r) => r.keys().map(r)
importAll(require.context('images', false, /\.(png|jpe?g|svg)$/i));
//importAll(require.context('@fortawesome/fontawesome-free/webfonts', false, /\.(eot|svg|ttf|woff2?)$/i));

import "regenerator-runtime/runtime";
import "@stimulus/polyfills";

import JQuery from 'jquery';
window.$ = window.JQuery = JQuery;
require("node-json2html/json2html.js")

import "bootstrap";
import "@coreui/coreui";
import "selectize/dist/js/selectize";

import "stylesheets/application";

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("trix")
require("@rails/actiontext")

import "turbolinks/coreui";

import echarts from 'echarts'
require("echarts/map/js/china")
window.echarts = echarts;

import "controllers";

// Load Datatables
require('datatables.net-bs')(window, $);
require('datatables.net-buttons-bs')(window, $);
require('datatables.net-buttons/js/buttons.colVis.js')(window, $);
require('datatables.net-buttons/js/buttons.html5.js')(window, $);
require('datatables.net-buttons/js/buttons.print.js')(window, $);
require('datatables.net-responsive-bs')(window, $);
require('datatables.net-select')(window, $);
// require('yadcf')(window, $); // Uncomment if you use yadcf (need a recent version of yadcf)
require("datatables");

require("devise-jwt");

// Translate dataTable into Chinese
$.extend( $.fn.dataTable.defaults, {
  language: {
    "sProcessing":   "处理中...",
    "sLengthMenu":   "显示 _MENU_ 项结果",
    "sZeroRecords":  "没有匹配结果",
    "sInfo":         "显示第 _START_ 至 _END_ 项结果，共 _TOTAL_ 项",
    "sInfoEmpty":    "显示第 0 至 0 项结果，共 0 项",
    "sInfoFiltered": "(由 _MAX_ 项结果过滤)",
    "sInfoPostFix":  "",
    "sSearch":       "搜索:",
    "sUrl":          "",
    "sEmptyTable":     "表中数据为空",
    "sLoadingRecords": "载入中...",
    "sInfoThousands":  ",",
    "oPaginate": {
        "sFirst":    "首页",
        "sPrevious": "上页",
        "sNext":     "下页",
        "sLast":     "末页"
    },
    "oAria": {
        "sSortAscending":  ": 以升序排列此列",
        "sSortDescending": ": 以降序排列此列"
    }
  }
});

document.addEventListener("turbolinks:load", function() {
  JQuery("figure>img").on( "click", function() {
    $("#knowledge-edit-modal").html(`
<div class="modal-dialog modal-dialog-centered">
  <div class="modal-content">
    <img src="${$(this).attr('src')}">
  </div>
</div>`).modal('show');
  });

  $("select[class='form-control'][class!='selectized']").selectize();
  $('button[data-toggle="popover"]').popover();
});
