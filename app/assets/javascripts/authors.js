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
    },
    {
        value: gon.data[3][1],
        color: "#3598DB",
        highlight: "#5DADE2",
        label: gon.data[3][0]
    },
    {
        value: gon.data[4][1],
        color: "#293949",
        highlight: "#3E4D5B",
        label: gon.data[4][0]
    }
];

var options = {
    scaleShowLabels : true,
    animation: true,
    animationEasing: "easeOutQuart",
    animationSteps: 40,
  };
  
  var myChart = new Chart(document.getElementById("authorContributionsChart").getContext("2d")).Pie(data, options);


///////////////////Begin World Chart///////////////////////////
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
