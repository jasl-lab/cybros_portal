import { Controller } from "stimulus"

let nameCardsListsFixedHeader;

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "name"},
      {"data": "english_name"},
      {"data": "email"},
      {"data": "task_id"},
      {"data": "department_name"},
      {"data": "en_department_name"},
      {"data": "title"},
      {"data": "en_title"},
      {"data": "mobile"},
      {"data": "phone_ext"},
      {"data": "fax_no"},
      {"data": "print_out_box_number"},
      {"data": "status"},
      {"data": "item_action", bSortable: false}
    ];

    const nameCardsListsDatatable = $('#name-cards-lists-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#name-cards-lists-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": normalColumns,
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_name-cards-lists', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_name-cards-lists'));
        }
    });
    nameCardsListsFixedHeader = new $.fn.dataTable.FixedHeader(nameCardsListsDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    nameCardsListsFixedHeader.destroy();
    $('#name-cards-lists-datatable').DataTable().destroy();
  }
}
