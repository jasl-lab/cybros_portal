import { Controller } from "stimulus"

let crmReceivableAccountTable2FixedHeader;

export default class extends Controller {
  static values = { pageLength: Number }

  connect() {
    const normalColumns = [
      {"data": "crmthrank"},
      {"data": "crmshort"},
    ];

    const crmReceivableAccountDatatable = $('#customer-receivable-account-downpart-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#customer-receivable-account-downpart-datatable').data('source'),
      "pagingType": "numbers",
      "columns": normalColumns,
      "order": [[ 1, 'desc' ]],
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_customer-receivable-account-downpart', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_customer-receivable-account-downpart'));
        }
    });

    crmReceivableAccountTable2FixedHeader = new $.fn.dataTable.FixedHeader(crmReceivableAccountDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    crmReceivableAccountTable2FixedHeader.destroy();
    $('#customer-receivable-account-downpart-datatable').DataTable().destroy();
  }
}
