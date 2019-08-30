import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $('#contract-sign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "ajax": $('#contract-sign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": [
        {"data": "org_name"},
        {"data": "dept_name"},
        {"data": "business_director_name"},
        {"data": "sales_contract_code"},
        {"data": "sales_contract_name"},
        {"data": "first_party_name"},
        {"data": "amount_total"},
        {"data": "date_1"},
        {"data": "date_2"},
        {"data": "project_code"},
        {"data": "project_name"}
      ],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_contract-sign-details', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_contract-sign-details'));
        }
    });
  }

  disconnect() {
    $('#contract-sign-details-datatable').DataTable().destroy();
  }
}
