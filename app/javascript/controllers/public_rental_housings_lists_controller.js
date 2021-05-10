import { Controller } from "stimulus"

export default class extends Controller {
  static values = { pageLength: Number }

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

    $('#public-rental-housings-lists-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#public-rental-housings-lists-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      "order": [[ 4, 'desc' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_public_rental_housings_lists', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_public_rental_housings_lists'));
        }
    });
  }

  disconnect() {
    $('#public-rental-housings-lists-datatable').DataTable().destroy();
  }
}
