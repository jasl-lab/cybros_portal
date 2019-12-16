import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "project_no"},
      {"data": "market_info_name"},
      {"data": "project_type_scale_area"},
      {"data": "main_dept_name"}
    ];

    $('#company-contracts-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "autoWidth": false,
      "ajax": $('#company-contracts-datatable').data('source'),
      "pagingType": "full_numbers",
      "lengthChange": false,
      "pageLength": 20,
      "searching": false,
      "columns": normalColumns,
      "order": [[ 1, 'desc' ]],
      "stateSave": false
    });
  }

  disconnect() {
    $('#company-contracts-datatable').DataTable().destroy();
  }
}
