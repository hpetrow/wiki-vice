$(function () {
      var chart = c3.generate({
        bindto: '#zoom',
        data: {
          x: 'x',
          columns: [
            gon.revDates,
            gon.revCounts
          ],
          type: 'spline',
          colors: {
            x: '#000'
          },
          color: function(color) {
            return color;
          }
        },
        axis : {
            x : {
               type : 'timeseries',
               tick: {
                rotate: -45,
                multiline: false,
                format: '%m/%d/%Y'
           }
               
         }
       },
        zoom: {
          enabled: true
        }
      });
});
