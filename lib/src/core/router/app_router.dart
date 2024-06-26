import 'package:beamer/beamer.dart';

import '../../feature/search/search.dart';

class AppRouter {
  static final beamerParser = BeamerParser();
  static final beamerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(routes: {
      '/': (context, state, data) => const BeamPage(
            title: 'Search',
            child: SearchScreen(),
          ),
    }).call,
  );
}
