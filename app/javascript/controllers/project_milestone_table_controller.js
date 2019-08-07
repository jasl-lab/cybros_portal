import { Controller } from "stimulus"

export default class extends Controller {
  drill_down(event){
    const name = $(event.target).text().split('（')[0];
    const month_name = $('#month_name').val();
    let sent_data = {
      name,
      month_name
    };
    let drill_down_url = '/report/project_milestore/detail_table_drill_down';
    $.ajax(drill_down_url, {
      data: sent_data,
      dataType: 'script'
    });
  }
}

