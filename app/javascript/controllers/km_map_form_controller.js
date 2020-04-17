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
  }

  disconnect() {
    $('#select-km-biz-category').off('change');
  }
}
