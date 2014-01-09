window.firebaseBase = 'https://chartms.firebaseio.com';
window.firebaseTexts = 'https://chartms.firebaseio.com/example_texts';
window.firebaseData = 'https://chartms.firebaseio.com/example_data';

window.appOnStart = function() {
  console.log("Initialize");
};

window.appOnDataLoaded = function(data, snapshot) {
  var chart, chartData, chartDataRaw, chartOptions, key, val;
  
  // Console log loaded data
  console.log("Loaded data", data);
  
  // Put some text to webpage
  $("#data-count").text(Object.keys(data).length);
  
  // Prepare data
  chartDataRaw = [["Cat type", "Age"]];
  for (key in data) {
    val = data[key];
    chartDataRaw.push([key, val]);
  }
  
  // And create a chart
  chartData = google.visualization.arrayToDataTable(chartDataRaw);
  chartOptions = {
    legend: "none",
    hAxis: {
      title: "Cat type"
    },
    vAxis: {
      title: "Age [years]"
    }
  };
  chart = new google.visualization.ColumnChart(document.getElementById("example-column-chart"));
  chart.draw(chartData, chartOptions);
};