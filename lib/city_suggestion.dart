// lib/widgets/city_suggestion_list.dart
import 'package:flutter/material.dart';

class CitySuggestionList extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(Map<String, dynamic>) onCitySelected;

  const CitySuggestionList({
    super.key,
    required this.suggestions,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return Container();

    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final city = suggestions[index];

          return ListTile(
            title: Text(city['name']),
            subtitle: Text(
              "${city['admin1'] ?? 'Unknown region'}, ${city['country']}",
            ),
            onTap: () => onCitySelected(city),
          );
        },
      ),
    );
  }
}
