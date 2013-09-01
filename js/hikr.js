/*
	Hikr - Hiking. With friends.
*/
(function(){


var Hikr = function(maps, container){

      //http://a.tiles.mapbox.com/v3/hikr.map-bcefinb2/page.html
      //'http://{s}.tiles.mapbox.com/v3/hikr.map-gtn520tv/{z}/{x}/{y}.png
    //      http://{S}tile.stamen.com/", layer, "/{Z}/{X}/{Y}
  this.lineStyle = {
    "color": "#ff4400",
    "weight": 4,
    "opacity": 0.7
  };

  this.maps = maps;

  this.container = $(container);
  this.map = L.map(container).setView([ 35.358, 138.731], 6);
  var map = this.map;
  var self = this;
  map.on("zoomend", function(){
    self.adjustInterface();
  }).on("click", function(e){
    var center = e.latlng; //this.mouseEventToLatLng(e.latlng);
    var lat = Math.round(center.lat*1000000)/1000000.0;
    var lng = Math.round(center.lng*1000000)/1000000.0;
    console.log(lng+","+lat);
  });
  //
  var bg = L.tileLayer('http://{s}.tiles.mapbox.com/v3/hikr.map-gtn520tv/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery &copy; <a href="http://mapbox.com">MapBox</a>, Photos from Panoramio are copyright of their respective authors.',
      maxZoom: 16
  });
  map.zoomControl.setPosition("topright");
   // var panoramio = new L.Panoramio({maxLoad: 50, maxTotal: 250});
  map.addLayer(bg);
  // map.addLayer(panoramio);
  var layers = { "Map": bg };
  // var overlays = { "Photos": panoramio };
  // var control_layers = new L.Control.Layers(layers, overlays).addTo(map);

  this.loadMaps(maps);

};

 Hikr.prototype.loadMaps = function(){

  var makeMarker = function(feature, latlng){
      var label = '';

      if(feature.properties.hasOwnProperty("label")){
        if(typeof(feature.properties.label)==="string")
          label = feature.properties.label;
        else if(typeof(feature.properties.label)=="object"){
          for(var lang in feature.properties.label){
            label += '<span class="lang-'+lang+'">'+feature.properties.label[lang]+'</span> ';
          }
        }
      } else if(feature.properties.hasOwnProperty("name")){
        label = feature.properties.name;
      }
      if(feature.properties.type==="summit" || feature.properties.elevation){
        var ele = feature.geometry.coordinates[2];
        var ele2 = feature.properties.elevation || 0;
        if(ele2>ele) ele = ele2;
        label += " ("+ele+"m)";
      }
      var icon = L.divIcon({
          className:"maki-icon "+feature.properties.type,
          html:label,
          iconSize: [26,24]
      });
      var marker = L.marker(latlng, {icon: icon});
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
            [{ data:plot, lines:{fillColor: "#4A5A61", show:true, fill:true}} ],
            {colors: ["#4A5A61"], grid:{show:true, markings: { xaxis: false }, borderWidth: 0}, yaxis: { max: 1500} }
            );
      }
    };



    var map = this.map;
    var app = this;
    for(var i in this.maps){
      var url = this.maps[i];
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
 };

 Hikr.prototype.adjustInterface = function(){
    var zoom = this.map.getZoom();
    if(zoom<13) this.container.addClass("hide-labels");
    else this.container.removeClass("hide-labels");
  };

  window.Hikr = Hikr;

})();
