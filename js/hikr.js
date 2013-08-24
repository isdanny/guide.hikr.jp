
var Hikr = function(maps, container){

  this.icons = {
    none: L.icon({iconUrl:"/icons/train.png",  labelAnchor: [1, 1], iconSize: [1,1], iconAnchor: [1,1]}),
    station: L.icon({iconUrl:"/icons/train.png",  labelAnchor: [0, 0], iconSize: [32,37], iconAnchor: [24,30]}),
    toilet: L.icon({iconUrl:"/icons/toilets.png", labelAnchor: [0, 0], iconSize: [32,37], iconAnchor: [24,30]}),
    pass: L.icon({iconUrl:"/icons/pass.png", labelAnchor: [0, 0], iconSize: [32,37], iconAnchor: [24,30]}),
    waterfall: L.icon({iconUrl:"/icons/waterfall.png", labelAnchor: [0, 0], iconSize: [32,37], iconAnchor: [24,30]})
  };

      //http://a.tiles.mapbox.com/v3/hikr.map-bcefinb2/page.html
      //'http://{s}.tiles.mapbox.com/v3/hikr.map-gtn520tv/{z}/{x}/{y}.png
  this.lineStyle = {
    "color": "#ff4400",
    "weight": 4,
    "opacity": 0.7
  };

  this.init = function(container){
    this.map = L.map('map').setView([ 35.358, 138.731], 6);
    var map = this.map;
    var bg = L.tileLayer('http://{s}.tiles.mapbox.com/v3/hikr.map-bcefinb2/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery &copy; <a href="http://mapbox.com">MapBox</a>, Photos from Panoramio are copyright of their respective authors.',
      maxZoom: 16
    });
    map.zoomControl.setPosition("topright");
    var panoramio = new L.Panoramio({maxLoad: 50, maxTotal: 250});
    map.addLayer(bg);
    map.addLayer(panoramio);
    var layers = { "Map": bg };
    var overlays = { "Photos": panoramio };
    // var control_layers = new L.Control.Layers(layers, overlays).addTo(map);
  };

  var makeMarker = function(feature, latlng){
      var marker = L.circleMarker(latlng);
      if(feature && feature.properties.hasOwnProperty("type")){
        var type = feature.properties.type;
        if(icons.hasOwnProperty(type)) marker =  L.marker(latlng, {icon:icons[type]});
        else marker = L.marker(latlng, {icon:icons.none});
      }
      var label = "";
      if(feature.geometry.type=="Point"){
        if(feature.properties.hasOwnProperty("label")){
          label = feature.properties.label;
        } else if(feature.properties.hasOwnProperty("name")){
          label = feature.properties.name;
        }
        if(feature.properties.type==="summit" || feature.properties.elevation){
          var ele = feature.geometry.coordinates[2];
          var ele2 = feature.properties.elevation || 0;
          if(ele2>ele) ele = ele2;
          label += " ("+ele+"m)";
        }
        if(label.length>0) marker.bindLabel(label,{noHide: true});
      }
      if(feature.properties.hasOwnProperty("popup"))
        marker.bindPopup(feature.properties.popup);
      if(label){
        marker.addTo(map);
        try{
          marker.showLabel();
        }catch(e){}
      }
      return marker;
  };

    var onEachFeature = function(feature, latlng){
      function d(a,b){
        return Math.sqrt((a[0]-b[0])*(a[0]-b[0])+(a[1]-b[1])*(a[1]-b[1]));
      }
      if(feature.geometry.type!="Point"){
        var plot = [];
        var dist = 0;
        var previous = feature.geometry.coordinates[0];

        for(var i in feature.geometry.coordinates){
          var dd = d(previous, feature.geometry.coordinates[i]);
          if(dd>0.0005 && feature.geometry.coordinates[i][2]<4000){
            dist += dd;
            plot.push([dist,feature.geometry.coordinates[i][2]]);
            previous = feature.geometry.coordinates[i];
          }
        }
        $.plot("#plot",
            [{ data:plot, lines:{color: "red", show:true, fill:true}} ],
            {colors: ["#2ca9ad"], grid:{show:false}});
      }
    };

  this.loadMaps = function(maps){
    var map = this.map;
    var app = this;
    for(var i in maps){
      var url = maps[i];
      if(url) $.get(url,function(data){
        var geojsonFeature = data;
        // L.geoJson(geojsonFeature).addTo(map);
        var myLayer = L.geoJson(data,{
          style: app.lineStyle,
          pointToLayer: makeMarker,
          onEachFeature: onEachFeature
        }).addTo(map);
        // myLayer.addData(geojsonFeature).setStyle(myStyle);
        var bounds = myLayer.getBounds();
        map.fitBounds(bounds);
      }); // get
    }// for
  };// loadMaps

  this.init(container);
  this.loadMaps(maps);

};