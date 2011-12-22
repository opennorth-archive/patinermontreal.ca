var map = new L.Map('map', {
    center: new L.LatLng(51.505, -0.09), 
    zoom: 13
});

var cloudmadeUrl = 'http://{s}.tile.cloudmade.com/YOUR-API-KEY/997/256/{z}/{x}/{y}.png',
    cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18});

map.addLayer(cloudmade);
