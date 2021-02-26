import { Controller } from "stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    const load_url = this.urlValue;
    $('#ncworkno-select').selectize({
      valueField: "clerk_code",
      labelField: "chinese_name",
      searchField: ['clerk_code','chinese_name'],
      create: false,
      load: function (query, callback) {
        if (!query.length) return callback();
        $.ajax({
          url: `${load_url}?q=${encodeURIComponent(query)}`,
          type: "GET",
          error: function () {
            callback();
          },
          success: function (res) {
            callback(res.users);
          },
        });
      },
    });
  }
}
