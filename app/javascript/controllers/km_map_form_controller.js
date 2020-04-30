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

    function refresh_city(t) {
      const province = t.target.value;
      const fill_city_url = '/company/km_map/fill_city';
      $.ajax(fill_city_url, {
        data: { province },
        dataType: 'script'
      });
    };
    $('#select-province').on('change', refresh_city);

    function refresh_fill_department(t) {
      const company_name = t.target.value;
      const fill_department_url = '/company/km_map/fill_department';
      $.ajax(fill_department_url, {
        data: { company_name },
        dataType: 'script'
      });
    };
    $('#select-km-company').on('change', refresh_fill_department);

    function refresh_fill_progress(t) {
      const service_stage = t.target.value;
      const fill_progress_url = '/company/km_map/fill_progress';
      $.ajax(fill_progress_url, {
        data: { service_stage },
        dataType: 'script'
      });
    };
    $('#select-km-service-stage').on('change', refresh_fill_progress);
  }

  disconnect() {
    $('#select-km-biz-category').off('change');
    $('#select-km-company').off('change');
    $('#select-km-service-stage').off('change');
  }
}
