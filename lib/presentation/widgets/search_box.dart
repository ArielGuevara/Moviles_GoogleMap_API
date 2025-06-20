import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSuggestionSelected;
  final Future<List<String>> Function(String)? suggestionsCallback;

  const SearchBox({
    Key? key,
    this.controller,
    this.onSuggestionSelected,
    this.suggestionsCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TypeAheadField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Buscar lugar...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        suggestionsCallback: suggestionsCallback ?? (pattern) async{
          // Retorna una lista vacía si no se provee función
          return [];
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: onSuggestionSelected ?? (suggestion) {},
      ),
    );
  }
}