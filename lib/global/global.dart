import 'dart:async';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:sahayak_kooli/models/porter_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionPorterLivePosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? porterCurrentPosition;
PorterData onlinePorterData = PorterData();
String? porterVehicleType = "";
String titleStarsRating = "Good";
bool isPorterActive = false;
String statusText = "Go Online";
Color buttonColor = Colors.blue;