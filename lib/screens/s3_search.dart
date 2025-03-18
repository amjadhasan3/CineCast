import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = '845270b9ac9191ab88da8fa8596672f9';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchMovies(String query) async {
    setState(() {
      _isLoading = true;
      _searchResults = []; // Clear previous results
    });

    final url = Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&include_adult=false&language=en-US&page=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['results'];
          _isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Search failed with status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFF0A0E21),
        title: Center(
            child: Text('Search',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0A0E21)))),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 2, 22, 52),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          _searchMovies(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        return MovieSearchResultTile(movie: movie);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieSearchResultTile extends StatelessWidget {
  final dynamic movie;

  const MovieSearchResultTile({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    posterUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[800],
                        child: Center(child: Icon(Icons.error_outline)),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie['title'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 14),
                          Text(
                              '${(movie['vote_average'] as double).toStringAsFixed(1)}/10 IMDb',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        movie['overview'],
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Release Date: ${movie['release_date']}",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
