function histogram() {
    var id = $("#page_id").text();
    $.ajax({
      url: '/histogram',
      type: 'GET',
      dataType: 'json',
      data: {id: id},
    })
    .success(function(data) {
      var colors = ['#000'];
      var chart = c3.generate({
        bindto: '#zoom',
        data: {
          x: 'x',
          columns: [
            data.revDates,
            data.revCounts
          ],
          type: 'line',
          color: function(color) {
            return colors[0];
          }
        },
        axis : {
          x : {
            type: 'timeseries',
            tick : {
              rotate: -45,
              multiline: false,
              format: '%m/%d/%Y'
           } ,
           height: 130    
          }
        },
        zoom: {
          enabled: true
        }
      });      
    });
};