import { Controller } from "stimulus"

let crmReceivableAccountTableFixedHeader;

export default class extends Controller {
  static values = { pageLength: Number }

  connect() {
    const normalColumns = [
      {"data": "crmthrank"},
      {"data": "crmshort"},
      {"data": "cricrank"},
      {"data": "clientproperty"},
      {"data": "sum_receive"},
      {"data": "sum_receive_gt1_years"},
      {"data": "aging_amount_lt3_months"},
      {"data": "aging_amount_4to12_months"},
      {"data": "aging_amount_gt1_years"},
      {"data": "sign_receive"},
      {"data": "unsign_receive"}
    ];

    const crmReceivableAccountDatatable = $('#customer-receivable-account-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#customer-receivable-account-datatable').data('source'),
      "pagingType": "numbers",
      "columns": normalColumns,
      "order": [[ 4, 'desc' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_customer-receivable-account', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_customer-receivable-account'));
        }
    });

    crmReceivableAccountTableFixedHeader = new $.fn.dataTable.FixedHeader(crmReceivableAccountDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    crmReceivableAccountTableFixedHeader.destroy();
    $('#customer-receivable-account-datatable').DataTable().destroy();
  }
}
