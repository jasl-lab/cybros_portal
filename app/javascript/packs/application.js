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

require("devise-jwt");

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
});
