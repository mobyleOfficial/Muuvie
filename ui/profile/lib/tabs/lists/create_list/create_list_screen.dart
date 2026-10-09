import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';

import 'package:profile_ui/tabs/lists/create_list/add_movies_screen.dart';
import 'package:profile_ui/tabs/lists/create_list/create_list_bloc.dart';
import 'package:profile_ui/tabs/lists/create_list/create_list_state.dart';

class CreateListScreen extends StatefulWidget {
  final CreateListCubit cubit;
  final SearchMovies searchMovies;

  const CreateListScreen({
    super.key,
    required this.cubit,
    required this.searchMovies,
  });

  @override
  State<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nameFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openAddMovies(List<Movie> currentSelection) async {
    final result = await Navigator.of(context).push<List<Movie>>(
      MaterialPageRoute(
        builder: (_) => AddMoviesScreen(
          searchMovies: widget.searchMovies,
          alreadySelected: currentSelection,
        ),
      ),
    );

    if (result != null && mounted) {
      widget.cubit.setSelectedMovies(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close),
            onPressed: () => context.router.maybePop(),
          ),
          title: const Text('New List'),
          centerTitle: true,
          actions: [
            BlocBuilder<CreateListCubit, CreateListState>(
              builder: (context, state) {
                final isSaving = state is CreateListSaving;
                return TextButton(
                  onPressed: isSaving
                      ? null
                      : () => widget.cubit.createList(
                            _nameController.text,
                            _descriptionController.text,
                          ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<CreateListCubit, CreateListState>(
          listener: (context, state) {
            switch (state) {
              case CreateListSuccess():
                context.router.maybePop(true);
              case CreateListError(:final message):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              default:
                break;
            }
          },
          child: BlocBuilder<CreateListCubit, CreateListState>(
            builder: (context, state) {
              final selectedMovies = switch (state) {
                CreateListIdle(:final selectedMovies) => selectedMovies,
                CreateListSaving(:final selectedMovies) => selectedMovies,
                CreateListError(:final selectedMovies) => selectedMovies,
                _ => <Movie>[],
              };

              return CustomScrollView(
                slivers: [
                  // Name & description fields
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textInputAction: TextInputAction.next,
                            style:
                                TextStyle(color: colorScheme.onSurface),
                            cursorColor: colorScheme.primary,
                            decoration: _inputDecoration(
                                context, 'Name'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            textInputAction: TextInputAction.done,
                            maxLines: 3,
                            style:
                                TextStyle(color: colorScheme.onSurface),
                            cursorColor: colorScheme.primary,
                            decoration: _inputDecoration(
                                context, 'Description'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Movies section header + add button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            selectedMovies.isNotEmpty
                                ? 'MOVIES (${selectedMovies.length})'
                                : 'MOVIES',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                _openAddMovies(selectedMovies),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Movies'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selected movies list
                  if (selectedMovies.isNotEmpty)
                    SliverList.builder(
                      itemCount: selectedMovies.length,
                      itemBuilder: (context, index) =>
                          _SelectedMovieTile(
                        movie: selectedMovies[index],
                        onRemove: () => widget.cubit
                            .removeMovie(selectedMovies[index].id),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No movies added yet',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Bottom padding
                  const SliverPadding(
                      padding: EdgeInsets.only(bottom: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SelectedMovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onRemove;

  const _SelectedMovieTile({required this.movie, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 40,
              height: 58,
              child: movie.posterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:
                          TmdbImageUrl.buildPosterSmall(movie.posterPath),
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                          color: colorScheme.surfaceContainerHighest),
                      errorWidget: (_, _, _) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.movie,
                            size: 18,
                            color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.movie,
                          size: 18, color: colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (movie.info?.releaseDate.isNotEmpty ?? false)
                  Text(
                    movie.info!.releaseDate.length >= 4
                        ? movie.info!.releaseDate.substring(0, 4)
                        : movie.info!.releaseDate,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                size: 18, color: colorScheme.onSurfaceVariant),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
