import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const canHideItem = this.data.get("can_hide_item") == "true";

    const normalColumns = [
      {"data": "org_name"},
      {"data": "dept_name"},
      {"data": "business_director_name"},
      {"data": "sales_contract_code_name"},
      {"data": "first_party_name"},
      {"data": "amount_total"},
      {"data": "date_1"},
      {"data": "date_2"},
      {"data": "contract_time"},
      {"data": "min_timecard_fill"},
      {"data": "min_date_hrcost_amount"},
      {"data": "project_type"}
    ];

    const adminColumns = normalColumns.concat([{"data": "admin_action", bSortable: false}]);

    $('#contract-sign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#contract-sign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": (canHideItem ? adminColumns : normalColumns),
      "order": [[ 6, 'desc' ]],
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
