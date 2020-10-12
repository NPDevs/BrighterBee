import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

upvote(String community, String key, String username, bool upvoted,
    bool downvoted) async {
  if (upvoted) {
    await undoUpvote(community, key, username, upvoted, downvoted);
    return;
  }
  if (downvoted) {
    await undoDownvote(community, key, username, upvoted, downvoted);
    // return;
  }
  FirebaseFirestore instance = FirebaseFirestore.instance;
  await instance.runTransaction((transaction) async {
    DocumentReference postRef =
        instance.collection('communities/$community/posts').doc(key);
    await transaction.update(postRef, {
      'upvoters': FieldValue.arrayUnion([username])
    });

    await instance.collection('users/$username/posts').doc('upvoted').update({
      community: FieldValue.arrayUnion([key])
    });
  });

  debugPrint('Upvoted!');
}

downvote(String community, String key, String username, bool upvoted,
    bool downvoted) async {
  if (downvoted) {
    undoDownvote(community, key, username, upvoted, downvoted);
    return;
  }
  if (upvoted) {
    await undoUpvote(community, key, username, upvoted, downvoted);
    // return;
  }
  FirebaseFirestore instance = FirebaseFirestore.instance;
  await instance.runTransaction((transaction) async {
    DocumentReference postRef =
        instance.collection('communities/$community/posts').doc(key);
    await transaction.update(postRef, {
      'downvoters': FieldValue.arrayUnion([username])
    });

    await instance.collection('users/$username/posts').doc('downvoted').update({
      community: FieldValue.arrayUnion([key])
    });
  });

  debugPrint('Downvoted!');
}

undoUpvote(String community, String key, String username, bool upvoted,
    bool downvoted) async {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  await instance.runTransaction((transaction) async {
    DocumentReference postRef =
        instance.collection('communities/$community/posts').doc(key);
    await transaction.update(postRef, {
      'upvoters': FieldValue.arrayRemove([username])
    });

    await instance.collection('users/$username/posts').doc('upvoted').update({
      community: FieldValue.arrayRemove([key])
    });
  });

  debugPrint('Upvote undone!');
}

undoDownvote(String community, String key, String username, bool upvoted,
    bool downvoted) async {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  await instance.runTransaction((transaction) async {
    DocumentReference postRef =
        instance.collection('communities/$community/posts').doc(key);
    await transaction.update(postRef, {
      'downvoters': FieldValue.arrayRemove([username])
    });

    await instance.collection('users/$username/posts').doc('downvoted').update({
      community: FieldValue.arrayRemove([key])
    });
  });

  debugPrint('Downvote undone!');
}
