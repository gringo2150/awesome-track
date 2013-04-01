/**
 * @class Ext.ux.OpenMapPanel
 * @extends Ext.Panel
 * @author Graham Bacon
 * Uses open layers.
 */
Ext.ux.OpenMapPanel = Ext.extend(Ext.Panel, {
    initComponent : function(){
        //Variable for events where scope cannot be changed
        var map = this;
        this.imagePath = 'application/javascript/ext/ux/OpenMapPanel/';
        //Search field for the panel toolbar
        var searchField = new Ext.form.TextField({
			width: 200,
			scope: this,
			listeners: {
				specialkey: function(field, value) {
					map.geoCodeLookup(field.getValue());
				}
			}
		});
		//Default config, these values are used in the event no defaults are provided.
        var defConfig = {
			plain: true,
			zoomLevel: 3,
			yaw: 180,
			pitch: 0,
			zoom: 0,
			loadMask: null,
			searchWindow: null,
			addMode: null,
			addModeClicks: null,
			markersList: [],
			border: false,
			tbar: new Ext.Toolbar({
				items: ['Search Locations: ', searchField,' ',{
						text: 'Search',
						scope: this,
            			icon: this.imagePath + 'search.png',
            			tooltip: 'Search the map for locations',
            			handler: function() {
            				this.geoCodeLookup(searchField.getValue());
            			}
            		},' ',{
            			text: 'Clear Markers',
            			icon: this.imagePath + 'map_clear.png',
            			scope: this,
            			tooltip: 'Clear the map of markers',
            			handler: function() {
            				this.clearMarkers();
            				if(this.searchWindow != null) {
            					this.searchWindow.close();
            				}
            			}
            		},'-'
            	]
			})
        };
        //Merge defaults with the defined config.
        Ext.applyIf(this,defConfig);
        //Call the parent initComponent
        Ext.ux.OpenMapPanel.superclass.initComponent.call(this);
    },
    afterRender : function(){
    	//If no loadMask has been defined, create one here.
    	if(this.loadMask == null) {
    		this.loadMask = new Ext.LoadMask(this.body.dom, {msg:"Please wait..."});
    	}
    	//Open layers MousePosition, usefull for coords.
    	var mouseInfo = new OpenLayers.Control.MousePosition();
        var wh =  null;
        if(this.ownerCt != undefined) {
        	 wh = this.ownerCt.getSize();
        } else {
        	wh = [this.width, this.height]
        }
        Ext.applyIf(this, wh);
        //Define the open layers map in the panel
        this.map = new OpenLayers.Map(this.body.dom, {
        	size: new OpenLayers.Size({ w:this.getInnerWidth(), h:this.getInnerHeight()}),
			controls: [
				new OpenLayers.Control.Navigation(), 
				new OpenLayers.Control.PanZoomBar(), 
				new OpenLayers.Control.Attribution(),
				new OpenLayers.Control.LayerSwitcher(),
				mouseInfo
			]
		});
		
		/**********
		* OSM Layers, add layers to the map, defaults are markers, lines and OSM data.
		**********/
		
		this.map.addLayer(new OpenLayers.Layer.OSM());
		
		var gphy = new OpenLayers.Layer.Google(
        	"Google Physical",
        	{type: google.maps.MapTypeId.TERRAIN}
    	);
    	var gmap = new OpenLayers.Layer.Google(
        	"Google Streets", // the default
        	{numZoomLevels: 20}
    	);
    	var ghyb = new OpenLayers.Layer.Google(
        	"Google Hybrid",
        	{type: google.maps.MapTypeId.HYBRID, numZoomLevels: 20}
    	);
    	var gsat = new OpenLayers.Layer.Google(
        	"Google Satellite",
        	{type: google.maps.MapTypeId.SATELLITE, numZoomLevels: 22}
    	);

    	this.map.addLayers([gphy, gmap, ghyb, gsat]);
        
        this.lineLayer = new OpenLayers.Layer.Vector("Line Layer");
        this.map.addLayer(this.lineLayer);
        this.map.addControl(new OpenLayers.Control.DrawFeature(this.lineLayer, OpenLayers.Handler.Path));
        
        this.polyLayer = new OpenLayers.Layer.Vector("Polygon Layer");
        this.map.addLayer(this.polyLayer);
        this.map.addControl(new OpenLayers.Control.DrawFeature(this.polyLayer, OpenLayers.Handler.Path));
        
		this.markerLayer = new OpenLayers.Layer.Markers( "Markers" );
		this.map.addLayer(this.markerLayer);
		
		/**********
		* Events mapping, map the open layers events to the panel passing any additional information needed such as lat, long
		**********/
		
		/**
		 * Wrapper for the click event, includes additional information, point and map.
		 */
		this.map.events.register('click', this, function(evt){
			var point = this.map.getLonLatFromViewPortPx(
				new OpenLayers.Pixel(evt.xy.x, evt.xy.y)
			);
			var tmpPoint = this.map.getLonLatFromViewPortPx(
				new OpenLayers.Pixel(evt.xy.x, evt.xy.y)
			);
			tmpPoint.transform(this.map.getProjectionObject(), new OpenLayers.Projection("EPSG:4326"));
			this.fireEvent('click', evt, point, tmpPoint, this.map);
		});
		
		/**
		 * Wrapper for the dblclick event, includes additional information, point and map.
		 */
		this.map.events.register('dblclick', this, function(evt){
			var point = this.map.getLonLatFromViewPortPx(
				new OpenLayers.Pixel(evt.xy.x, evt.xy.y)
			);
			var tmpPoint = this.map.getLonLatFromViewPortPx(
				new OpenLayers.Pixel(evt.xy.x, evt.xy.y)
			);
			tmpPoint.transform(this.map.getProjectionObject(), new OpenLayers.Projection("EPSG:4326"));
			this.fireEvent('dblclick', evt, point, tmpPoint, this.map);
		});
		
		/**
		 * Wrapper for the rightclick event, includes additional information, point and map.
		 */
		var panel = this;
		this.map.div.oncontextmenu = function noContextMenu(evt) {
			var point = panel.map.getLonLatFromViewPortPx(
				new OpenLayers.Pixel(evt.layerX, evt.layerY)
			);
			var tmpPoint = panel.map.getLonLatFromViewPortPx(
				new OpenLayers.Pixel(evt.layerX, evt.layerY)
			);
			var event =  Ext.EventObject.setEvent(evt);
			tmpPoint.transform(panel.map.getProjectionObject(), new OpenLayers.Projection("EPSG:4326"));
			panel.fireEvent('contextmenu', event, point, tmpPoint, map);  
		};
		
		//Call the map on ready event.
        this.onMapReady();
        //Call the parent calss afterrender event.
        Ext.ux.OpenMapPanel.superclass.afterRender.call(this); 
    },
    onMapReady : function(){
        this.addMarkers(this.markers);
        //this.addMapControls();
        //this.addOptions();
        this.fireEvent('mapReady', this); 
    },
    onResize : function(w, h){
        this.getMap().updateSize();
        Ext.ux.OpenMapPanel.superclass.onResize.call(this, w, h);
    },
    setSize : function(width, height, animate){
        this.getMap().updateSize();
        Ext.ux.OpenMapPanel.superclass.setSize.call(this, width, height, animate);
    },
    getMap : function(){
        return this.map;
    },
    getCenter : function(){
        return this.getMap().getCenter();
    },
    setCenter : function(point, zoomLevel) {
    	if(!typeof zoomLevel === 'number') {
    		zoomLevel = this.zoomLevel;	
    	}
    	this.getMap().setCenter(point, zoomLevel);
    },
    getCenterLatLng : function(){
        var ll = this.getCenter();
        return {lng: ll.lat, lat: ll.lon};
    },
    setCenterLatLng : function(lat, lng, zoomLevel) {
    	if(!typeof zoomLevel === 'number') {
    		zoomLevel = this.zoomLevel;	
    	}
    	var point = this.makePoint(lat, lng);
    	this.getMap().setCenter(point, zoomLevel);
    },
    addMarkers : function(markers) {
        if (Ext.isArray(markers)){
            for (var i = 0; i < markers.length; i++) {
                var mkr_point = this.makePoint(markers[i].lat,markers[i].lng);
                this.addMarker(mkr_point,markers[i].marker, false, markers[i].setCenter, markers[i].listeners);
            }
        }
    },
    /**
     * Author Graham Bacon
     * Adds a marker to the map, if marker object is empty or just a point is passed a default marker is used.
     */
    addMarker : function(point, marker, clear, center, listeners){
		var defMarker = {
			size: {
				length: 32,
				width: 32
			},
			offset: {
				x: -16,
				y: -32
			},
			icon: this.imagePath + 'pin.png'
		};
		
		Ext.applyIf(marker, defMarker);
		
		var size = new OpenLayers.Size(marker.size.length,marker.size.width);
		var offset = new OpenLayers.Pixel(marker.offset.x, marker.offset.y);
		var icon = new OpenLayers.Icon(marker.icon, size, offset);
		
		var mapMarker = new OpenLayers.Marker(point, icon);
					
        if (clear === true){
        	this.clearMarkers();
        }
        if (center === true) {
            this.getMap().setCenter(point, this.zoomLevel);
        }

        if (typeof listeners === 'object'){
            for (evt in listeners) {
            	mapMarker.events.register(evt, point, listeners[evt]);
            }
        }
        this.markersList.push(mapMarker);
		this.markerLayer.addMarker(mapMarker);
		return mapMarker;
    },
    getMarkers: function() {
    	return this.markersList;
    },
    clearMarkers: function() {
    	this.markersList = [];
    	this.markerLayer.clearMarkers();
    },
    makePoint : function(lat, lng) {
    	return new OpenLayers.LonLat(lng, lat).transform(new OpenLayers.Projection("EPSG:4326"), this.map.getProjectionObject());
    },
    makeGeomPoint: function(lat, lng) {
    	var point = new OpenLayers.Geometry.Point(parseFloat(lng), parseFloat(lat));
		point.transform(new OpenLayers.Projection("EPSG:4326"), this.map.getProjectionObject());
		return point;
    },
    addLines : function(path, colour, opacity, weight) {
    	var line = new OpenLayers.Geometry.LineString(path);
		var style = {
			strokeColor: colour,
			strokeOpacity: opacity,
			strokeWidth: weight
		};
		var lineFeature = new OpenLayers.Feature.Vector(line, null, style);
		this.lineLayer.addFeatures([lineFeature]);
    },
    addLine : function(startPoint, endPoint, colour, opacity, weight) {
    	var points = [startPoint, endPoint];
		var line = new OpenLayers.Geometry.LineString(points);
		var style = {
			strokeColor: colour,
			strokeOpacity: opacity,
			strokeWidth: weight
		};
		var lineFeature = new OpenLayers.Feature.Vector(line, null, style);
		this.lineLayer.addFeatures([lineFeature]);
    },
    addPolygon: function(path, strokeColor, strokeWidth, strokeOpacity, fillColor, fillOpacity) {
    	var polyParams = {	
    		strokeColor: strokeColor,
			strokeOpacity: strokeOpacity,
			fillColor: fillColor,
			fillOpacity: fillOpacity,
			strokeWidth: strokeWidth
		}
    	var poly = new OpenLayers.Geometry.Polygon(new OpenLayers.​Geometry.​LinearRing(path));
    	var polyFeature = new OpenLayers.Feature.Vector(poly, null, polyParams);
    	this.polyLayer.addFeatures(polyFeature);
    },
    addPolygons: function() {
    	//Calls the above in a loop.
    },
    addRegPolygon: function(point, radius, sides, rotation, unit, strokeColor, strokeWidth, strokeOpacity, fillColor, fillOpacity) {
    	//Creates a regular polygon at a given point.
    	var mile = 1609.344;
    	var km = 1000;
    	var m = 1;
    	var calcUnit = null;
    	if(unit === 'mile') {
    		calcUnit = (radius * mile);
    	}
    	if(unit === 'km') {
    		calcUnit = (radius * km);
    	}
    	if(unit === 'm') {
    		calcUnit = (radius * m);
    	}
    	var polyParams = {	
    		strokeColor: strokeColor,
			strokeOpacity: strokeOpacity,
			fillColor: fillColor,
			fillOpacity: fillOpacity,
			strokeWidth: strokeWidth
		};
    	var poly = new OpenLayers.Geometry.Polygon.createRegularPolygon(point, calcUnit, sides, rotation);
    	var polyFeature = new OpenLayers.Feature.Vector(poly, null, polyParams);
    	this.polyLayer.addFeatures(polyFeature);
    },
    distanceBetweenPoints: function(startPoint, endPoint) {
    	//Docs at http://www.movable-type.co.uk/scripts/latlong.html
    	console.log("Hello"/*this.map.getProjectionObject()*/);
		var sp = startPoint.clone().transform(new OpenLayers.Projection("EPSG:900913"), new OpenLayers.Projection("EPSG:4326"));
    	var ep = endPoint.clone().transform(new OpenLayers.Projection("EPSG:900913"), new OpenLayers.Projection("EPSG:4326"));
		return OpenLayers.Util.distVincenty(sp, ep);
    },
    distanceToPoint: function(point, bearing, km) {
    	//Docs at http://www.movable-type.co.uk/scripts/latlong.html
    	point.transform(this.map.getProjectionObject(), new OpenLayers.Projection("EPSG:4326"));
    	return OpenLayers.Util.destinationVincenty(point, bearing, km);
    },
    addMapControls : function(){
        if (this.gmapType === 'map') {
            if (Ext.isArray(this.mapControls)) {
                for(i=0;i<this.mapControls.length;i++){
                    this.addMapControl(this.mapControls[i]);
                }
            }else if(typeof this.mapControls === 'string'){
                this.addMapControl(this.mapControls);
            }else if(typeof this.mapControls === 'object'){
                this.getMap().addControl(this.mapControls);
            }
        }
        
    },
    addMapControl : function(mc){
        var mcf = window[mc];
        if (typeof mcf === 'function') {
            this.getMap().addControl(new mcf());
        }    
    },
    addOptions : function(){
        if (Ext.isArray(this.mapConfOpts)) {
            var mc;
            for(i=0;i<this.mapConfOpts.length;i++){
                this.addOption(this.mapConfOpts[i]);
            }
        }else if(typeof this.mapConfOpts === 'string'){
            this.addOption(this.mapConfOpts);
        }        
    },
    addOption : function(mc){
        var mcf = this.getMap()[mc];
        if (typeof mcf === 'function') {
            this.getMap()[mc]();
        }     
    },
    locationSearch : function (addr, callback) {
    	//API Available at http://wiki.openstreetmap.org/wiki/Nominatim
    	Ext.ux.JSONP.request('http://nominatim.openstreetmap.org/search', {
        	callbackKey: 'json_callback',
			params: {
				format: 'json',
				q: addr,
				addressdetails: 1                        
			},
			callback: callback
		});
    },
    geoCodeLookup : function(addr) {
        this.loadMask.show();
        this.locationSearch(addr, this.addAddressToMap.createDelegate(this));
    },
    addAddressToMap : function(response) {     
        var map = this;
        if (response[0] == undefined) {
             Ext.MessageBox.alert('Unable to Locate Address', 'Unable to Locate the Address you provided');
        }else{
        	var tableData = {results: response.length, rows: response};
        	var reader = new Ext.data.JsonReader({
				idProperty: 'id',
				root: 'rows',
				totalProperty: 'results',
				fields: [
					'display_name',
					'lat',
					'lon'
				]
			});
			var memProxy = new Ext.data.MemoryProxy(tableData);
			var tableStore = new Ext.data.Store({
				remoteSort: true,
				reader: reader,
				proxy: memProxy
			});
			var tableColumns = new Ext.grid.ColumnModel({
				defaults: {
					sortable: true
				},
				columns: [
					new Ext.grid.RowNumberer({width: 20}),
					{header: 'Location Descrip', dataIndex: 'display_name'},
				]
		   	});
			tableStore.load();
			if(this.searchWindow != null) {
				this.searchWindow.close();
			}
        	this.searchWindow = new Ext.Window({
				layout: 'fit',
				width: (this.getInnerWidth() - 10),
				height: 200,
				closeAction:'close',
				plain: false,
				resizable: false,
				renderTo: this.body.dom,
				x: 0,
				y: this.getInnerHeight() - 200,
				title: 'Map Locations Search Results',
				constrain: true,
				draggable: false,
				items: [{
					xtype: 'grid',
					frame: false,
					border: false,
					stripeRows: true,
					store: tableStore,
					width: '100%',
					height: '100%',
					colModel: tableColumns,
					viewConfig: {
						forceFit: true
					},
					sm: new Ext.grid.RowSelectionModel({
						singleSelect: true,
						listeners: {
							rowselect: function(s, index) {
								var row = s.getSelected();
								map.loadMask.show();
								map.setCenterLatLng(parseFloat(row.data.lat), parseFloat(row.data.lon), 12);
								map.loadMask.hide();
							}
						}
					}),
					listeners: {
						click: function(e) {
							e.preventDefault();
							e.stopPropagation();
						},
						dblclick: function(e) {
							e.preventDefault();
							e.stopPropagation();
						},
						mousedown: function(e) {
							e.preventDefault();
							e.stopPropagation();
						}
					}
				}]
			});
			this.loadMask.hide();
			Ext.each(response, function(item, index, allitems) {
				var place = response[index];
				var addressinfo = place.address;
				var point = this.makePoint(parseFloat(place.lat), parseFloat(place.lon));
				var marker = {
					size: {
						length: 17,
						width: 19
					},
					offset: {
						x: -17,
						y: -19
					},
					icon: this.imagePath + 'numbers/lightblue'+(index+1)+'.png'
				};
				this.addMarker(point, marker, false, false);
			}, this); 
			this.searchWindow.show();  
        }
    }
});

Ext.reg('openmappanel', Ext.ux.OpenMapPanel);
