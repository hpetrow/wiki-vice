$(function() {
    var anonData = [
        {
            value: gon.anonData[225],
            color:"#F7464A",
            highlight: "#FF5A5E",
            label: gon.anonCountryName[0]

        },
        {
            value: gon.anonData[0],
            color: "#46BFBD",
            highlight: "#5AD3D1",
            label: gon.anonCountryName[1]
        },
        {
            value: gon.anonData[38],
            color: "#FDB45C",
            highlight: "#FFC870",
            label: gon.anonCountryName[2]
        },
        {
            value: gon.anonData[233],
            color: "#949FB1",
            highlight: "#A8B3C5",
            label: gon.anonCountryName[3]
        },
        {
            value: gon.anonData[191],
            color: "#4D5360",
            highlight: "#616774",
            label: gon.anonCountryName[4]
        }

    ];



    var options = {
      scaleShowLabelBackdrop: true,
      scaleBackdropColor: "rgba(255,255,255,0.75)",
      scaleBeginAtZero: true,
      scaleShowLine: true,
      animationSteps: 40,
    };

    var ctx = document.getElementById("anonCountriesChart").getContext("2d");
    var anonChart = new Chart(ctx).PolarArea(anonData, options);
});