import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.load()
  }

  load() {
    $.ajax('/api/v1/courses?h=true', {
      dataType: 'json'
    }).done(function(response) {
      const template = {'<>':'div','class':'col-sm-12 col-md-6 col-lg-4 col-xl-3',
       'html':'<div class="card"><img src="https://portal.thape.com.cn${cover}" class="card-img-top"><div class="card-body"><p class="card-text">${title}</p><a href="${url}" target="_blank" class="card-link">查看</a></div></div>'};

      const data = response.data;

      const news_html = json2html.transform(data,template);

      $("#home-training-container").html(news_html);
    }).fail(function() {
      $("#home-training-title").hide();
    });
  }
}
