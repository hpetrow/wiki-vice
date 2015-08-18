function pageMap(){

	// var anonLocationData = gon.anonLocationMap; 

	var id = $("#page_id").text();

	$.ajax({
		url: '/map',
		type: 'GET',
		dataType: 'json',
		data: {id: id}
	})
	.success(function(data){
		anonLocationData = data.mapData;
		console.log(anonLocationData);		

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
	});

};
