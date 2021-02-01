import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $('#ncworkno-select').selectize({
      valueField: "clerk_code",
      labelField: "chinese_name",
      searchField: "chinese_name",
      create: false,
      load: function (query, callback) {
        if (!query.length) return callback();
        $.ajax({
          url: "/ui/ncworkno_select.json?q=" + encodeURIComponent(query),
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
