import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Replace with your actual TMDB API key
const String apiKey = '845270b9ac9191ab88da8fa8596672f9';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> highestGrossingMovies = [];
  List<dynamic> popularMovies = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchHighestGrossingMovies();
    await fetchPopularMovies();
  }

  Future<void> fetchHighestGrossingMovies() async {
    // Adjust these parameters based on the TMDB API and what "highest grossing" means
    // The below uses "now playing" as a proxy. You'll likely want "top rated" or "popular" with filtering.
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey&language=en-US&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        highestGrossingMovies = data['results'];
      });
    } else {
      // Handle error appropriately (show a message, etc.)
      Fluttertoast.showToast(
          msg:
              'Failed to load highest grossing movies: ${response.statusCode}');
    }
  }

  Future<void> fetchPopularMovies() async {
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        popularMovies = data['results'];
      });
    } else {
      // Handle error appropriately (show a message, etc.)
      Fluttertoast.showToast(
          msg: 'Failed to load popular movies: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFF0A0E21),
        title: Center(
            child: Text('CineCast',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0A0E21)))),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upcoming Movies',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0E21))),
              SizedBox(height: 16),
              SizedBox(
                height: 320, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: highestGrossingMovies.length,
                  itemBuilder: (context, index) {
                    final movie = highestGrossingMovies[index];
                    return MovieCard(movie: movie);
                  },
                ),
              ),
              SizedBox(height: 1),
              Text('Popular',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A0E21))),
              SizedBox(height: 16),
              Column(
                children: [
                  for (var movie in popularMovies)
                    PopularMovieCard(movie: movie),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final dynamic movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              posterUrl,
              height: 220,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  width: 180,
                  color: Colors.grey[800],
                  child: Center(
                      child: Icon(Icons.error_outline, color: Colors.white)),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Text(
            movie['title'],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Release Date: ${movie['release_date']}",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 14),
              Text(
                  '${(movie['vote_average'] as double).toStringAsFixed(1)}/10 IMDb',
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

class PopularMovieCard extends StatelessWidget {
  final dynamic movie;

  const PopularMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            // color: const Color.fromARGB(
            //     255, 158, 158, 158), // Card background color
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
