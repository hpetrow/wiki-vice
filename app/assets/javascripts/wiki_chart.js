$(function(){

	var data = [
    {
        value: gon.data[0][1],
        color:"#F7464A",
        highlight: "#FF5A5E",
        label: gon.data[0][0]
    },
    {
        value: gon.data[1][1],
        color: "#46BFBD",
        highlight: "#5AD3D1",
        label: gon.data[1][0]
    },
    {
        value: gon.data[2][1],
        color: "#FDB45C",
        highlight: "#FFC870",
        label: gon.data[2][0]
    }
]

var options = {
		scaleShowLabels : true,
		animation: true,
		animationEasing: "easeOutQuart",
		animationSteps: 40,
	};
	
	var myChart = new Chart(document.getElementById("authorContributionsChart").getContext("2d")).Pie(data, options);


    

})
