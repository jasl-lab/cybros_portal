import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "project_no"},
      {"data": "market_info_name"},
      {"data": "project_type_scale_area"},
      {"data": "main_dept_name"}
    ];

    $('#company-contracts-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#company-contracts-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      "order": [[ 1, 'desc' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_company-contracts', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_company-contracts'));
        }
    });
  }

  disconnect() {
    $('#company-contracts-datatable').DataTable().destroy();
  }
}
