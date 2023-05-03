import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnetionNotifier extends InheritedNotifier<ValueNotifier<bool>> {
  const ConnetionNotifier({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ValueNotifier<bool> of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ConnetionNotifier>()!
        .notifier!;
  }
}

const titulo = 'Verifica internet';
final internetConnectionChecker = InternetConnectionChecker.createInstance(
  checkTimeout: const Duration(seconds: 1),
  checkInterval: const Duration(seconds: 1),
  // addresses: // pode-se colocar o endereco do servidor de apo para verificar se esta on-line
);

Future<void> main() async {
  //final hasConnection = await InternetConnectionChecker().hasConnection;
  // substituido pela variavel global
  final hasConnection = await internetConnectionChecker.hasConnection;

  runApp(
    ConnetionNotifier(
      notifier: ValueNotifier(hasConnection),
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final StreamSubscription<InternetConnectionStatus> listener;

  @override
  void initState() {
    super.initState();

    //listener = InternetConnectionChecker().onStatusChange.listen((status) {
    // substituido por
    listener = internetConnectionChecker.onStatusChange.listen((status) {
      final notifier = ConnetionNotifier.of(context);
      notifier.value =
          status == InternetConnectionStatus.connected ? true : false;
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: titulo,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final hasConnetion = ConnetionNotifier.of(context).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
            ),
            child: Icon(hasConnetion ? Icons.wifi : Icons.wifi_off),
          ),
        ],
      ),
      body: const Center(
        child: Text('Verifica conexão com internet'),
        //Text(' Possui internet ${hasConnetion ? 'sim' : 'nao'}'),
      ),
    );
  }
}
