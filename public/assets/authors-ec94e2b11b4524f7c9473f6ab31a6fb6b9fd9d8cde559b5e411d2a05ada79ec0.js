$(function(){
  var data = [
    {
        value: (gon.data[0][1] === undefined) ? 0 : gon.data[0][1],
        color:"#F7464A",
        highlight: "#FF5A5E",
        label: (gon.data[0][0] === undefined) ? nil : gon.data[0][0]
    },
    {
        value: (gon.data[1][1] === undefined) ? 0 : gon.data[1][1],
        color: "#46BFBD",
        highlight: "#5AD3D1",
        label: (gon.data[1][0] === undefined) ? nil : gon.data[1][0]
    },
    {
        value: (gon.data[2][1] === undefined) ? 0 : gon.data[2][1],
        color: "#FDB45C",
        highlight: "#FFC870",
        label: (gon.data[2][0] === undefined) ? nil : gon.data[2][0]
    },
    {
        value: (gon.data[3][1] === undefined) ? 0 : gon.data[3][1],
        color: "#3598DB",
        highlight: "#5DADE2",
        label: (gon.data[3][0] === undefined) ? nil : gon.data[3][0]
    },
    {
        value: (gon.data[4][1] === undefined) ? 0 : gon.data[4][1],
        color: "#293949",
        highlight: "#3E4D5B",
        label: (gon.data[4][0] === undefined) ? nil : gon.data[4][0]
    }
];

var options = {
    // scaleShowLabels : true,
    // animation: true,
    // animationEasing: "easeOutQuart",
    // animationSteps: 40,
  };
  
  var myChart = new Chart(document.getElementById("authorContributionsChart").getContext("2d")).PolarArea(data, options);
});
