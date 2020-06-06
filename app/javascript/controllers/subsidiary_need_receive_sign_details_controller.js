import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const canHideItem = this.data.get("can_hide_item") == "true";

    const normalColumns = [
      {"data": "org_name"},
      {"data": "dept_name"},
      {"data": "business_director_name"},
      {"data": "sales_contract_code"},
      {"data": "sales_contract_name"},
      {"data": "amount_total"},
      {"data": "contract_property_name"},
      {"data": "contract_time"},
      {"data": "sign_receive"},
      {"data": "over_amount"}
    ];

    const adminColumns = normalColumns.concat([{"data": "admin_action", bSortable: false}]);

    $('#subsidiary-need-receive-sign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#subsidiary-need-receive-sign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": (canHideItem ? adminColumns : normalColumns),
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_subsidiary-need-receive-sign-details', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_subsidiary-need-receive-sign-details'));
        }
    });
  }

  disconnect() {
    $('#subsidiary-need-receive-sign-details-datatable').DataTable().destroy();
  }
}
