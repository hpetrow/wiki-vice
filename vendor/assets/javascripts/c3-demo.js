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
               format: '%m/%d/%Y'
             //format: '%Y' // format string is also available for timeseries data
           }
               
         }
       }
        // zoom: {
        //   enabled: true
        // }
      });
});
