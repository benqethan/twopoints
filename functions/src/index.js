"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var functions = require("firebase-functions");
var admin = require("firebase-admin");
var GeoPoint = FirebaseFirestore.GeoPoint;
// import g from 'ngeohash';
var geoutils_1 = require("./geoutils");
admin.initializeApp();
exports.getRequests = functions.https.onRequest(function (req, res) {
    var uid = String(req.query.uid);
    console.log('getRequests start.................');
    function compileFeedPost() {
        return __awaiter(this, void 0, void 0, function () {
            var following, listOfPosts;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, log('I am a log entry111111111111!')];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, getFollowing(uid, res)];
                    case 2:
                        following = _a.sent();
                        return [4 /*yield*/, getAllPosts(following, res)];
                    case 3:
                        listOfPosts = _a.sent();
                        listOfPosts = [].concat.apply([], listOfPosts); // flattens list
                        res.send(listOfPosts);
                        return [2 /*return*/];
                }
            });
        });
    }
    compileFeedPost().then()["catch"]();
    // doMatch();
});
function log(message) {
    return __awaiter(this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, admin.firestore().collection('logs').add(message)];
                case 1:
                    _a.sent();
                    return [2 /*return*/];
            }
        });
    });
}
// for testing only
function doMatch() {
    var box = {
        "swCorner": {
            "latitude": -100,
            "longitude": -100
        },
        "neCorner": {
            "latitude": 100,
            "longitude": 100
        }
    };
    var locations = getLocations(box);
    // log('I am a log entry!');
}
function getAllPosts(following, res) {
    return __awaiter(this, void 0, void 0, function () {
        var listOfPosts, _a, _b, _i, user, _c, _d;
        return __generator(this, function (_e) {
            switch (_e.label) {
                case 0:
                    listOfPosts = [];
                    _a = [];
                    for (_b in following)
                        _a.push(_b);
                    _i = 0;
                    _e.label = 1;
                case 1:
                    if (!(_i < _a.length)) return [3 /*break*/, 4];
                    user = _a[_i];
                    _d = (_c = listOfPosts).push;
                    return [4 /*yield*/, getUserPosts(following[user], res)];
                case 2:
                    _d.apply(_c, [_e.sent()]);
                    _e.label = 3;
                case 3:
                    _i++;
                    return [3 /*break*/, 1];
                case 4: return [2 /*return*/, listOfPosts];
            }
        });
    });
}
function getUserPosts(userId, res) {
    var posts = admin.firestore().collection("twopoints_requests").where("ownerId", "==", userId).orderBy("timestamp");
    return posts.get()
        .then(function (querySnapshot) {
        var listOfPosts = [];
        querySnapshot.forEach(function (doc) {
            listOfPosts.push(doc.data());
        });
        return listOfPosts;
    });
}
function getFollowing(uid, res) {
    var doc = admin.firestore().doc("users/" + uid);
    return doc.get().then(function (snapshot) {
        var followings = snapshot.data().following;
        var following_list = [];
        for (var following in followings) {
            if (followings[following] === true) {
                following_list.push(following);
            }
        }
        return following_list;
    })["catch"](function (error) {
        res.status(500).send(error);
    });
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
    var lesserGeopoint = new GeoPoint(box.swCorner.latitude, box.swCorner.longitude);
    var greaterGeopoint = new GeoPoint(box.neCorner.latitude, box.neCorner.longitude);
    // construct the Firestore query
    var query = admin.firestore().collection("users").where('locations', '>', lesserGeopoint).where('locations', '<', greaterGeopoint);
    // return a Promise that fulfills with the locations
    return query.get()
        .then(function (snapshot) {
        var allLocs = []; // used to hold all the loc data
        snapshot.forEach(function (loc) {
            // get the data
            var data = loc.data();
            // calculate a distance from the center
            data.distanceFromCenter = geoutils_1.GeoUtils.distance(area.center, data.location);
            // add to the array
            allLocs.push(data);
        });
        return allLocs;
    })["catch"](function (err) {
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
