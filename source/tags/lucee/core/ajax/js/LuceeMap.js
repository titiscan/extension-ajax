Lucee.Map = (function () {
    var a = new Lucee.adapters.Map();
    Lucee.Message.map = { missingRelatedArgument: "Attributes {0} or {1} are required." };
    function b() {
        return a;
    }
    return {
        init: function (e, d) {
            var c = b();
            if (d.centeraddress.length == 0 && (d.centerlatitude.length == 0 || d.centerlongitude.length == 0)) {
                Lucee.globalErrorHandler("map.missingRelatedArgument", ["centeraddress", "centerlatitude,centerlongitude"]);
            }
            d.address = d.centeraddress;
            d.latitude = d.centerlatitude;
            d.longitude = d.centerlongitude;
            c.init(e, d);
        },
        getMapObject: function (d) {
            var c = b();
            return c.getMapObject(d);
        },
        addMarker: function (f, c) {
            var d = b();
            var e = c;
            if (e.address.length == 0 && (e.latitude.length == 0 || e.longitude.length == 0)) {
                Lucee.globalErrorHandler("map.missingRelatedArgument", ["centeraddress", "centerlatitude,centerlongitude"]);
            }
            d.addMarker(f, e);
        },
        addEvent: function (d, e, f) {
            var c = b();
            c.addEvent(d, e, f);
        },
    };
})();