import { Controller } from "stimulus"

let companyContractsFixedHeader;

export default class extends Controller {
  static values = { pageLength: Number }

  connect() {
    const normalColumns = [
      {"data": "project_no_and_name" },
      {"data": "project_type_and_main_dept_name" },
      {"data": "total_sales_contract_amount", bSortable: false }
    ];

    const companyContractsDatatable = $('#company-contracts-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "pageLength": this.pageLengthValue,
      "autoWidth": false,
      "ajax": $('#company-contracts-datatable').data('source'),
      "pagingType": "full_numbers",
      "dom": // original setting from node_modules/datatables.net-bs4/js/dataTables.bootstrap4.js
        "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
      "colReorder": false,
      "lengthChange": false,
      "searching": false,
      "columns": normalColumns,
      "order": [[ 0, 'desc' ]],
      "stateSave": false
    });
    companyContractsFixedHeader = new $.fn.dataTable.FixedHeader(companyContractsDatatable, {
      header: true,
      footer: false,
      headerOffset: 50,
      footerOffset: 0
    });
  }

  disconnect() {
    companyContractsFixedHeader.destroy();
    $('#company-contracts-datatable').DataTable().destroy();
  }
}
