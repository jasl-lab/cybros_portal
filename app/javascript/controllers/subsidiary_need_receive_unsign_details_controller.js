import { Controller } from "stimulus"

let subsidiaryNeedReceiveUnsignDetailsFixedHeader;

export default class extends Controller {
  static values = { pageLength: Number }

  connect() {
    const canHideItem = this.data.get("can_hide_item") == "true";

    const normalColumns = [
      {"data": "org_dept_name"},
      {"data": "project_manager_name"},
      {"data": "project_item_code_name"},
      {"data": "created_date"},
      {"data": "predict_amount"},
      {"data": "unsign_receive"},
      {"data": "f_date"},
      {"data": "min_timecard_fill"},
      {"data": "days_to_min_timecard_fill"}
    ];

    const adminColumns = normalColumns.concat([{"data": "comment_on_project_item_code", bSortable: false}, {"data": "admin_action", bSortable: false}]);

    const subsidiaryNeedReceiveUnsignDetailsDatatable = $('#subsidiary-need-receive-unsign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#subsidiary-need-receive-unsign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": (canHideItem ? adminColumns : normalColumns),
      "order": [[ 5, 'desc' ]],
      stateSave: true,
      drawCallback: function () {
          $('button[data-toggle="popover"]').popover({ "html": true });
        },
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_subsidiary-need-receive-unsign-details', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_subsidiary-need-receive-unsign-details'));
        }
    });
    subsidiaryNeedReceiveUnsignDetailsFixedHeader = new $.fn.dataTable.FixedHeader(subsidiaryNeedReceiveUnsignDetailsDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    subsidiaryNeedReceiveUnsignDetailsFixedHeader.destroy();
    $('#subsidiary-need-receive-unsign-details-datatable').DataTable().destroy();
  }
}
