$(function(){

	var anonLocationData = gon.anonLocationMap

	$('#map').vectorMap({
	    map: 'world_mill_en',
	    series: {
	      regions: [{
	        values: anonLocationData,
	        scale: ['#44C6AD', '#e84c3d'],
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
