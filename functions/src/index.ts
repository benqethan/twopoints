import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import GeoPoint = FirebaseFirestore.GeoPoint;
// import g from 'ngeohash';
import { GeoUtils } from "./geoutils";

admin.initializeApp();
const utils = new GeoUtils();

// As an admin, the app has access to read and write all data, regardless of Security Rules
let db = admin.database();
let ref = db.ref("twopoints_requests");

export const getRequests = functions.https.onRequest((req, res) => {
  const uid = String(req.query.uid);
  console.log('getRequests start.................');

  async function compileFeedPost() {
    console.log('xx I am a log entry111111111111!');

    let listOfPosts = await getAllPosts(0, res);

    listOfPosts = [].concat.apply([], listOfPosts); // flattens list
    // console.log('Count of posts:' + listOfPosts.length);
    // console.log(listOfPosts[0]);
    res.send(listOfPosts);

    // const matches = await doMatch();
    // res.send(matches);
  }
  
  compileFeedPost().then().catch();
})

// async function log(message) {
//   await admin.firestore().collection('logs').add({message: message});
// }

// for testing only
async function doMatch() {
  let box = {
    "swCorner" : 
    {
      "latitude": -100, 
      "longitude": -100
    },
    "neCorner" : 
    {
      "latitude": 100, 
      "longitude": 100
    }
  };

  let locations = getLocations(box);
  // console.log('I am a log entry 222222!');

  return locations;
}

async function getAllPosts(following, res) {
  const userId = 999;

  var posts = await getCustomerRequests(0, 0);
  console.log("getCustomerRequests done, posts:" + posts);

  return posts;
}


async function getCustomerRequests(userId, res){
  // const queryRef = ref.orderByChild("requestTimestamp").limitToLast(10);
  let listOfRequests = [];

  console.log("getCustomerRequests...");

  // TODO: If use .on(), need to remove the listner if the user shift the activity to save the power and prevent memory leak
 return ref.once('value').then((snapshot) => {
    snapshot.forEach((reqSnapshot) => {
      listOfRequests.push(reqSnapshot.val());
    });

    // console.log("getCustomerRequests done, size is " + listOfRequests.length);

    return listOfRequests;
  }).catch((error) => {
    console.log('Error getting messages', error.message);
  });

  return listOfRequests;
}


function getFollowing(uid, res){
  const doc = admin.firestore().doc(`users/${uid}`)
  return doc.get().then(snapshot => {
    const followings = snapshot.data().following;
    
    let following_list = [];

    for (const following in followings) {
      if (followings[following] === true){
        following_list.push(following);
      }
    }
    return following_list; 
}).catch(error => {
    res.status(500).send(error)
})
}


// Given address, convert it to Geo location
// function toGeoLocation(address) {

// }

// https://github.com/firebase/geofire-js/issues/163

/** 
const store = admin.firestore();

const addLocation = (lat, lng) =>  
  store
    .collection('locations')
    .add({
      g10: g.encode_int(lat, lng, 24), // ~10 km radius
      g5: g.encode_int(lat, lng, 26), // ~5 km radius
      g1: g.encode_int(lat, lng, 30) // ~1 km radius
    });

const nearbyLocationsRef = (lat, lng, d = 1) => {
  const bits =  d === 10 ? 24 : d === 5 ? 26 : 30;

  const h = g.encode_int(lat, lng, bits);

  return store
    .collection('locations')
    .where(`g${d}`, '>=', g.neighbor_int(h, [-1, -1], bits))
    .where(`g${d}`, '<=', g.neighbor_int(h, [1, 1], bits));
};

// match by distance, return mulitple if possible.
// https://github.com/firebase/geofire-js/blob/87a2efe872581f1647aaf22e660e06dddd912919/docs/reference.md#geofiredistancelocation1-location2
function getMatch() {

  // Create a new GeoFire instance at the random Firebase location
  var geoFire = new GeoFire(firebaseRef);
  var geoQuery;

  $("#addfish").on("submit", function() {
    var lat = parseFloat($("#addlat").val());
    var lon = parseFloat($("#addlon").val());
    var myID = "fish-" + firebaseRef.push().key;

    geoFire.set(myID, [lat, lon]).then(function() {
      log(myID + ": setting position to [" + lat + "," + lon + "]");
    });

    return false;
  });

}
*/

// send email or notifcation
// function postRequest() {

// }

// get (userId, location1, location2) given the provided (locationSrc, locationDest) 
function getLocations(box) {
  // calculate the SW and NE corners of the bounding box to query for
  // const box = utils.boundingBoxCoordinates(area.center, area.radius);

  // construct the GeoPoints
  const lesserGeopoint = new admin.firestore.GeoPoint(box.swCorner.latitude, box.swCorner.longitude);
  const greaterGeopoint = new admin.firestore.GeoPoint(box.neCorner.latitude, box.neCorner.longitude);

  // construct the Firestore query
  let query = admin.firestore().collection("users").where('locations', '>', lesserGeopoint).where('locations', '<', greaterGeopoint);

  // return a Promise that fulfills with the locations
  return query.get()
    .then((snapshot) => {
      const allLocs = []; // used to hold all the loc data
      snapshot.forEach((loc) => {
        // get the data
        const data = loc.data();
        // calculate a distance from the center. 
        // @TODO: error TS2339: Property 'distance' does not exist on type 'typeof GeoUtils'.
        data.distanceFromCenter = utils.distance({latitude: 50, longitude: 50}, data.location);

        // add to the array
        allLocs.push(data);
      });
      return allLocs;
    })
    .catch((err) => {
      return new Error('Error while retrieving events');
    });
}

// NB: - For Firebase Realtime Database, GeoFire is not maitainted and cannot combine the geo query with the text query
// https://github.com/firebase/geofire-js/issues/158
//     - For Firestore, no official support for Geo yet.
// https://developers.google.com/android/reference/com/google/firebase/firestore/GeoPoint
// ** Drop-in replacement for GeoFire:  https://github.com/MichaelSolati/geofirestore
// *** But a bounded box way can be applied:
// https://stackoverflow.com/questions/46630507/how-to-run-a-geo-nearby-query-with-firestore

//     - A generic way(maybe not scalable way) is GeoHash
// * https://github.com/sunng87/node-geohash
// https://github.com/davetroy/geohash-js  -- Old way with only js