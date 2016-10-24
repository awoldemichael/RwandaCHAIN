// initialize the map on the "map" div with a given center and zoom
var map = L.map('mapid', {
  center: [-1.942806, 29.88074],
  maxBounds: [
      [-0.442806, 28.38074],
      [-3.442806, 31.38074]
],
  zoom: 9
});

// Basemap: var Esri_OceanBasemap (only goes to zoom level 10)
L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}', {
  attribution: 'Tiles &copy; Esri &mdash; Sources: GEBCO, NOAA, CHS, OSU, UNH, CSUMB, National Geographic, DeLorme, NAVTEQ, and Esri',
  minZoom: 9,
  maxZoom: 12,
}).addTo(map);

// temporary dummy data containing combined summaries by Province
var summaryData = [{
  'Prov_Name': 'Kigali City',
  'density': 50
}, {
  'Prov_Name': 'Southern Province',
  'density': 30
}, {
  'Prov_Name': 'Eastern Province',
  'density': 25
}, {
  'Prov_Name': 'Northern Province',
  'density': 10
}, {
  'Prov_Name': 'Western Province',
  'density': 2
}]

// Popup
function onEachFeature(feature, layer) {
  // does this feature have a property named popupContent?
  if (feature.properties && feature.properties.Prov_ID) {
    layer.bindPopup(feature.properties.Prov_ID);
  }
}

// scale_fill function
function getColor(d) {
  return d > 55 ? '#800026' :
  d > 44  ? '#BD0026' :
  d > 33  ? '#E31A1C' :
  d > 22  ? '#FC4E2A' :
  d > 5   ? '#FD8D3C' :
  d > 2   ? '#FEB24C' :
  d > 1   ? '#FED976' :
  '#FFEDA0';
}

// Map values for each region name to the color scale
function getRegionColor(region) {
  var color;

  for (var i = 0; i < summaryData.length; i++) {
    if(summaryData[i].Prov_Name == region){
      color = getColor(summaryData[i].density);
      break;
    }
  }
  return color;
}

// Style function for choropleth
function style(feature) {
  return {
    fillColor: getRegionColor(feature.properties.Prov_Name),
    weight: 0.75,
    opacity: 1,
    color: 'white',
    fillOpacity: 0.6
  };
}


// Map Admin3 polygons
var admin3 = new L.GeoJSON.AJAX("geodata/RWA_admin1.geojson",
{style: style}
).addTo(map);



//  .setLatLng([-2.5, 28])
//  .setContent("I am a standalone popup.")
//  .openOn(map);
//([
//  [-2.696523, 27.41864],
//  [-1.099525, 32.44473]
//])
