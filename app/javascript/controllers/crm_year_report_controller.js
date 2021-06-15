import { Controller } from "stimulus"

let crmYearReportChart;
let crmYearTableFixedHeader;

export default class extends Controller {
  static values = { pageLength: Number }

  connect() {
    crmYearReportChart = echarts.init(document.getElementById('crm-year-report-chart'));

    const xAxis = JSON.parse(this.data.get("x_axis"));
    const top20s = JSON.parse(this.data.get("top20s"));
    const top20to50 = JSON.parse(this.data.get("top20to50s"));
    const gt50s = JSON.parse(this.data.get("gt50s"));
    const others = JSON.parse(this.data.get("others"));

    const option = {
      legend: {
        data: ['TOP 20 房企','TOP 20-50 房企','非 TOP 50 大客户','其他'],
        align: 'left'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'cross'
        }
      },
      grid: {
        left: 65,
        right: 0,
        top: 48,
        bottom: 60
      },
      toolbox: {
        feature: {
          dataView: {},
          saveAsImage: {
              pixelRatio: 2
          }
        }
      },
      xAxis: {
        data: xAxis,
        silent: true,
        axisLabel: {
          interval: 0,
          rotate: -40
        },
        splitLine: {
            show: false
        }
      },
      yAxis: [{
        type: 'value',
        position: 'left',
        axisLabel: {
          formatter: '{value}百万'
        }
      }],
      series: [{
        name: 'TOP 20 房企',
        type: 'bar',
        stack: '生产合同额',
        data: top20s,
        label: {
          show: true,
          position: 'inside'
        }
      },{
        name: 'TOP 20-50 房企',
        type: 'bar',
        stack: '生产合同额',
        data: top20to50,
        label: {
          show: true,
          position: 'inside'
        }
      },{
        name: '非 TOP 50 大客户',
        type: 'bar',
        stack: '生产合同额',
        data: gt50s,
      },{
        name: '其他',
        type: 'bar',
        stack: '生产合同额',
        data: others,
        label: {
          show: true,
          position: 'inside'
        }
      }]
    };

    function drill_down_crm_year_chart_detail(params) {
      if (params.componentType === 'series') {
        if (params.seriesType === 'bar') {
          console.log(params);
          const sent_data = { year: params.name, series_name: params.seriesName };

          const drill_down_url = "/report/crm_year_report/drill_down";

          $.ajax(drill_down_url, {
            data: sent_data,
            dataType: 'script'
          });
        }
      }
    }
    crmYearReportChart.setOption(option, false);
    crmYearReportChart.on('click', drill_down_crm_year_chart_detail);

    setTimeout(() => {
      crmYearReportChart.resize();
    }, 200);

    const normalColumns = [
      {"data": "rank"},
      {"data": "customer_group"},
      {"data": "kerrey_trading_area_ranking"},
      {"data": "customer_ownership"},
      {"data": "production_contract_value_last_year"},
      {"data": "production_contract_value_this_year"},
      {"data": "group_production_contract_value_last_year"},
      {"data": "group_production_contract_value_this_year"},

      {"data": "scheme_production_contract_value_at_each_stage"},
      {"data": "construction_drawing_production_contract_value_at_each_stage"},
      {"data": "whole_process_production_contract_value_at_each_stage"},
      {"data": "total_contract_value_of_the_group_percent"},
      {"data": "the_top_three_teams_in_cooperation"},

      {"data": "average_contract_value_of_single_project_in_the_past_year"},
      {"data": "average_scale_of_single_project_in_the_past_year"},
      {"data": "nearly_one_year_contract_average_contract_period"},
      {"data": "proportion_of_contract_amount_modification_fee"},
      {"data": "proportion_of_labor_cost_of_bidding_land_acquisition"},
    ];

    const crmYearReportDatatable = $('#crm-year-report-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#crm-year-report-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      "dom":
        "<'row'<'col-sm-12 col-md-2'B><'col-sm-12 col-md-7'l><'col-sm-12 col-md-3'f>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
      "colReorder": true,
      "buttons": ['colvis'],
      "order": [[ 2, 'asc' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_crm_year_report', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_crm_year_report'));
        }
    });

    crmYearTableFixedHeader = new $.fn.dataTable.FixedHeader(crmYearReportDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  layout() {
    crmYearReportChart.resize();
  }

  disconnect() {
    crmYearReportChart.dispose();
    crmYearTableFixedHeader.destroy();
    $('#crm-year-report-datatable').DataTable().destroy();
  }
}
