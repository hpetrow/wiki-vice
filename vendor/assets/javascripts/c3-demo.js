$(function () {
      var chart = c3.generate({
         bindto: '#zoom',
        data: {
          x: 'x',
          columns: [
            gon.revDates,
            gon.revCounts
          ]
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
