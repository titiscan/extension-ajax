Lucee.adapters.Map = function () {
    var _maps = {};
    var _SUPPORTED_MAP_TYPES = { map: "google.maps.MapTypeId.ROADMAP", satellite: "google.maps.MapTypeId.SATELLITE", hybrid: "google.maps.MapTypeId.HYBRID", terrain: "google.maps.MapTypeId.TERRAIN" };
    function _convertMapType(type) {
        if (typeof (_SUPPORTED_MAP_TYPES[type] == "undefined")) {
        }
        return eval(_SUPPORTED_MAP_TYPES[type]);
    }
    function _createMarker(point, options, map) {
        var markerOptions = { position: point, draggable: false, map: map };
        if (options.tip) {
            markerOptions.title = options.tip;
        }
        if (options.markercolor.length) {
            var icon = {};
            icon.url = "https://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%20|" + options.markercolor + "|000000";
            markerOptions.icon = icon;
        } else {
            if (options.markericon.length) {
                var icon = {};
                icon.url = options.markericon;
                markerOptions.icon = icon;
            }
        }
        var marker = new google.maps.Marker(markerOptions);
        if (options.markerwindowcontent.length) {
            var infowindow = new google.maps.InfoWindow({ content: options.markerwindowcontent });
            google.maps.event.addListener(marker, "click", function () {
                infowindow.open(map, marker);
            });
        }
        return marker;
    }
    function _addTypeControl(type, mapOptions) {
        if (type == "basic") {
            mapOptions.mapTypeControl = true;
        } else {
            if (type == "advanced") {
                mapOptions.mapTypeControl = true;
            }
        }
    }
    function _addZoomControl(mapOptions, type) {
        if (type == "none") {
            mapOptions.zoomControl = false;
        } else {
            mapOptions.zoomControl = true;
        }
    }
    return {
        getMapObject: function (name) {
            try {
                var m = _maps[name].object;
                if (!m) {
                    Lucee.globalErrorHandler("map.mapNotFound", [name]);
                }
            } catch (e) {
                alert(e);
            }
            return m;
        },
        init: function (name, options) {
            var mapOptions = {};
            options.zoomlevel = parseInt(options.zoomlevel) || 3;
            mapOptions.zoom = options.zoomlevel;
            mapOptions.mapTypeId = options.type = _convertMapType(options.type);
            if (options.typecontrol.length) {
                _addTypeControl(options.typecontrol, mapOptions);
            }
            if (options.zoomcontrol.length) {
                _addZoomControl(mapOptions, options.zoomcontrol);
            }
            if (options.showscale == "true") {
                mapOptions.scaleControl = true;
            }
            if (options.doubleclickzoom == "false") {
                mapOptions.disableDoubleClickZoom = true;
            }
            var map = new google.maps.Map(document.getElementById(name), mapOptions);
            if (options.onerror.length) {
                var f = eval(options.onerror);
                google.maps.event.addListener(map, "error", function () {
                    f();
                });
            }
            if (options.onload.length) {
                var f = eval(options.onload);
                google.maps.event.addListener(map, "load", function () {
                    f(map.getContainer().id, map);
                });
            }
            if (options.onnotfound.length) {
                options.onnotfound = eval(options.onnotfound);
            }
            map.setMapTypeId(options.type);
            _maps[name] = {};
            _maps[name].object = map;
            _maps[name].options = options;
            this.setCenter(name, options);
        },
        addMarker: function (name, options) {
            var map = _maps[name].object;
            if (options.tip) {
                options.title = options.tip;
            }
            if (options.address) {
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode({ address: options.address }, function (point, status) {
                    if (status == "ok") {
                        if (!point) {
                            var msg = "Location not found. Address: " + options.address;
                            if (typeof _maps[name].options.onnotfound == "function") {
                                _maps[name].options.onnotfound(msg, _maps[name].object.getContainer().id, _maps[name].object);
                            } else {
                                alert(msg);
                            }
                        } else {
                            _createMarker(point, options, map);
                        }
                    } else {
                        var msg = "status for the request from google maps = " + status + ", address = " + options.address;
                        console.log(msg);
                    }
                });
            } else {
                var point = new google.maps.LatLng(options.latitude, options.longitude);
                if (!point) {
                    var msg = "Location not found. Lat: " + options.latitude + " Long: " + options.longitude;
                    if (typeof _maps[name].options == "function") {
                        _maps[name].options.onnotfound(msg, _maps[name].object.getContainer().id, _maps[name].object);
                    } else {
                        alert(msg);
                    }
                } else {
                    _createMarker(point, options, map);
                }
            }
        },
        setCenter: function (name, options) {
            var map = _maps[name].object;
            if (options.address) {
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode({ address: options.address }, function (point, status) {
                    if (status == "ok") {
                        if (!point) {
                            var msg = "Location not found. Address: " + options.address;
                            if (typeof _maps[name].options.onnotfound == "function") {
                                _maps[name].options.onnotfound(msg, _maps[name].object.getContainer().id, _maps[name].object);
                            } else {
                                alert(msg);
                            }
                        } else {
                            map.setCenter(point[0], options.zoomlevel);
                            if (eval(options.showcentermarker) == true) {
                                _createMarker(point, options, map);
                            }
                        }
                    } else {
                        var msg = "status for the request from google maps = " + status + ", address = " + options.address;
                        console.log(msg);
                    }
                });
            } else {
                var point = new google.maps.LatLng(options.latitude, options.longitude);
                if (!point) {
                    var msg = "Location not found. Lat: " + options.latitude + " Long: " + options.longitude;
                    if (typeof _maps[name].options.onnotfound == "function") {
                        _maps[name].options.onnotfound(msg, _maps[name].object.getContainer().id, _maps[name].object);
                    } else {
                        alert(msg);
                    }
                } else {
                    map.setCenter(point, options.zoomlevel);
                    if (eval(options.showcentermarker) == true) {
                        _createMarker(point, options, map);
                    }
                }
            }
        },
        addEvent: function (map, event, listener) {
            m = this.getMapObject(map);
            google.maps.event.addListener(m, event, listener);
        }
    };
};