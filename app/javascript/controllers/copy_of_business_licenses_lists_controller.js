import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "employee_name"},
      {"data": "clerk_code"},
      {"data": "belong_company_name"},
      {"data": "belong_department_name"},
      {"data": "contract_belong_company"},
      {"data": "stamp_to_place"},
      {"data": "stamp_comment"},
      {"data": "item_action", bSortable: false}
    ];

    $('#copy-of-business-licenses-lists-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#copy-of-business-licenses-lists-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_copy-of-business-licenses-lists', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_copy-of-business-licenses-lists'));
        }
    });
  }

  disconnect() {
    $('#copy-of-business-licenses-lists-datatable').DataTable().destroy();
  }
}
