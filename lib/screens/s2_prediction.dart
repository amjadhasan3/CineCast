import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Import intl package

class Prediction extends StatefulWidget {
  const Prediction({super.key});

  @override
  State<Prediction> createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _releasedController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _starController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _runtimeController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _votesController = TextEditingController();
  String _predictionResult = '';
  Map<String, dynamic> _explanations = {};
  Map<String, dynamic> _movieData = {}; // Store the movie data
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TMDB API Key (Replace with your actual key)
  final String _tmdbApiKey =
      '845270b9ac9191ab88da8fa8596672f9'; // Replace with your actual API key

  // Director Search
  List<Map<String, dynamic>> _directorSuggestions = [];
  bool _isLoadingDirectors = false;

  // Writer Search
  List<Map<String, dynamic>> _writerSuggestions = [];
  bool _isLoadingWriters = false;

  // Star Search
  List<Map<String, dynamic>> _starSuggestions = [];
  bool _isLoadingStars = false;

  // Movie Rating Options
  final List<String> _ratingOptions = [
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17',
    'Unrated' // Or handle unrated differently, depending on your needs.
  ];

  // Genre Options (from TMDB)
  List<Map<String, dynamic>> _genreOptions = [];
  bool _isLoadingGenres = false;

  // Company Options (from TMDB Search)
  List<Map<String, dynamic>> _companySuggestions = [];
  bool _isLoadingCompanies = false;

  // Score Options
  final List<String> _scoreOptions = List.generate(
      11,
      (index) =>
          index.toString()); // Generates a list of strings from '0' to '10'

  // Refresh Indicator Key
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _handleRefresh() async {
    // Clear any existing data
    _directorSuggestions.clear();
    _writerSuggestions.clear();
    _starSuggestions.clear();
    _companySuggestions.clear();
    _releasedController.clear();
    _writerController.clear();
    _ratingController.clear();
    _nameController.clear();
    _genreController.clear();
    _directorController.clear();
    _starController.clear();
    _countryController.clear();
    _companyController.clear();
    _runtimeController.clear();
    _scoreController.clear();
    _budgetController.clear();
    _yearController.clear();
    _votesController.clear();
    setState(() {
      _predictionResult = '';
      _explanations = {};
      _movieData = {};
    });

    // Refetch initial data (like genres)
    await _fetchGenres(); // Assuming this is what you want to refresh

    // Add any other refresh-related logic here
  }

