 $(function() {
    var button = $('.search-loader');
      var loadPopUp = $('.loader');
      var hideOnSubmit = $('.hideOnSubmit');

      button.click(function() {
        loadPopUp.fadeIn();
        hideOnSubmit.fadeOut();
      });
 });