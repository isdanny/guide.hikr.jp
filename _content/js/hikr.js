/*
	Hikr - Hiking. With friends.
*/
(function(){
var Hikr = function(container, features){

L.Control.Language = L.Control.extend({
    options: {
        position: 'topright',
        click: function(){}
    },

    onAdd: function (map) {
      var controlDiv = L.DomUtil.create('div', 'leaflet-control-language leaflet-control leaflet-bar');
      L.DomEvent
        .addListener(controlDiv, 'click', L.DomEvent.stopPropagation)
        .addListener(controlDiv, 'click', L.DomEvent.preventDefault)
        .addListener(controlDiv, 'dblclick', L.DomEvent.preventDefault)
        .addListener(controlDiv, 'dblclick', L.DomEvent.stopPropagation)
        .addListener(controlDiv, 'click', this.options.click );
      var controlUI = L.DomUtil.create('a', 'leaflet-control-language-interior', controlDiv);
      controlUI.href="#";
      controlUI.title = 'Language';
      return controlDiv;
    }
});

L.control.language = function (options) {
    return new L.Control.Language(options);
};

      //http://a.tiles.mapbox.com/v3/hikr.map-bcefinb2/page.html
      //'http://{s}.tiles.mapbox.com/v3/hikr.map-gtn520tv/{z}/{x}/{y}.png
    //      http://{S}tile.stamen.com/", layer, "/{Z}/{X}/{Y}
  this.lineStyle = {
    "color": "#ff4400",
    "weight": 4,
    "opacity": 0.7
  };

  this.container = $(container);
  this.features = features;
  this.map = L.map(container).setView([ 35.358, 138.731], 6);
  this.map.scrollWheelZoom.disable();
  var map = this.map;

  var self = this;
  this.fg = new L.FeatureGroup([]);
  map.on("zoomend", function(){
    self.adjustInterface();
  }).on("click", function(e){
    var center = e.latlng; //this.mouseEventToLatLng(e.latlng);
    var lat = Math.round(center.lat*1000000)/1000000.0;
    var lng = Math.round(center.lng*1000000)/1000000.0;
  });
  //
  this.zoomClass = "zoom-16";
  var bg = L.tileLayer('http://{s}.tiles.mapbox.com/v3/hikr.map-gtn520tv/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery &copy; <a href="http://mapbox.com">MapBox</a>, Photos from Panoramio are copyright of their respective authors.',
      maxZoom: 16
  });
  map.zoomControl.setPosition("topright");
  var languageControl = new L.Control.Language({ click: function(){
    var c = $("#map");
    if(c.hasClass("jp")) c.removeClass("jp");
    else c.addClass("jp");
    if(c.hasClass("en")) c.removeClass("en");
    else c.addClass("en");
    return false;
  }});
  this.map.addControl(languageControl);
   // var panoramio = new L.Panoramio({maxLoad: 50, maxTotal: 250});
  map.addLayer(bg);
  map.addLayer(this.fg);
  // map.addLayer(panoramio);
  var layers = { "Map": bg };

};


  Hikr.onEachFeature = function(feature, latlng){
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
        try{
          $.plot("#plot",
            [{ data:plot, lines:{fillColor: "#4A5A61", show:true, fill:true}} ],
            {colors: ["#4A5A61"], grid:{show:true, markings: { xaxis: false }, borderWidth: 0}, yaxis: { max: 1500} }
            );
        }catch(e){}
      }
    };

  Hikr.makeMarker = function(feature, latlng){
      var label = '&nbsp;';
      var className = className+ " hikricon-"+feature.properties.type;
      if(feature.properties.hasOwnProperty("popup")){
        className = 'preview-box';
        label = "<div class='inside'>"+feature.properties.popup+"</div>";
      }
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
          className: className,
          html: label,
          iconSize: [26,24]
      });
      var marker = L.marker(latlng, {icon: icon});
      if(feature.properties.url){
        marker.url = feature.properties.url;
        marker.on("click",function(){
          window.location = this.url;
        });
      }
      return marker;
  };

 Hikr.prototype.loadMap = function(url, callback, getBounds){
  var app = this;
  var map = this.map;
  $.get(url,function(data){
        var myLayer = L.geoJson(data,{
          style: app.lineStyle,
          pointToLayer: Hikr.makeMarker,
          onEachFeature: Hikr.onEachFeature
        });
        for(var i in myLayer.getLayers()){
          myLayer.getLayers()[i].addTo(app.fg);
        }
        // myLayer.addData(geojsonFeature).setStyle(myStyle);
        if(getBounds){
          var bounds = myLayer.getBounds();
          map.fitBounds(bounds);
        }
        callback.call(app);
  });
 };

 Hikr.prototype.loadMaps = function(maps, callback){
    callback = callback || function(){};
    this.maps = maps;
    var getBounds = true;
    for(var i in this.maps){
      var url = this.maps[i];
      if(url) this.loadMap(url, callback, getBounds);
      getBounds = false;
    }
 };

Hikr.prototype.adjustInterface = function(){
  this.container.removeClass(this.zoomClass);
  var zoom = this.map.getZoom();
  this.zoomClass = "zoom-"+zoom;
  this.container.addClass(this.zoomClass);
  if(zoom<13) this.container.addClass("hide-labels");
  else this.container.removeClass("hide-labels");
};

Hikr.prototype.makeEditable = function(){
  var app = this;
  var drawControl = new L.Control.Draw({
      edit: {
          featureGroup: this.fg
      },
      position: "topright",
      draw:{
        rectangle: false,
        polygon: false,
        circle: false,
        polyline:{
          shapeOptions: app.lineStyle
        },
        marker:{
          icon: L.divIcon({
            className:"icon marker",
            html:"",
            iconSize: [26,24]
          })
        }
      }
  });
  this.map.on('draw:created', function (e) {
    var type = e.layerType,
        layer = e.layer;
    if (type === 'marker') {
    }
    // Do whatever else you need to. (save to db, add to map etc)
    app.fg.addLayer(layer);
  });
  this.map.addControl(drawControl);
};

window.Hikr = Hikr;

})();



$(document).ready(function(){
  $(".search-bar input").on("keyup",function(){
    var term = $(this).val()
    var letter = term[0];
    var $results = $('.search-results');
    $.get('/data/search/'+letter+'.json', function(data){
      console.log("---");
      $results.html('');
      for(var keyword in data){
        if(keyword.match(term)){
          for(var i in data[keyword]){
            $results.append('<a href="'+data[keyword][i]['url']+'">'+data[keyword][i]['title']+'</a>')

          }
        }
      }
    })
  });
})
