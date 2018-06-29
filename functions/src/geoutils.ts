
export class GeoUtils {
/**
 * Calculates the distance, in kilometers, between two locations, via the
 * Haversine formula. Note that this is approximate due to the fact that
 * the Earth's radius varies between 6356.752 km and 6378.137 km.
 *
 * @param {Object} location1 The first location given as .latitude and .longitude
 * @param {Object} location2 The second location given as .latitude and .longitude
 * @return {number} The distance, in kilometers, between the inputted locations.
 */
 distance(location1: any, location2: any): number {
    const radius = 6371; // Earth's radius in kilometers
    const latDelta = this.degreesToRadians(location2.latitude - location1.latitude);
    const lonDelta = this.degreesToRadians(location2.longitude - location1.longitude);
  
    const a = (Math.sin(latDelta / 2) * Math.sin(latDelta / 2)) +
            (Math.cos(this.degreesToRadians(location1.latitude)) * Math.cos(this.degreesToRadians(location2.latitude)) *
            Math.sin(lonDelta / 2) * Math.sin(lonDelta / 2));
  
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  
    return radius * c;
  }

degreesToRadians(degrees) {
    return (degrees * Math.PI)/180;
}

}