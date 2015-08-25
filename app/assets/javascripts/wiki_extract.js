function wikiExtract() {
  var callback = 'https://en.wikipedia.org/w/api.php?'
  var action = 'query';
  var format = 'json';
  var prop = 'extracts';
  var exsentences = '2';
  var explaintext = 'true';
  var extract;
  var pages;
  var pageData;

  console.log(callback);

  $.ajax({
    url: callback,
    dataType: 'jsonp',
    data: {
      action: action,
      format: format,
      prop: prop,
      exsentences: exsentences,
      explaintext: explaintext,
      titles: gon.extractTitle
    }
  })
  .done(function(response) {
    console.log(response);
    extract = response.query.pages[gon.extractPageId].extract;
    $("#extract").html(extract);
  });
};