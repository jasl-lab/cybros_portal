import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    const canHideItem = this.data.get("can_hide_item") == "true";

    const normalColumns = [
      {"data": "org_name"},
      {"data": "dept_name"},
      {"data": "project_manager_name"},
      {"data": "project_item_code"},
      {"data": "project_item_name"},
      {"data": "created_date"},
      {"data": "unsign_receive"},
      {"data": "f_date"},
      {"data": "min_timecard_fill"},
      {"data": "days_to_min_timecard_fill"}
    ];

    const adminColumns = normalColumns.concat([{"data": "admin_action", bSortable: false}]);

    $('#subsidiary-need-receive-unsign-details-datatable').dataTable({
      "processing": true,
      "serverSide": true,
      "ajax": $('#subsidiary-need-receive-unsign-details-datatable').data('source'),
      "pagingType": "full_numbers",
      "columns": (canHideItem ? adminColumns : normalColumns),
      stateSave: true,
      stateSaveCallback: function(settings, data) {
          localStorage.setItem('DataTables_subsidiary-need-receive-unsign-details', JSON.stringify(data));
        },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem('DataTables_subsidiary-need-receive-unsign-details'));
        }
    });
  }

  disconnect() {
    $('#subsidiary-need-receive-unsign-details-datatable').DataTable().destroy();
  }
}
