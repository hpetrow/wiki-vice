$(function() {
 Pusher.log = function(message) {
    if (window.console && window.console.log) {
      window.console.log(message);
    }
  };

  var id = $("#page_id").text();

  var pusher = new Pusher('0c88ff9f8382fb32596e', {
    encrypted: true
  });
  var channel = pusher.subscribe('page_results_' + id);


  channel.bind('pusher:subscription_succeeded', function() {
    channel.bind('get_page', function(data) {
      // alert(data.title);
      console.log(data.id);
      // alert(data.revisionRate);
      // pusher.unsubscribe("page_results");
      $.ajax({
        method: "GET",
        url: "/dashboard",
        data: {id: data.id},
        dataType: "script"
      });
    });
  });
});
