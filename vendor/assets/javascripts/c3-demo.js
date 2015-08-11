$(function () {
      var chart = c3.generate({
         bindto: '#zoom',

        data: {
          x: 'x',
          columns: [
            gon.revDates,
            gon.revCounts
          ],
          colors: {
            x: '#41BB99',
          },
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
