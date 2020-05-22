import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "employee_name"},
      {"data": "stamp_to_place"},
      {"data": "stamp_comment"},
      {"data": "attachments"},
      {"data": "created_at"},
      {"data": "task_id"},
      {"data": "task_status"},
      {"data": "belong_company_department"},
      {"data": "item_action", bSortable: false}
    ];

    $('#proof-of-employments-lists-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#proof-of-employments-lists-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      "order": [[ 4, 'desc' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_proof_of_employments_lists', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_proof_of_employments_lists'));
        }
    });
  }

  disconnect() {
    $('#proof-of-employments-lists-datatable').DataTable().destroy();
  }
}