  Future<void> _fetchGenres() async {
    setState(() {
      _isLoadingGenres = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/genre/movie/list?api_key=$_tmdbApiKey'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        List<Map<String, dynamic>> results =
            (decodedResponse['genres'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _genreOptions = results;
          _isLoadingGenres = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to fetch genres: ${response.statusCode}');
        setState(() {
          _genreOptions = [];
          _isLoadingGenres = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching genres: $e');
      setState(() {
        _genreOptions = [];
        _isLoadingGenres = false;
      });
    }
  }

  Future<void> _searchCompanies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _companySuggestions = [];
        _isLoadingCompanies = false;
      });
      return;
    }

    setState(() {
      _isLoadingCompanies = true;
      _companySuggestions = []; // Clear previous suggestions
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/search/company?api_key=$_tmdbApiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        List<Map<String, dynamic>> results =
            (decodedResponse['results'] as List).cast<Map<String, dynamic>>();

        setState(() {
          _companySuggestions = results;
          _isLoadingCompanies = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to fetch companies: ${response.statusCode}');
        setState(() {
          _companySuggestions = [];
          _isLoadingCompanies = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching companies: $e');
      setState(() {
        _companySuggestions = [];
        _isLoadingCompanies = false;
      });
    }
  }

  Future<void> _searchDirectors(String query) async {
    if (query.isEmpty) {
      setState(() {
        _directorSuggestions = [];
        _isLoadingDirectors = false;
      });
      return;
    }

    setState(() {
      _isLoadingDirectors = true;
      _directorSuggestions = []; // Clear previous suggestions
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/search/person?api_key=$_tmdbApiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        List<Map<String, dynamic>> results =
            (decodedResponse['results'] as List).cast<Map<String, dynamic>>();

        setState(() {
          _directorSuggestions = results;
          _isLoadingDirectors = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to fetch directors: ${response.statusCode}');
        setState(() {
          _directorSuggestions = [];
          _isLoadingDirectors = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching directors: $e');
      setState(() {
        _directorSuggestions = [];
        _isLoadingDirectors = false;
      });
    }
  }

  Future<void> _searchWriters(String query) async {
    if (query.isEmpty) {
      setState(() {
        _writerSuggestions = [];
        _isLoadingWriters = false;
      });
      return;
    }

    setState(() {
      _isLoadingWriters = true;
      _writerSuggestions = []; // Clear previous suggestions
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/search/person?api_key=$_tmdbApiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        List<Map<String, dynamic>> results =
            (decodedResponse['results'] as List).cast<Map<String, dynamic>>();

        setState(() {
          _writerSuggestions = results;
          _isLoadingWriters = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to fetch writers: ${response.statusCode}');
        setState(() {
          _writerSuggestions = [];
          _isLoadingWriters = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching writers: $e');
      setState(() {
        _writerSuggestions = [];
        _isLoadingWriters = false;
      });
    }
  }

  Future<void> _searchStars(String query) async {
    if (query.isEmpty) {
      setState(() {
        _starSuggestions = [];
        _isLoadingStars = false;
      });
      return;
    }

    setState(() {
      _isLoadingStars = true;
      _starSuggestions = []; // Clear previous suggestions
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/search/person?api_key=$_tmdbApiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        List<Map<String, dynamic>> results =
            (decodedResponse['results'] as List).cast<Map<String, dynamic>>();

        setState(() {
          _starSuggestions = results;
          _isLoadingStars = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to fetch stars: ${response.statusCode}');
        setState(() {
          _starSuggestions = [];
          _isLoadingStars = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching stars: $e');
      setState(() {
        _starSuggestions = [];
        _isLoadingStars = false;
      });
    }
  }

  Future<void> _fetchPrediction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> movieData = {
        "released": _releasedController.text,
        "writer": _writerController.text,
        "rating": _ratingController.text,
        "name": _nameController.text,
        "genre": _genreController.text,
        "director": _directorController.text,
        "star": _starController.text,
        "country": _countryController.text,
        "company": _companyController.text,
        "runtime": int.parse(_runtimeController.text),
        "score": int.parse(_scoreController.text),
        "budget": int.parse(_budgetController.text),
        "year": int.parse(_yearController.text),
        "votes": int.parse(_votesController.text),
      };

      _movieData = movieData; // Store the movie data

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/predict'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(movieData),
        );

        if (response.statusCode == 200) {
          final decodedResponse = json.decode(response.body);
          setState(() {
            _predictionResult = decodedResponse['prediction'].toString();
            _showResults = true; // Show the results and download button
          });
          _fetchExplanations(movieData).then((_) {
            // Save data AFTER explanations are fetched
            _saveDataToFirestore(movieData, _predictionResult, _explanations);
          });
        } else {
          setState(() {
            _predictionResult = 'Failed to fetch prediction';
          });
        }
      } catch (e) {
        setState(() {
          _predictionResult = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _saveDataToFirestore(Map<String, dynamic> movieData,
      String predictionResult, Map<String, dynamic> explanations) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('predictions')
            .add({
          'movieData': movieData,
          'predictionResult': predictionResult,
          'explanations': explanations,
          'timestamp':
              FieldValue.serverTimestamp(), // Add timestamp for ordering
        });
        Fluttertoast.showToast(msg: 'Data saved to Firestore!');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error saving data to Firestore: $e');
      }
    } else {
      Fluttertoast.showToast(msg: 'User not signed in.');
    }
  }

  Future<void> _fetchExplanations(Map<String, dynamic> movieData) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:3000/explain'), // Try this for Android emulator
        headers: {"Content-Type": "application/json"},
        body: json.encode(movieData),
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          _explanations = decodedResponse['explanation'];
        });
      } else {
        setState(() {
          _explanations = {'error': 'Failed to fetch explanation'};
        });
      }
    } catch (e) {
      setState(() {
        _explanations = {'error': 'Error: ${e.toString()}'};
      });
    }
  }

  Future<void> _downloadAsPdf() async {
    final pdf = pw.Document();

    if (_formKey.currentState!.validate()) {
      // First Page: User Input and Prediction
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Movie Revenue Prediction Report',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 20)),
                pw.SizedBox(height: 20),
                pw.Text('User Input:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
                for (var key in _movieData.keys)
                  pw.Text('$key: ${_movieData[key]}'),
                pw.SizedBox(height: 20),
                pw.Text('Prediction:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.Text('Predicted Revenue: \$$_predictionResult',
                    style: const pw.TextStyle(fontSize: 14)),
              ],
            );
          },
        ),
      );

      // Second Page onwards: SHAP Explanations (One page per model)
      if (_explanations.isNotEmpty && !_explanations.containsKey("error")) {
        for (var modelName in _explanations.keys) {
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SHAP Explanations for $modelName Model',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    pw.SizedBox(height: 20),
                    for (var feature in _explanations[modelName].keys)
                      pw.Text(
                          '  $feature: ${_explanations[modelName][feature].toStringAsFixed(4)}'),
                  ],
                );
              },
            ),
          );
        }
      } else {
        //Error Page
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text("Error: ${_explanations["error"]}",
                    style: pw.TextStyle(color: PdfColors.red)),
              );
            },
          ),
        );
      }

      // Save the pdf
      Directory? appDocDir =
          await getExternalStorageDirectory(); // Change to getApplicationDocumentsDirectory() for internal storage
      appDocDir ??= await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String movieName = _nameController.text;
      final file = File('$appDocPath/$movieName.pdf');
      await file.writeAsBytes(await pdf.save());

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF report saved to ${file.path}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFF0A0E21),
        title: Center(
            child: Text('Enter Movie Data For Prediction',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0A0E21)))),
        elevation: 0,
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _handleRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Make it always scrollable, even when content is short
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const SizedBox(height: 70),
                  // const Text(
                  //   "Enter Your Movie Details For Prediction",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 20, color: Colors.black),
                  // ),
                  // const SizedBox(height: 20),
                  _buildMonthPickerField(),
                  _buildWriterSearchField(),
                  _buildRatingDropdown(),
                  _buildTextField(_nameController, 'Movie Name'),
                  _buildGenreDropdown(),
                  _buildDirectorSearchField(),
                  _buildStarSearchField(),
                  _buildTextField(_countryController, 'Country'),
                  _buildCompanySearchField(),
                  _buildTextField(_runtimeController, 'Runtime',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  _buildScoreDropdown(),
                  _buildTextField(_budgetController, 'Budget',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  _buildYearPickerField(),
                  _buildTextField(_votesController, 'Votes',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.deepPurple,
                    child: SizedBox(
                      width: 160, // Adjust the width as needed
                      child: MaterialButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        onPressed: _fetchPrediction,
                        child: Text(
                          "Predict Revenue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_showResults) // Conditionally render the following widgets
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.deepPurple,
                      child: SizedBox(
                        width: 20,
                        child: MaterialButton(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          onPressed: _downloadAsPdf,
                          child: Text(
                            "Download Results",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Centers children horizontally
                    children: [
                      Center(
                        // Explicitly centers the first Text widget
                        child: Text(
                          'Predicted Revenue is \$${_predictionResult.isEmpty ? " " : _predictionResult}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 56, 23, 96),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        // Explicitly centers the second Text widget
                        child: const Text(
                          'SHAP Explanations:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 56, 23, 96),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_explanations.isNotEmpty)
                    for (var modelName in _explanations.keys)
                      if (modelName != "error")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '  $modelName Model:',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            for (var feature in _explanations[modelName].keys)
                              Text(
                                '      $feature: ${_explanations[modelName][feature].toStringAsFixed(4)}',
                                style: const TextStyle(color: Colors.black),
                              ),
                          ],
                        ),
                  if (_explanations.containsKey("error"))
                    Text("Error: ${_explanations["error"]}",
                        style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthPickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _releasedController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Release Month',
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          suffixIcon: Icon(Icons.calendar_month, color: Colors.white70),
        ),
        readOnly: true, // Prevent manual editing
        onTap: () async {
          DateTime? pickedDate = await showMonthPicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2050),
          );

          if (pickedDate != null) {
            String formattedMonth =
                DateFormat('MMMM').format(pickedDate); // Format to month name
            setState(() {
              _releasedController.text = formattedMonth;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select the release month';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRatingDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Movie Rating',
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dropdownColor: const Color.fromARGB(255, 2, 22, 52),
        style: TextStyle(color: Colors.white),
        value:
            _ratingController.text.isNotEmpty ? _ratingController.text : null,
        items: _ratingOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _ratingController.text = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a movie rating';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenreDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Genre',
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          suffixIcon: _isLoadingGenres
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : null, // Loading indicator
        ),
        dropdownColor: const Color.fromARGB(255, 2, 22, 52),
        style: TextStyle(color: Colors.white),
        value: _genreController.text.isNotEmpty ? _genreController.text : null,
        items: _genreOptions.map((Map<String, dynamic> genre) {
          return DropdownMenuItem<String>(
            value: genre['name'],
            child: Text(genre['name'], style: TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: _isLoadingGenres
            ? null // Disable dropdown while loading
            : (newValue) {
                setState(() {
                  _genreController.text = newValue!;
                });
              },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a genre';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCompanySearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _companyController,
            style: TextStyle(color: Colors.white), // Sets text color to white
            decoration: InputDecoration(
              labelText: 'Company',
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color.fromARGB(255, 2, 22, 52),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              suffixIcon:
                  _isLoadingCompanies ? CircularProgressIndicator() : null,
            ),
            onChanged: (value) {
              _searchCompanies(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the company';
              }
              return null;
            },
          ),
          if (_companySuggestions.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey[300]!),
              ),
              constraints: BoxConstraints(maxHeight: 200), // Scrollable area
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _companySuggestions.length,
                itemBuilder: (context, index) {
                  final company = _companySuggestions[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _companyController.text = company['name'];
                        _companySuggestions =
                            []; // Clear suggestions after selection
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        company['name'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildYearPickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _yearController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Year',
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
        ),
        readOnly: true, // Prevent manual editing
        onTap: () async {
          final DateTime? pickedDate = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Select Year"),
                content: SizedBox(
                  width: 300,
                  height: 300,
                  child: YearPicker(
                    firstDate: DateTime(1900),
                    lastDate: DateTime(DateTime.now().year + 10),
                    selectedDate: DateTime(_yearController.text.isNotEmpty
                        ? int.parse(_yearController.text)
                        : DateTime.now().year),
                    onChanged: (DateTime dateTime) {
                      setState(() {
                        _yearController.text = dateTime.year.toString();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );

          if (pickedDate != null) {
            setState(() {
              _yearController.text = pickedDate.year.toString();
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select the year';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter a valid year';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildScoreDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Score (0-10)',
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dropdownColor: const Color.fromARGB(255, 2, 22, 52),
        style: TextStyle(color: Colors.white),
        value: _scoreController.text.isNotEmpty ? _scoreController.text : null,
        items: _scoreOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _scoreController.text = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a score';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDirectorSearchField() {
    return _buildPersonSearchField(
      labelText: 'Director',
      controller: _directorController,
      suggestions: _directorSuggestions,
      isLoading: _isLoadingDirectors,
      onChanged: (value) => _searchDirectors(value),
      onSuggestionSelected: (person) {
        setState(() {
          _directorController.text = person['name'];
          _directorSuggestions = [];
        });
      },
    );
  }

  Widget _buildWriterSearchField() {
    return _buildPersonSearchField(
      labelText: 'Writer',
      controller: _writerController,
      suggestions: _writerSuggestions,
      isLoading: _isLoadingWriters,
      onChanged: (value) => _searchWriters(value),
      onSuggestionSelected: (person) {
        setState(() {
          _writerController.text = person['name'];
          _writerSuggestions = [];
        });
      },
    );
  }

  Widget _buildStarSearchField() {
    return _buildPersonSearchField(
      labelText: 'Star',
      controller: _starController,
      suggestions: _starSuggestions,
      isLoading: _isLoadingStars,
      onChanged: (value) => _searchStars(value),
      onSuggestionSelected: (person) {
        setState(() {
          _starController.text = person['name'];
          _starSuggestions = [];
        });
      },
    );
  }

  Widget _buildPersonSearchField({
    required String labelText,
    required TextEditingController controller,
    required List<Map<String, dynamic>> suggestions,
    required bool isLoading,
    required ValueChanged<String> onChanged,
    required Function(Map<String, dynamic>) onSuggestionSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.white), // Sets text color to white
            decoration: InputDecoration(
              labelText: labelText,
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color.fromARGB(255, 2, 22, 52),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              suffixIcon: isLoading ? CircularProgressIndicator() : null,
            ),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the $labelText';
              }
              return null;
            },
          ),
          if (suggestions.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey[300]!),
              ),
              constraints: BoxConstraints(maxHeight: 200), // Scrollable area
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final person = suggestions[index];
                  return InkWell(
                    onTap: () {
                      onSuggestionSelected(person);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        person['name'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white), // Sets text color to white
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromARGB(255, 2, 22, 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Add input formatters here
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          } // No need to check for valid numbers if keyboardType is TextInputType.text
          return null;
        },
      ),
    );
  }
}
