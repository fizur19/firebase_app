// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   final storage = FirebaseStorage.instance;
//   final storageRef = FirebaseStorage.instance.ref();
//   List<Movie> listOfMovie = [];
//   @override
//   void initState() {
//     super.initState();
//     // _getmovielist();
//   }

//   _getmovielist() {
//     _firebaseFirestore.collection('movie').get().then(
//       (value) {
//         listOfMovie.clear();
//         for (QueryDocumentSnapshot doc in value.docs) {
//           listOfMovie
//               .add(Movie.fromjson(doc.id, doc.data() as Map<String, dynamic>));
//           print(doc.data());
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('movie')),
//       body: StreamBuilder(
//           stream: _firebaseFirestore.collection('movie').snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             listOfMovie.clear();
//             for (QueryDocumentSnapshot doc in snapshot.data?.docs ?? []) {
//               listOfMovie.add(
//                   Movie.fromjson(doc.id, doc.data() as Map<String, dynamic>));
//               print(doc.data());
//             }
//             return ListView.builder(
//               itemCount: listOfMovie.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => UpdateScreen(
//                             name: listOfMovie[index].name,
//                             year: listOfMovie[index].year,
//                             id: listOfMovie[index].id,
//                           ),
//                         ));
//                   },
//                   title: Text(listOfMovie[index].name),
//                   subtitle: Text(listOfMovie[index].year),
//                   trailing: IconButton(
//                     onPressed: () {
//                       _firebaseFirestore
//                           .collection('movie')
//                           .doc(listOfMovie[index].id)
//                           .delete();
//                     },
//                     icon: Icon(Icons.delete),
//                   ),
//                 );
//               },
//             );
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddScreen(),
//               ));
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// class Movie {
//   final String id, name, year, img;
//   Movie(
//       {required this.id,
//       required this.name,
//       required this.year,
//       required this.img});
//   factory Movie.fromjson(String id, Map<String, dynamic> json) {
//     return Movie(
//         id: id,
//         name: json['name'],
//         year: json['year'],
//         img: json['image'].toString());
//   }
// }

// class AddScreen extends StatefulWidget {
//   const AddScreen({super.key});

//   @override
//   State<AddScreen> createState() => _AddScreenState();
// }

// class _AddScreenState extends State<AddScreen> {
//   FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
//   FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   var name = TextEditingController();
//   var year = TextEditingController();
//   final _imagePick = ImagePicker();
//   XFile? selectedimage;
//   File? image;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           TextField(
//             controller: name,
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           TextField(
//             controller: year,
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           InkWell(
//             onTap: () async {
//               selectedimage =
//                   await _imagePick.pickImage(source: ImageSource.gallery);

//               if (selectedimage != null) {
//                 File convertedfile = File(selectedimage!.path);
//                 setState(() {
//                   image = convertedfile;
//                 });
//               } else {}
//             },
//             child: CircleAvatar(
//               backgroundImage: (image != null) ? FileImage(image!) : null,
//             ),
//           ),
//           ElevatedButton(
//               onPressed: () async {
//                 UploadTask uploadTask =
//                     _firebaseStorage.ref().child('image').putFile(image!);
//                 final snapshot = await uploadTask;
//                 final url = await snapshot.ref.getDownloadURL();

//                 Map<String, dynamic> newMovie = {
//                   'name': name.text,
//                   'year': year.text,
//                   'image': url
//                 };
//                 _firebaseFirestore.collection('movie').add(newMovie);

//                 Navigator.pop(context);
//               },
//               child: Text('add'))
//         ],
//       ),
//     );
//   }
// }

// class UpdateScreen extends StatefulWidget {
//   UpdateScreen(
//       {super.key, required this.name, required this.year, required this.id});
//   String name;
//   String year;
//   String id;

//   @override
//   State<UpdateScreen> createState() => _UpdateScreenState();
// }

// class _UpdateScreenState extends State<UpdateScreen> {
//   FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   var name = TextEditingController();
//   var year = TextEditingController();

//   @override
//   void initState() {
//     // TODO: implement initState
//     name.text = widget.name;
//     year.text = widget.year;

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextField(
//           controller: name,
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         TextField(
//           controller: year,
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         ElevatedButton(
//             onPressed: () {
//               Map<String, dynamic> newMovie = {
//                 'name': name.text,
//                 'year': year.text
//               };
//               _firebaseFirestore
//                   .collection('movie')
//                   .doc(widget.id)
//                   .update(newMovie);
//               Navigator.pop(context);
//             },
//             child: Text('add'))
//       ],
//     ));
//   }
// }
