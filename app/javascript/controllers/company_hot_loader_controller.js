import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.load()
  }

  load() {
    $.ajax('/api/v1/hots?h=true&page=1', {
      dataType: 'json'
    }).done(function(response) {
      const data = response.data[0];
      console.log(data);

      $("#company-hots-img").attr("src", `https://portal.thape.com.cn${data.cover}`);
      $("#company-hots-title").html(data.title);
      $("#company-hots-text").html(data.description);
      $("#company-hots-link").attr("href", data.url);

    });
  }
}
