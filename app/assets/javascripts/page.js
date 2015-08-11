$(function() {
  $('ul.nav-tabs').on('click', 'li', function (e) {
    window.activeTab = e.target;
    var id = $(this).data('id');

    $.ajax({
      url: '/revisions/' + id,
      dataType: 'script'
    });
  });
});

