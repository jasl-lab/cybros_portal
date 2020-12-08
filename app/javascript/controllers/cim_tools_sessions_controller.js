import { Controller } from "stimulus"

let cimToolsSessionsFixedHeader;

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "user_name"},
      {"data": "user_company"},
      {"data": "user_department"},
      {"data": "user_title"},
      {"data": "operation"},
      {"data": "ip_mac_address"},
      {"data": "created_at"},
      {"data": "updated_at"}
    ];

    const cimToolsSessionsDatatable = $('#cim-tools-sessions-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#cim-tools-sessions-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      "order": [[ 3, 'DESC' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_cim-tools-sessions', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_cim-tools-sessions'));
        }
    });
    cimToolsSessionsFixedHeader = new $.fn.dataTable.FixedHeader(cimToolsSessionsDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    cimToolsSessionsFixedHeader.destroy();
    $('#cim-tools-sessions-datatable').DataTable().destroy();
  }
}
