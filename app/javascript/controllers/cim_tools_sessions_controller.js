import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "session"},
      {"data": "begin_operation"},
      {"data": "operation"},
      {"data": "end_operation"},
      {"data": "ip_address"},
      {"data": "mac_address"},
      {"data": "created_at"},
      {"data": "updated_at"}
    ];

    $('#cim-tools-sessions-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#cim-tools-sessions-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      "order": [[ 6, 'DESC' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_cim-tools-sessions', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_cim-tools-sessions'));
        }
    });
  }

  disconnect() {
    $('#cim-tools-sessions-datatable').DataTable().destroy();
  }
}
