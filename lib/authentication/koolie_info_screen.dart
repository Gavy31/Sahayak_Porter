import 'package:sahayak_kooli/splashScreen/splash_screen.dart';
import 'package:sahayak_kooli/global/global.dart';
import 'package:sahayak_kooli/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class KoolieInfoScreen extends StatefulWidget
{

  @override
  _KoolieInfoScreenState createState() => _KoolieInfoScreenState();
}



class _KoolieInfoScreenState extends State<KoolieInfoScreen>
{
  TextEditingController licenseTextEditingController = TextEditingController();
  TextEditingController stationTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();



  saveInfo()
  {
    Map porterInfoMap =
    {
      "license": licenseTextEditingController.text.trim(),
      "station": stationTextEditingController.text.trim(),
      "age": ageTextEditingController.text.trim(),
    };

    DatabaseReference portersRef = FirebaseDatabase.instance.ref().child("porters");
    portersRef.child(currentFirebaseUser!.uid).child("porter_details").set(porterInfoMap);

    Fluttertoast.showToast(msg: "License has been saved, Congratulations.");
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/sahayak.png"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Registration Details",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: licenseTextEditingController,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "License Number",
                  hintText: "License Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: stationTextEditingController,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Registered Railway Station",
                  hintText: "Your Station",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: ageTextEditingController,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Age",
                  hintText: "Age",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              // DropdownButton(
              //   iconSize: 26,
              //   dropdownColor: Colors.black,
              //   hint: const Text(
              //     "Please choose Car Type",
              //     style: TextStyle(
              //       fontSize: 14.0,
              //       color: Colors.grey,
              //     ),
              //   ),
              //   value: selectedCarType,
              //   onChanged: (newValue)
              //   {
              //     setState(() {
              //       selectedCarType = newValue.toString();
              //     });
              //   },
              //   items: carTypesList.map((car){
              //     return DropdownMenuItem(
              //       child: Text(
              //         car,
              //         style: const TextStyle(color: Colors.grey),
              //       ),
              //       value: car,
              //     );
              //   }).toList(),
              // ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                  if(licenseTextEditingController.text.isNotEmpty
                      && stationTextEditingController.text.isNotEmpty
                      && ageTextEditingController.text.isNotEmpty )
                  {
                    saveInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlueAccent,
                ),
                child: const Text(
                  "Save Now",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
