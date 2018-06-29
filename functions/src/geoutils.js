"use strict";
exports.__esModule = true;
var GeoUtils = /** @class */ (function () {
    function GeoUtils() {
    }
    /**
     * Calculates the distance, in kilometers, between two locations, via the
     * Haversine formula. Note that this is approximate due to the fact that
     * the Earth's radius varies between 6356.752 km and 6378.137 km.
     *
     * @param {Object} location1 The first location given as .latitude and .longitude
     * @param {Object} location2 The second location given as .latitude and .longitude
     * @return {number} The distance, in kilometers, between the inputted locations.
     */
    GeoUtils.prototype.distance = function (location1, location2) {
        var radius = 6371; // Earth's radius in kilometers
        var latDelta = this.degreesToRadians(location2.latitude - location1.latitude);
        var lonDelta = this.degreesToRadians(location2.longitude - location1.longitude);
        var a = (Math.sin(latDelta / 2) * Math.sin(latDelta / 2)) +
            (Math.cos(this.degreesToRadians(location1.latitude)) * Math.cos(this.degreesToRadians(location2.latitude)) *
                Math.sin(lonDelta / 2) * Math.sin(lonDelta / 2));
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return radius * c;
    };
    GeoUtils.prototype.degreesToRadians = function (degrees) {
        return (degrees * Math.PI) / 180;
    };
    return GeoUtils;
}());
exports.GeoUtils = GeoUtils;
