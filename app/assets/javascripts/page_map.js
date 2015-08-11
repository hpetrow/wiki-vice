$(function(){

	var anonLocationData = gon.anonLocationMap; 


	$('#map').vectorMap({
	    map: 'world_mill_en',
	    series: {
	      regions: [{
	        values: anonLocationData,
	        scale: ['#eda3a3', '#e84c3d'],
	        normalizeFunction: 'polynomial'
	      }]
	    },
	    backgroundColor: 'transparent',
	    regionStyle: {
	        initial: {
	            fill: '#1ABC9C',
	        },
	        hover: {
	            "fill-opacity": 0.8
	        }
	    }
	});
});
