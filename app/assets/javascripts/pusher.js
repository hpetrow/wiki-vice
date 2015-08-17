  var pusher = new Pusher('0c88ff9f8382fb32596e');
  var channel = pusher.subscribe('page_results');
  channel.bind('get_page', function(data) {
    alert(data.title);
    alert("hello world");
    console.log("hello world");
  });  
