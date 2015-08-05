$(function(){
	// debugger;
      $('#world-map').vectorMap({map: 'world_mill_en',
          backgroundColor: 'transparent',
          regionStyle: {
            initial: {
              fill: '#1ABC9C',
            },
            hover: {
              "fill-opacity": 0.8
            }
          },
          markerStyle:{
              initial:{
                r: 10
              },
               hover: {
                r: 12,
                stroke: 'rgba(255,255,255,0.8)',
                "stroke-width": 3
              }
            }});



});
