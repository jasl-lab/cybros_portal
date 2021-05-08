// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

const importAll = (r) => r.keys().map(r)
importAll(require.context('images', false, /\.(png|jpe?g|svg)$/i));
//importAll(require.context('@fortawesome/fontawesome-free/webfonts', false, /\.(eot|svg|ttf|woff2?)$/i));

import "regenerator-runtime/runtime";
import "@stimulus/polyfills";

import $ from 'jquery'
global.$ = $
global.jQuery = $
require("node-json2html/json2html.js")

import "bootstrap";
import "@coreui/coreui";
import "selectize/dist/js/selectize";

import "stylesheets/application";

global.moment = require('moment');
require("tempusdominus-bootstrap-4/build/js/tempusdominus-bootstrap-4")

global.Rails = require("@rails/ujs");

global.Rails.start();

require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("trix")
require("@rails/actiontext")

import "turbolinks/coreui";

import echarts from 'echarts'
require("echarts/map/js/china")
global.echarts = echarts;

import "controllers";

// Load Datatables
require('datatables.net-bs4')(window, $);
require('datatables.net-buttons-bs4')(window, $);
require('datatables.net-fixedheader-bs4')(window, $);
require('datatables.net-select-bs4')(window, $);
// require('yadcf')(window, $); // Uncomment if you use yadcf (need a recent version of yadcf)

require("devise-jwt");

$.extend( $.fn.dataTable.defaults, {
  lengthMenu: [ 12, 25, 50, 75, 100 ],
  language: {
    "emptyTable":     "表中数据为空",
    "info":           "显示第 _START_ 至 _END_ 项结果，共 _TOTAL_ 项",
    "infoEmpty":      "显示第 0 至 0 项结果，共 0 项",
    "infoFiltered":   "(由 _MAX_ 项结果过滤)",
    "infoThousands":  ",",
    "lengthMenu":     "显示数量 _MENU_",
    "loadingRecords": "载入中...",
    "processing":     "处理中...",
    "search":         "搜索:",
    "zeroRecords":    "没有匹配结果",
    "thousands": ",",
    "paginate": {
      "first":    "第一页",
      "last":     "最后一页",
      "next":     "下一页",
      "previous": "上一页"
    },
    "aria": {
      "sortAscending":  ": 以升序排列此列",
      "sortDescending": ": 以降序排列此列"
    }
  }
} );

$.fn.datetimepicker.Constructor.Default = $.extend({},
  $.fn.datetimepicker.Constructor.Default,
  { icons:
    { time: 'fas fa-clock',
      date: 'fas fa-calendar',
      up: 'fas fa-arrow-up',
      down: 'fas fa-arrow-down',
      previous: 'fas fa-arrow-circle-left',
      next: 'fas fa-arrow-circle-right',
      today: 'far fa-calendar-check-o',
      clear: 'fas fa-trash',
      close: 'far fa-times' } });

document.addEventListener("turbolinks:load", function() {
  $("figure>img").on( "click", function() {
    $("#knowledge-edit-modal").html(`
<div class="modal-dialog modal-dialog-centered">
  <div class="modal-content">
    <img src="${$(this).attr('src')}">
  </div>
</div>`).modal('show');
  });

  $('#datetimepicker_start_date').datetimepicker({locale: 'zh-cn', format: 'YYYY-MM-DD'});
  $('#datetimepicker_end_date').datetimepicker({locale: 'zh-cn', format: 'YYYY-MM-DD'});

  $("select[class='form-control'][class!='selectized']").selectize();
  $('button[data-toggle="popover"]').popover();
});
