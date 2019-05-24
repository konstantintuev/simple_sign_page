
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:simple_sign_page/refresh_no_indicator.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new CupertinoApp(
      title: 'Simple Sign In/Out Page',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: RegisterLoginPage(),
    );
  }
}


class RegisterLoginPage extends StatefulWidget {
  RegisterLoginPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  String title;

  @override
  _RegisterLoginPageState createState() => new _RegisterLoginPageState();
}

class _RegisterLoginPageState extends State<RegisterLoginPage> with TickerProviderStateMixin {

  String action = "Login";

  bool repeatPassVisible = false;

  TextEditingController emailController = new TextEditingController();
  TextEditingController pswController = new TextEditingController();
  TextEditingController pswRepController = new TextEditingController();

  var server_url = "http://localhost:8080";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTextStyle(
        style: const TextStyle(
          fontFamily: '.SF UI Text',
          inherit: false,
          fontSize: 17.0,
          color: CupertinoColors.black,
        ),

        child:  new Scaffold(
          appBar: new CupertinoNavigationBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            middle: new Text("Login/Register"),
          ),
          body: new RefreshNoIndicator(

            onRefresh: () {
              return Future<void>.delayed(const Duration(milliseconds: 200)).then<void>((_) {
                if (mounted) {
                  setState(() {
                    if (!repeatPassVisible) {
                      action = "Register";
                      repeatPassVisible = true;
                    } else {
                      action = "Login";
                      repeatPassVisible = false;
                    }
                  });
                }
              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: new Container(
                child: new Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 48),
                    child: new Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          "Swipe down to ${action == "Register" ? "Login" : "Register"}",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        new Center(
                          // Center is a layout widget. It takes a single child and positions it
                          // in the middle of the parent.
                          child: new Column(
                            // Column is also layout widget. It takes a list of children and
                            // arranges them vertically. By default, it sizes itself to fit its
                            // children horizontally, and tries to be as tall as its parent.
                            //
                            // Invoke "debug paint" (press "p" in the console where you ran
                            // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
                            // window in IntelliJ) to see the wireframe for each widget.
                            //
                            // Column has various properties to control how it sizes itself and
                            // how it positions its children. Here we use mainAxisAlignment to
                            // center the children vertically; the main axis here is the vertical
                            // axis because Columns are vertical (the cross axis would be
                            // horizontal).
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              /*new Text(
                    "Login",
                    style: Theme.of(context).textTheme.display1,
                  ),*/
                              new CupertinoTextField(
                                placeholder: "E-Mail",
                                controller: emailController,
                              ),
                              SizedBox(height: 10.0),
                              new CupertinoTextField(
                                placeholder: "Password",
                                controller: pswController,
                              ),
                              SizedBox(height: 10.0),
                              AnimatedOpacity(
                                opacity: repeatPassVisible ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 500),
                                child: new AnimatedSize(
                                  vsync: this,
                                  duration: Duration(milliseconds: 450),
                                  child: SizedBox(
                                    height: repeatPassVisible ? 34 : 0,
                                    child: new CupertinoTextField(
                                      controller: pswRepController,
                                      placeholder: "Repeat Password",
                                    ),
                                  )
                                  ),
                              ),
                              SizedBox(height: 10.0),

                              new CupertinoButton(
                                  child: new Text(action),
                                  color: CupertinoColors.activeBlue,
                                  onPressed: _login_register
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                ),
                height: MediaQuery.of(context).size.height - 72,
              )
            )
          )
        )
    );
  }

  Future _login_register() async {
    if (repeatPassVisible) {
      String url =
          '$server_url/register';
      Map map = {
        "email": emailController.text,
        "password": pswRepController.text
      };

      print(await apiRequest(url, map));
    } else {
      String url =
          '$server_url/login';
      Map map = {
        "email": emailController.text,
        "password": pswController.text
      };

      print(await apiRequest(url, map));
    }
  }

  Future<String> apiRequest(String url, Map jsonMap) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    if (response.statusCode != HttpStatus.ok) {
      httpClient.close();
      return Future<String>.value(null);
    }
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }
}
