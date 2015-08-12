$(function() {
  var button = $('#search-loader');
  var loadPopUp = $('.loader');
  var pageDimmer = $('#page-dimmer');
  
  button.click(function() {
    loadPopUp.show();
    pageDimmer.show();
  });

});