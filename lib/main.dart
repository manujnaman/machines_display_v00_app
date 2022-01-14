import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

// import 'package:async/async.dart';
// import 'dart:convert';
// import 'dart:async';
// import 'package:web_socket_channel/io.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:flutter/widgets.dart';

import 'utilities.dart';
import 'deployment_model.dart';
import 'canvas_screen.dart';

bool isLoggedIn = false;
String loginEmail = '';
String loginUserName = '';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    // 'https://www.googleapis.com/auth/contacts.readonly',
  ],
);


class SizeConfig {

  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}


void main() {
  runApp(MachinesInterfaceApp());
}

class MachinesInterfaceApp extends StatelessWidget {
  // Root widget of this application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DeploymentState()),
       ],
      child: MaterialApp(
        title: 'Machines Interface App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: SignInScreen(), //SettingsPage(title: 'Copilot App'),
        routes: {
          '/signin': (context) => SignInScreen(),
          '/canvas': (context) => CanvasScreen(title: 'oakcreek-wi',),
          '/about': (context) => AboutScreen(),
          // '/settings': (context) => SettingsPage(title: 'Copilot App'),
          // '/handheld': (context) => HandheldScreen(),
          // '/stations': (context) => StationsScreen(),
          // '/learn': (context) => LearnScreen(),
          // '/health': (context) => HealthScreen(),
          // '/admin': (context) => AdminScreen(),
        },
        navigatorObservers: [ MyNavigatorObserver() ],
      ),
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (isInDebugMode) print('didPush route=${route.settings.name} previousRoute=${previousRoute?.settings?.name}');
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  AppHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Consumer<DeploymentState>(
        builder: (context, deploymentState, child) {
          return Container(
            margin: const EdgeInsets.fromLTRB(2.5, 5, 2.5, 5),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset(
                      'images/icon-48x48.png', fit: BoxFit.cover
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        deploymentState.clientName + " " + deploymentState.deploymentName, //deploymentModel._machineName
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                          isLoggedIn ? loginEmail : '(Not logged in)' //deploymentModel._machineName
                      )
                  ),
                  const Icon(
                      Icons.wifi_tethering,
                      // (deploymentModel.hasHighConnectionDelay()) ? Icons.portable_wifi_off : Icons.wifi_tethering,
                      color: Colors.green, //(deploymentModel.hasHighConnectionDelay()) ? Colors.red :
                      // (deploymentModel.hasGoodConnection()) ? Colors.green : Colors.amberAccent,
                      size: 30
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 0.0),
                    child: Icon(
                        Icons.minimize,
                        // ((deploymentModel.hasHighConnectionDelay()) || (deploymentModel.gatewayCommanderClientDelayMs < 0)) ? Icons.minimize : Icons.apartment,
                        color:
                        // ((deploymentModel.hasHighConnectionDelay()) || (deploymentModel.gatewayCommanderClientDelayMs < 0)) ? Colors.grey[700] :
                        // (deploymentModel.gatewayCommanderClientDelayMs < 2000) ? Colors.green :
                        // (deploymentModel.gatewayCommanderClientDelayMs < 5000) ? Colors.amberAccent :
                        Colors.grey,
                        size: 30
                    ),
                  ),

                ]
            ),
          );
        }
    );
  }
}



class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 100.0,
            child: DrawerHeader(
              child: Text(
                  'Anantak Machines Interface',
                  style: TextStyle(
                    fontSize: 20,
                  )
              ),
              decoration: BoxDecoration(
                color: Colors.black26,
              ),
              // margin: EdgeInsets.all(0.0),
              // padding: EdgeInsets.all(0.0),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.apps, color: Colors.black),
            title: const Text(
              'Log In',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/signin');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.pin_drop, color: Colors.black),
            title: const Text(
              'Dashboard',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/canvas');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          /*ListTile(
            leading: Icon(Icons.edit_road, color: Colors.green),
            title: Text(
              'Learn',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/learn');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.electrical_services, color: Colors.green),
            title: Text(
              'Health',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/health');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.article, color: Colors.black),
            title: const Text(
              'List View',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/about');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.agriculture, color: Colors.black),
            title: const Text(
              'Usage',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/about');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black),
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/settings');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: Colors.black),
            title: const Text(
              'About',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              // Update the state of the app
              Navigator.popAndPushNamed(context, '/about');
              // Then close the drawer
              // Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}



class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State createState() => SignInState();
}


class SignInState extends State<SignInScreen> with AutomaticKeepAliveClientMixin {
  GoogleSignInAccount? _currentUser;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        loginEmail = _currentUser?.email ?? "";
        isLoggedIn = true;
        loginUserName = _currentUser?.displayName ?? '';
      });
    });
    _googleSignIn.signInSilently();
  }


  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    // GoogleSignInAccount? user = _currentUser;
    if (isLoggedIn) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 400,
                child: ListTile(
                  // leading: GoogleUserCircleAvatar(
                  //   identity: user? null,
                  // ),
                  title: Text(loginUserName),
                  subtitle: Text(loginEmail),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 400,
                height: 100,
                child: const Text("Signed in successfully."),
              ),
              Container(
                  alignment: Alignment.center,
                  width: 400,
                  height: 100,
                  child: ElevatedButton(
                    child: const Text('SIGN OUT'),
                    onPressed: _handleSignOut,
                  )
              ),
            ],
          )
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
          title: AppHeader(title: 'About'),
          backgroundColor: Colors.grey[850]
      ),

      body: Center(
       child: _buildBody(),
      ),

      drawer: MainDrawer(
        // parameters
      ),

    );
  }

}



class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
          title: AppHeader(title: 'About'),
          backgroundColor: Colors.grey[850]
      ),

      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                          'images/icon-96x96.png',
                          fit: BoxFit.cover
                      ),
                      Text(
                          'Anantak Robotics',
                          style: TextStyle(
                            fontSize: 25,
                          )
                      ),
                      // Text(
                      //     'Robot Controller',
                      //     style: TextStyle(
                      //       fontSize: 22,
                      //     )
                      // ),

                    ]
                ),
              ),

              Consumer<DeploymentState>(
                  builder: (context, deploymentModel, child) {
                    return Text(
                        "Machines Interface", //deploymentModel.appName,
                        style: TextStyle(
                          fontSize: 17,
                        )
                    );
                  }
              ),

              Text(
                  'Display: ' + SizeConfig.screenHeight.toStringAsFixed(0) +' x '+ SizeConfig.screenWidth.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 15,
                  )
              ),

              Consumer<DeploymentState>(
                  builder: (context, deploymentModel, child) {
                    return Text(
                        'APP Version: ', //+deploymentModel.version+'+'+deploymentModel.buildNumber,
                        style: TextStyle(
                          fontSize: 15,
                        )
                    );
                  }
              ),

              Consumer<DeploymentState>(
                  builder: (context, deploymentModel, child) {
                    return Text(
                        'SU Version: Unknown', //+deploymentModel.sensorUnitVersionString,
                        style: TextStyle(
                          fontSize: 15,
                        )
                    );
                  }
              ),

            ]
        ),
      ),

      drawer: MainDrawer(
        // parameters
      ),

    );
  }
}

