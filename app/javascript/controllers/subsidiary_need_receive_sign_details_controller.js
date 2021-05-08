import { Controller } from "stimulus"

let subsidiaryNeedReceiveSignDetailsFixedHeader;

export default class extends Controller {
  static values = { pageLength: Number, endOfDate: String, canHideItem: Boolean }

  connect() {
    const before202103Columns = [
      {"data": "org_dept_name"},
      {"data": "business_director_name"},
      {"data": "first_party_name"},
      {"data": "sales_contract_code"},
      {"data": "sales_contract_name"},
      {"data": "amount_total"},
      {"data": "contract_property_name"},
      {"data": "contract_time"},
      {"data": "sign_receive"},
      {"data": "over_amount"},
      {"data": "acc_need_receive"},
      {"data": "comment_on_sales_contract_code"},
    ];

    const after202103Columns = [
      {"data": "org_dept_name"},
      {"data": "business_director_name"},
      {"data": "first_party_name"},
      {"data": "sales_contract_code"},
      {"data": "sales_contract_name"},
      {"data": "amount_total"},
      {"data": "sign_receive"},
      {"data": "over_amount"},
      {"data": "acc_need_receive"},
      {"data": "acc_need_receive_gt3_months"},
      {"data": "comment_on_sales_contract_code"},
    ];

    let normalColumns;

    if (Date.parse(this.endOfDateValue+"T00:00:00") < Date.parse('2021-03-01T00:00:00')) {
      normalColumns = before202103Columns;
    } else {
      normalColumns = after202103Columns;
    }

    const adminColumns = normalColumns.concat([{"data": "admin_action", bSortable: false}]);

    const subsidiaryNeedReceiveSignDetailsDatatable = $('#subsidiary-need-receive-sign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#subsidiary-need-receive-sign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": (this.canHideItemValue ? adminColumns : normalColumns),
      "order": [[ 8, 'desc' ]],
      stateSave: true,
      drawCallback: function () {
          $('button[data-toggle="popover"]').popover({ "html": true });
        },
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_subsidiary-need-receive-sign-details', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_subsidiary-need-receive-sign-details'));
        }
    });
    subsidiaryNeedReceiveSignDetailsFixedHeader = new $.fn.dataTable.FixedHeader(subsidiaryNeedReceiveSignDetailsDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    subsidiaryNeedReceiveSignDetailsFixedHeader.destroy();
    $('#subsidiary-need-receive-sign-details-datatable').DataTable().destroy();
  }
}
