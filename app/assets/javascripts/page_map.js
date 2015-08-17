function drawMap(){

	var anonLocationData = gon.anonLocationMap; 

	if ($("#map").length) {
		$('#map').vectorMap({
		    map: 'world_mill_en',
		    zoomOnScroll: false,
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
		            fill: '#C9C5C5',
		        },
		        hover: {
		            "fill-opacity": 0.8
		        }
		    }
		});		
	}

};
