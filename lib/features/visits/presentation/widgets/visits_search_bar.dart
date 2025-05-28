import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/visits_bloc.dart';

class VisitsSearchBar extends StatefulWidget {
  const VisitsSearchBar({super.key});

  @override
  State<VisitsSearchBar> createState() => _VisitsSearchBarState();
}

class _VisitsSearchBarState extends State<VisitsSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search visits by location or notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    context.read<VisitsBloc>().add(const SearchVisitsEvent(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: theme.textTheme.bodyLarge,
        onChanged: (query) {
          context.read<VisitsBloc>().add(SearchVisitsEvent(query));
        },
      ),
    );
  }
}
