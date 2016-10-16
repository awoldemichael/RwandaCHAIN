// initialize the map on the "map" div with a given center and zoom
var map = L.map('mapid', {
    center: [-1.942806, 29.88074],
    zoom: 9
});

// var Esri_OceanBasemap
L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}', {
	attribution: 'Tiles &copy; Esri &mdash; Sources: GEBCO, NOAA, CHS, OSU, UNH, CSUMB, National Geographic, DeLorme, NAVTEQ, and Esri',
	minZoom: 9,
  maxZoom: 13,
}).addTo(map);
