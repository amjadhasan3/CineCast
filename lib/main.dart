import 'package:cinecast_fyp/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:path_provider/path_provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Movie Revenue Predictor',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Movie Revenue Predictor'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _releasedController = TextEditingController();
//   final TextEditingController _writerController = TextEditingController();
//   final TextEditingController _ratingController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _genreController = TextEditingController();
//   final TextEditingController _directorController = TextEditingController();
//   final TextEditingController _starController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   final TextEditingController _companyController = TextEditingController();
//   final TextEditingController _runtimeController = TextEditingController();
//   final TextEditingController _scoreController = TextEditingController();
//   final TextEditingController _budgetController = TextEditingController();
//   final TextEditingController _yearController = TextEditingController();
//   final TextEditingController _votesController = TextEditingController();
//   String _predictionResult = '';
//   Map<String, dynamic> _explanations = {};
//   Map<String, dynamic> _movieData = {}; // Store the movie data

//   Future<void> _fetchPrediction() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       final Map<String, dynamic> movieData = {
//         "released": _releasedController.text,
//         "writer": _writerController.text,
//         "rating": _ratingController.text,
//         "name": _nameController.text,
//         "genre": _genreController.text,
//         "director": _directorController.text,
//         "star": _starController.text,
//         "country": _countryController.text,
//         "company": _companyController.text,
//         "runtime": int.parse(_runtimeController.text),
//         "score": int.parse(_scoreController.text),
//         "budget": int.parse(_budgetController.text),
//         "year": int.parse(_yearController.text),
//         "votes": int.parse(_votesController.text),
//       };
//       _movieData = movieData; // Store the movie data
//       try {
//         final response = await http.post(
//           Uri.parse('http://127.0.0.1:3000/predict'),
//           headers: {"Content-Type": "application/json"},
//           body: json.encode(movieData),
//         );

//         if (response.statusCode == 200) {
//           final decodedResponse = json.decode(response.body);
//           setState(() {
//             _predictionResult = decodedResponse['prediction'].toString();
//           });
//           _fetchExplanations(movieData);
//         } else {
//           setState(() {
//             _predictionResult = 'Failed to fetch prediction';
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _predictionResult = 'Error: ${e.toString()}';
//         });
//       }
//     }
//   }

//   Future<void> _fetchExplanations(Map<String, dynamic> movieData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:3000/explain'),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(movieData),
//       );
//       if (response.statusCode == 200) {
//         final decodedResponse = json.decode(response.body);
//         setState(() {
//           _explanations = decodedResponse['explanation'];
//         });
//       } else {
//         setState(() {
//           _explanations = {'error': 'Failed to fetch explanation'};
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _explanations = {'error': 'Error: ${e.toString()}'};
//       });
//     }
//   }

//   Future<void> _downloadAsPdf() async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Movie Revenue Prediction Report',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 20)),
//               pw.SizedBox(height: 20),
//               pw.Text('User Input:',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 16)),
//               for (var key in _movieData.keys)
//                 pw.Text('$key: ${_movieData[key]}'),
//               pw.SizedBox(height: 20),
//               pw.Text('Prediction:',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 16)),
//               pw.Text('Predicted Revenue: \$${_predictionResult}',
//                   style: const pw.TextStyle(fontSize: 14)),
//               pw.SizedBox(height: 20),
//               pw.Text('SHAP Explanations:',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, fontSize: 16)),
//               if (_explanations.isNotEmpty)
//                 for (var modelName in _explanations.keys)
//                   if (modelName != "error")
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('  $modelName Model:',
//                             style:
//                                 pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                         for (var feature in _explanations[modelName].keys)
//                           pw.Text(
//                               '      $feature: ${_explanations[modelName][feature].toStringAsFixed(4)}'),
//                       ],
//                     ),
//               if (_explanations.containsKey("error"))
//                 pw.Text("Error: ${_explanations["error"]}"),
//             ],
//           );
//         },
//       ),
//     );

//     // Save the pdf
//     Directory? appDocDir =
//         await getExternalStorageDirectory(); // Change to getApplicationDocumentsDirectory() for internal storage

//     if (appDocDir == null) {
//       appDocDir = await getApplicationDocumentsDirectory();
//     }
//     String appDocPath = appDocDir.path;
//     final file = File('$appDocPath/movie_prediction_report.pdf');
//     await file.writeAsBytes(await pdf.save());

//     // Show a success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('PDF report saved to ${file.path}'),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextFormField(
//                   controller: _releasedController,
//                   decoration: const InputDecoration(labelText: 'Release Month'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter release month';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _writerController,
//                   decoration: const InputDecoration(labelText: 'Writer'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter writer';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _ratingController,
//                   decoration: const InputDecoration(labelText: 'Rating'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter rating';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: 'Movie Name'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter movie name';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _genreController,
//                   decoration: const InputDecoration(labelText: 'Genre'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter genre';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _directorController,
//                   decoration: const InputDecoration(labelText: 'Director'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter director';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _starController,
//                   decoration: const InputDecoration(labelText: 'Star'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter star';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _countryController,
//                   decoration: const InputDecoration(labelText: 'Country'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter country';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _companyController,
//                   decoration: const InputDecoration(labelText: 'Company'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter company';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _runtimeController,
//                   decoration: const InputDecoration(labelText: 'Runtime'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter runtime';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _scoreController,
//                   decoration: const InputDecoration(labelText: 'Score'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter score';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _budgetController,
//                   decoration: const InputDecoration(labelText: 'Budget'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter budget';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _yearController,
//                   decoration: const InputDecoration(labelText: 'Year'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter year';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _votesController,
//                   decoration: const InputDecoration(labelText: 'Votes'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter votes';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 ElevatedButton(
//                   onPressed: _fetchPrediction,
//                   child: const Text('Predict Revenue'),
//                 ),
//                 const SizedBox(height: 20),
//                 Text('Predicted Revenue: \$${_predictionResult}',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),
//                 const Text('SHAP Explanations:',
//                     style:
//                         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 if (_explanations.isNotEmpty)
//                   for (var modelName in _explanations.keys)
//                     if (modelName != "error")
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('  $modelName Model:',
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold)),
//                           for (var feature in _explanations[modelName].keys)
//                             Text(
//                                 '      $feature: ${_explanations[modelName][feature].toStringAsFixed(4)}'),
//                         ],
//                       ),
//                 if (_explanations.containsKey("error"))
//                   Text("Error: ${_explanations["error"]}",
//                       style: TextStyle(color: Colors.red)),
//                 ElevatedButton(
//                   onPressed: _downloadAsPdf,
//                   child: const Text('Download as PDF'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
