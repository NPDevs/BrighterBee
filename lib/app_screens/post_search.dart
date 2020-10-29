import 'dart:io';

import 'package:brighter_bee/app_screens/post_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PostSearch extends StatefulWidget {
  @override
  _PostSearchState createState() => _PostSearchState();
}

class _PostSearchState extends State<PostSearch> {
  TextEditingController searchController = TextEditingController();
  String username;
  List memberOf;
  PostListBloc postListBloc;
  ScrollController controller = ScrollController();
  int previousSnapshotLength;

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    searchController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (controller.position.extentAfter < 400) {
      debugPrint('At bottom!');
      postListBloc.fetchNextPosts();
    }
  }

  void initState() {
    super.initState();
    previousSnapshotLength = 0;
    username = FirebaseAuth.instance.currentUser.displayName;
    searchController.addListener(() {
      print(searchController.text);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(username)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else {
                memberOf = snapshot.data.data()['communityList'];
                postListBloc =
                    PostListBloc(searchController.text.toLowerCase(), memberOf);
                postListBloc.fetchFirstList();
                controller.addListener(scrollListener);
                return StreamBuilder<List<DocumentSnapshot>>(
                    stream: postListBloc.postStream,
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        int presentLength = snapshot.data.length;
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot documentSnapshot =
                                  snapshot.data[index];
                              String id = documentSnapshot.id;
                              debugPrint('${snapshot.data.length}');
                              return Column(children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostUI(
                                                documentSnapshot
                                                    .data()['community'],
                                                id)));
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0, top: 8.0),
                                        child: SizedBox(
                                          height: 40,
                                          child: Text(
                                            documentSnapshot.data()['title'],
                                            style: TextStyle(fontSize: 18),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 4.0, bottom: 4.0),
                                        child: Container(
                                          height: 1.0,
                                          width: double.infinity,
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      (index != snapshot.data.length - 1)
                                          ? Container()
                                          : buildProgressIndicator(
                                              presentLength)
                                    ],
                                  ),
                                ),
                              ]);
                            });
                      } else {
                        return Container();
                      }
                    });
              }
            }));
  }

  buildProgressIndicator(int presentLength) {
    if (presentLength != previousSnapshotLength) {
      previousSnapshotLength = presentLength;
      return CircularProgressIndicator();
    } else {
      return Container();
    }
  }
}

class PostListBloc {
  List memberOf;
  String searchText;

  bool showIndicator = false;
  List<DocumentSnapshot> documentList;
  BehaviorSubject<bool> showIndicatorController;
  BehaviorSubject<List<DocumentSnapshot>> postController;

  PostListBloc(this.searchText, this.memberOf) {
    showIndicatorController = BehaviorSubject<bool>();
    postController = BehaviorSubject<List<DocumentSnapshot>>();
  }

  Stream get getShowIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get postStream => postController.stream;

/*This method will automatically fetch first 10 elements from the document list */
  Future fetchFirstList() async {
    if (!showIndicator) {
      try {
        updateIndicator(true);
        documentList = (await getQuery().limit(15).get()).docs;
        postController.sink.add(documentList);
        updateIndicator(false);
      } on SocketException {
        updateIndicator(false);
        postController.sink.addError(SocketException("No Internet Connection"));
      } catch (e) {
        updateIndicator(false);
        print(e.toString());
        postController.sink.addError(e);
      }
    }
  }

/*This will automatically fetch the next 10 elements from the list*/
  fetchNextPosts() async {
    if (!showIndicator) {
      try {
        updateIndicator(true);
        List<DocumentSnapshot> newDocumentList = (await getQuery()
                .startAfterDocument(documentList[documentList.length - 1])
                .limit(17)
                .get())
            .docs;
        documentList.addAll(newDocumentList);
        postController.sink.add(documentList);
        updateIndicator(false);
      } on SocketException {
        postController.sink.addError(SocketException("No Internet Connection"));
      } catch (e) {
        print(e.toString());
        postController.sink.addError(e);
      }
    }
  }

  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    postController.close();
    showIndicatorController.close();
  }

  Query getQuery() {
    if (searchText != null && searchText != "")
      return FirebaseFirestore.instance
          .collectionGroup('posts')
          .where('isVerified', isEqualTo: true)
          .where('community', whereIn: memberOf)
          .where('titleSearch', arrayContains: searchText)
          .orderBy('time', descending: true);
    else
      return FirebaseFirestore.instance
          .collectionGroup('posts')
          .where('isVerified', isEqualTo: true)
          .where('community', whereIn: memberOf)
          .orderBy('time', descending: true);
  }
}
