import 'dart:async';
import 'package:sahayak_kooli/assistants/assistant_methods.dart';
import 'package:sahayak_kooli/global/global.dart';
import 'package:sahayak_kooli/main.dart';
import 'package:sahayak_kooli/push_notifications/push_notification_system.dart';
import 'package:sahayak_kooli/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/black_theme_google_map.dart';


class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}



class _HomeTabPageState extends State<HomeTabPage>
{
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;



  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locatePorterPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    porterCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(porterCurrentPosition!.latitude, porterCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(porterCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    AssistantMethods.readPorterRatings(context);
  }

  readCurrentPorterInformation() async
  {
    currentFirebaseUser = fAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("porters")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((DatabaseEvent snap)
    {
      if(snap.snapshot.value != null)
      {
        onlinePorterData.id = (snap.snapshot.value as Map)["id"];
        onlinePorterData.name = (snap.snapshot.value as Map)["name"];
        onlinePorterData.phone = (snap.snapshot.value as Map)["phone"];
        onlinePorterData.email = (snap.snapshot.value as Map)["email"];
        onlinePorterData.license = (snap.snapshot.value as Map)["license"];



        print("License Details :: ");
        print(onlinePorterData.license);
      }
    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();

    AssistantMethods.readPorterEarnings(context);
  }

  @override
  void initState()
  {
    super.initState();

    checkIfLocationPermissionAllowed();
    readCurrentPorterInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //black theme google map
            blackThemeGoogleMap(newGoogleMapController);

            locatePorterPosition();
          },
        ),

        //ui for online offline porter
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),

        //button for online offline porter
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ()
                {
                  if(isPorterActive != true) //offline
                  {
                    porterIsOnlineNow();
                    updatePortersLocationAtRealTime();

                    setState(() {
                      statusText = "Now Online";
                      isPorterActive = true;
                      buttonColor = Colors.transparent;
                    });

                    //display Toast
                    Fluttertoast.showToast(msg: "you are Online Now");
                  }
                  else //online
                  {
                    porterIsOfflineNow();

                    setState(() {
                      statusText = "Go Online";
                      isPorterActive = false;
                      buttonColor = Colors.blue;
                    });

                    //display Toast
                    Fluttertoast.showToast(msg: "you are Offline Now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                            color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  porterIsOnlineNow() async
  {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    porterCurrentPosition = pos;

    Geofire.initialize("activePorters");

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        porterCurrentPosition!.latitude,
        porterCurrentPosition!.longitude
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("porters")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.set("idle"); //searching for ride request
    ref.onValue.listen((event) { });
  }

  updatePortersLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
          porterCurrentPosition = position;

          if(isPorterActive == true)
          {
            Geofire.setLocation(
                currentFirebaseUser!.uid,
                porterCurrentPosition!.latitude,
                porterCurrentPosition!.longitude
            );
          }

          LatLng latLng = LatLng(
              porterCurrentPosition!.latitude,
              porterCurrentPosition!.longitude,
          );

          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  porterIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("porters")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), ()
    {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}
