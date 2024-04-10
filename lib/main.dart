import 'dart:io';

import 'package:firebase_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Image Demo',
      home: ImageScreen(),
    );
  }
}

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final picker = ImagePicker();
  late CollectionReference imagesRef;

  @override
  void initState() {
    super.initState();
    imagesRef = FirebaseFirestore.instance.collection('images');
  }

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      await imagesRef.add({'url': downloadURL});
    }
  }

  Future<void> _deleteImage(String documentId, String imageUrl) async {
    // Show a confirmation dialog before deleting the image
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this image?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if delete is canceled
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true if delete is confirmed
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    // If delete is confirmed, delete the image from Firebase Storage and Firestore
    if (deleteConfirmed == true) {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await imagesRef.doc(documentId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Image Demo'),
      ),
      body: StreamBuilder(
        stream: imagesRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return ImageWidget(
                imageUrl: doc['url'],
                documentId: doc.id,
                onDelete: () => _deleteImage(doc.id, doc['url']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImage,
        tooltip: 'Upload Image',
        child: Icon(Icons.add),
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final String documentId;
  final Function onDelete;

  ImageWidget(
      {required this.imageUrl,
      required this.documentId,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            imageUrl,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
