import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.load()
  }

  load() {
    $.ajax('https://portal.thape.com.cn/api/v1/index/notices?page=1&type=list', {
      dataType: 'json'
    }).done(function(response) {
      const template = {'<>':'li','class':'list-group-item','html':'<a href="${url}" target="_blank">${title}</a>'};

      const data = response.data;

      const news_html = json2html.transform(data,template);

      $("#company-news-ul").html(news_html);
    });
  }
}
