import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const canHideItem = this.data.get("can_hide_item") == "true";

    const normalColumns = [
      {"data": "org_dept_name"},
      {"data": "business_director_name"},
      {"data": "first_party_name"},
      {"data": "sales_contract_code_name"},
      {"data": "amount_total"},
      {"data": "contract_property_name"},
      {"data": "contract_time"},
      {"data": "acc_need_receive"},
      {"data": "sign_receive"},
      {"data": "over_amount"},
      {"data": "comment_on_sales_contract_code"},
    ];

    const adminColumns = normalColumns.concat([{"data": "admin_action", bSortable: false}]);

    $('#subsidiary-need-receive-sign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#subsidiary-need-receive-sign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": (canHideItem ? adminColumns : normalColumns),
      "order": [[ 8, 'desc' ]],
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
