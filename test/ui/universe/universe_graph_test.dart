import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';

Movie _movie(int id) => Movie(id: id, title: 'Filme $id', posterPath: '');

List<Movie> _movies(Iterable<int> ids) => ids.map(_movie).toList();

void main() {
  test('the origin sits at the center with its similar movies in orbit', () {
    final graph = UniverseGraph.origin(_movie(1), _movies([2, 3, 4]));

    expect(graph.originId, 1);
    expect(graph.origin.center, Offset.zero);
    expect(graph.origin.hops, 0);
    expect(graph.origin.planets.map((planet) => planet.movie.id), [2, 3, 4]);
    expect(graph.origin.planets.map((planet) => planet.rank), [0, 1, 2]);
  });

  test('a planet that becomes a system leaves its orbit, the others stay', () {
    final graph = UniverseGraph.origin(
      _movie(1),
      _movies([2, 3, 4]),
    ).addSystem(_movie(3), _movies([30, 31]));

    expect(graph.origin.planets.map((planet) => planet.movie.id), [2, 4]);
    expect(graph.origin.planets.map((planet) => planet.rank), [0, 2]);
    expect(graph.origin.orbitCount, 3);
    final system = graph.systemOf(3)!;
    expect(system.parentStarId, 1);
    expect(system.hops, 1);
    expect(system.planets.map((planet) => planet.movie.id), [30, 31]);
  });

  test('a movie already in the universe is never added again', () {
    final graph = UniverseGraph.origin(
      _movie(1),
      _movies([2, 3, 4]),
    ).addSystem(_movie(3), _movies([1, 2, 30, 30, 4, 31]));

    expect(graph.systemOf(3)!.planets.map((planet) => planet.movie.id), [
      30,
      31,
    ]);
    expect(graph.systemOf(3)!.planets.map((planet) => planet.rank), [0, 1]);
  });

  test('ten jumps in a row never overlap two systems', () {
    var graph = UniverseGraph.origin(
      _movie(1),
      _movies(List.generate(10, (index) => 100 + index)),
    );
    var current = 1;
    for (var jump = 0; jump < 10; jump++) {
      final system = graph.systemOf(current)!;
      // Always the outermost planet still in orbit, the worst case for space.
      final next = system.planets.last.movie;
      final similar = _movies(
        List.generate(10, (index) => (jump + 2) * 1000 + index),
      );
      graph = graph.addSystem(next, similar);
      current = next.id;
    }

    final systems = graph.systems.toList();
    expect(systems, hasLength(11));
    expect(graph.systemOf(current)!.hops, 10);
    for (var first = 0; first < systems.length; first++) {
      for (var second = first + 1; second < systems.length; second++) {
        final distance =
            (systems[first].center - systems[second].center).distance;
        expect(
          distance,
          greaterThanOrEqualTo(systems[first].extent + systems[second].extent),
          reason:
              '${systems[first].star.id} and ${systems[second].star.id} overlap',
        );
      }
    }
    final allMovies = [
      for (final system in systems) ...[
        system.star.id,
        for (final planet in system.planets) planet.movie.id,
      ],
    ];
    expect(allMovies.toSet(), hasLength(allMovies.length));
  });

  test('every planet of one system can become a system without overlaps', () {
    var graph = UniverseGraph.origin(
      _movie(1),
      _movies(List.generate(10, (index) => 100 + index)),
    );
    for (var index = 0; index < 10; index++) {
      graph = graph.addSystem(
        _movie(100 + index),
        _movies(List.generate(10, (planet) => 1000 * (index + 2) + planet)),
      );
    }

    final systems = graph.systems.toList();
    for (var first = 0; first < systems.length; first++) {
      for (var second = first + 1; second < systems.length; second++) {
        expect(
          (systems[first].center - systems[second].center).distance,
          greaterThanOrEqualTo(systems[first].extent + systems[second].extent),
        );
      }
    }
    expect(graph.origin.planets, isEmpty);
  });

  test('only a planet in orbit can become a system', () {
    final graph = UniverseGraph.origin(_movie(1), _movies([2]));

    expect(() => graph.addSystem(_movie(99), const []), throwsArgumentError);
  });

  test('the bounds hold every system', () {
    final graph = UniverseGraph.origin(
      _movie(1),
      _movies([2, 3]),
    ).addSystem(_movie(2), _movies([20]));

    for (final system in graph.systems) {
      expect(graph.bounds.contains(system.center), isTrue);
    }
  });
}
