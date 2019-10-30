import { Controller } from "stimulus"

export default class extends Controller {
  drill_down(event) {
    const work_no = $(event.target).data("project-milestone-table-work_no");
    const dept_code = $(event.target).data("project-milestone-table-dept_code");
    const month_name = $('#month_name').val();

    const sent_data = {
      work_no,
      dept_code,
      month_name
    };
    const drill_down_url = '/report/project_milestore/detail_table_drill_down';
    $.ajax(drill_down_url, {
      data: sent_data,
      dataType: 'script'
    });
  }
}
