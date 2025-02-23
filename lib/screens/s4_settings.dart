// ignore_for_file: use_build_context_synchronously

import 'package:cinecast_fyp/model/user_model.dart';
import 'package:cinecast_fyp/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; // Import intl package

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key}); // Add Key? key

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Add FirebaseFirestore instance

  @override
  void initState() {
    super.initState();
    loadUserData(); // Load user data in initState
  }

  Future<void> loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get();

        if (snapshot.exists) {
          loggedInUser =
              UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
          setState(() {});
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error loading user data: $e");
        // Handle the error appropriately (e.g., display an error message)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFF0A0E21),
        title: Center(
            child: Text('Settings',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0A0E21)))),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items to the start
          children: <Widget>[
            Center(
              child: Text(
                "Hi ${loggedInUser.firstName} ${loggedInUser.secondName}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 56, 23, 96),
                ),
                textAlign: TextAlign
                    .center, // Add this line to center the text horizontally within its available space
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "${loggedInUser.email}",
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500),
                textAlign: TextAlign
                    .center, // Add this line to center the text horizontally within its available space
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(103, 58, 183, 1),
                  padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                  textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Log Out', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 24),
            Text('Saved / History Predictions:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 56, 23, 96),
                )),
            SizedBox(height: 12),
            Expanded(
              child: user != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(user!.uid)
                          .collection('predictions')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          // Check for hasData
                          return Center(
                              child: Text('No predictions yet.',
                                  style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey.shade300),
                          itemBuilder: (context, index) {
                            var data = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                            String docId = snapshot
                                .data!.docs[index].id; // Get document ID
                            return PredictionListItem(
                                data: data,
                                docId: docId,
                                onDelete: () => _deletePrediction(docId));
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text('Please sign in to see your history.',
                          style: TextStyle(color: Colors.grey))),
            ),
          ],
        ),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _deletePrediction(String docId) async {
    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('predictions')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction deleted successfully.')),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting prediction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete prediction.')),
      );
    }
  }
}

class PredictionListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final VoidCallback onDelete;

  const PredictionListItem(
      {super.key,
      required this.data,
      required this.docId,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['movieData']['name'] ?? 'Unknown Movie',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              Text('\$${data['predictionResult'] ?? "XXXX"}',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PredictionDetailScreen(data: data),
                    ),
                  );
                },
                child: Text('VIEW', style: TextStyle(color: Color(0xFF4A148C))),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PredictionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  PredictionDetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['movieData']['name'] ?? 'Prediction Details',
            style: TextStyle(color: Color(0xFF0A0E21))),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF0A0E21)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Movie: ${data['movieData']['name']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Predicted Revenue: \$${data['predictionResult']}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text('Movie Data:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              for (var entry in (data['movieData'] as Map<String, dynamic>)
                  .entries) // Cast data['movieData'] to Map<String, dynamic>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              SizedBox(height: 16),
              Text('Explanations:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (data['explanations'] != null && data['explanations'] is Map)
                for (var modelName in (data['explanations'] as Map).keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('  $modelName:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      if ((data['explanations'] as Map)[modelName] != null &&
                          (data['explanations'] as Map)[modelName] is Map)
                        for (var feature in (((data['explanations']
                                as Map)[modelName]) as Map)
                            .keys)
                          Text(
                              '      $feature: ${((((data['explanations'] as Map)[modelName]) as Map)[feature]).toStringAsFixed(4)}'),
                      if ((data['explanations'] as Map)[modelName] == null)
                        Text('      No explanations available for this model.'),
                      if ((((data['explanations'] as Map)[modelName]) is! Map))
                        Text('Invalid explanation format.')
                    ],
                  ),
              SizedBox(height: 16),
              Text(
                  'Timestamp: ${DateFormat('yyyy-MM-dd – kk:mm').format((data['timestamp'] as Timestamp).toDate())}',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
