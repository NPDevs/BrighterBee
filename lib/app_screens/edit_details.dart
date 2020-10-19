import 'dart:io';

import 'package:brighter_bee/widgets/edit_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// @author: Ashutosh Chitranshi
// 18-10-2020 17:05
// This will be used for editing details of the user

class EditDetails extends StatefulWidget {
  @override
  _EditDetailsState createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  String username;
  String motto;
  String homeTown;
  String currentCity;
  String website;
  FirebaseAuth _auth = FirebaseAuth.instance;
  File _imageFile;
  String url;
  void initState() {
    super.initState();
    username = _auth.currentUser.displayName;
  }
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = _auth.currentUser.displayName + DateTime.now().toIso8601String() + '.jpg';
    StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('profilePics/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    url = await taskSnapshot.ref.getDownloadURL();
    print(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit profile',),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(username).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
           if(motto == null)
              motto = snapshot.data['motto'];
           if(homeTown == null)
            homeTown = snapshot.data['homeTown'];
           if(currentCity == null)
            currentCity = snapshot.data['currentCity'];
           if(website == null)
            website = snapshot.data['website'];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Text('Profile Picture',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                InkWell(
                  onTap: (){
                    print('ashu12');
                    pickImage();

                  },
                  child: Container(
                    margin: EdgeInsets.only(top:20,bottom: 20,left: 40,right: 40),
                    width: 200,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _imageFile==null?NetworkImage(snapshot.data['photoUrl']):AssetImage(_imageFile.path),
                          fit: BoxFit.fill
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Motto',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    IconButton(
                      icon: Icon(Icons.edit,color: Colors.grey,),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditText(motto))).then((value){
                          //print(value);
                          setState(() {
                            motto = value;
                            print(motto);
                          });
                        });
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5,left: 10.0, right: 10,bottom: 5),
                  child: Center(
                      child: Text(
                        motto,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.home),
                    IconButton(
                      icon: Icon(Icons.edit,color: Colors.grey,),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditText(homeTown))).then((value){
                          //print(value);
                          setState(() {
                            homeTown = value;
                            print(motto);
                          });
                        });
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5,left: 10.0, right: 10,bottom: 5),
                  child: Center(
                      child: Text(
                        'Lives in $homeTown, India',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.location_on),
                    IconButton(
                      icon: Icon(Icons.edit,color: Colors.grey,),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditText(currentCity))).then((value){
                          //print(value);
                          setState(() {
                            currentCity = value;
                            print(motto);
                          });
                        });
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5,left: 10.0, right: 10,bottom: 5),
                  child: Center(
                      child: Text(
                        'From $currentCity, India',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.link),
                    IconButton(
                      icon: Icon(Icons.edit,color: Colors.grey,),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditText(website))).then((value){
                          //print(value);
                          setState(() {
                            website = value;
                            print(motto);
                          });
                        });
                      },
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5,left: 10.0, right: 10,bottom: 5),
                  child: Center(
                      child: Text(
                        website,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: FlatButton(
                      child: Text("Save Details"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey)),
                    onPressed: () async {
                        if(_imageFile != null) {
                          await uploadImageToFirebase(context);
                          await FirebaseFirestore.instance.collection('users').doc(username).
                          update({
                            'motto':motto,
                            'homeTown':homeTown,
                            'currentCity':currentCity,
                            'website':website,
                            'photoUrl':url
                          });
                        }
                        else {
                          await FirebaseFirestore.instance.collection('users').doc(username).
                          update({
                            'motto':motto,
                            'homeTown':homeTown,
                            'currentCity':currentCity,
                            'website':website
                          });
                          Navigator.pop(context);
                        }
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
