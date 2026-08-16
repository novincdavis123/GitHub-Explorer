import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:githubexplorer/core/theme/app_theme.dart';
import 'package:githubexplorer/features/github/presentation/bloc/github_bloc.dart';
import 'package:githubexplorer/features/github/presentation/pages/search_page.dart';
import 'package:githubexplorer/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await init();

  runApp(const GithubExplorerApp());
}

class GithubExplorerApp extends StatelessWidget {
  const GithubExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GithubBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GitHub Explorer',

        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),

        themeMode: ThemeMode.system,

        home: const SearchPage(),
      ),
    );
  }
}
