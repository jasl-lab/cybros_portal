import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const normalColumns = [
      {"data": "project_no_and_name"},
      {"data": "project_type_and_main_dept_name"},
      {"data": "scale_area"}
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
      "order": [[ 0, 'desc' ]],
      "stateSave": false
    });
  }

  disconnect() {
    $('#company-contracts-datatable').DataTable().destroy();
  }
}
