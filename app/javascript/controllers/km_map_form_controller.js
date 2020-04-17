import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    function refresh_prj_category(t) {
      const biz_category = t.target.value;
      const fill_category_url = '/company/km_map/fill_category';
      $.ajax(fill_category_url, {
        data: { biz_category },
        dataType: 'script'
      });
    };
    $('#select-km-biz-category').on('change', refresh_prj_category);

    function refresh_fill_department(t) {
      const company_name = t.target.value;
      const fill_department_url = '/company/km_map/fill_department';
      $.ajax(fill_department_url, {
        data: { company_name },
        dataType: 'script'
      });
    };
    $('#select-km-company').on('change', refresh_fill_department);
  }

  disconnect() {
    $('#select-km-biz-category').off('change');
    $('#select-km-company').off('change');
  }
}
