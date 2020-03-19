import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "employee_name"},
      {"data": "stamp_to_place"},
      {"data": "stamp_comment"},
      {"data": "attachments"},
      {"data": "created_at"},
      {"data": "task_id_and_status"},
      {"data": "belong_company_department"},
      {"data": "item_action", bSortable: false}
    ];

    $('#proof-of-incomes-lists-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#proof-of-incomes-lists-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_proof_of_incomes_lists', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_proof_of_incomes_lists'));
        }
    });
  }

  disconnect() {
    $('#proof-of-incomes-lists-datatable').DataTable().destroy();
  }
}
