import 'package:active_ecommerce_flutter/helpers/addons_helper.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/screens/categories_list2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/splash.dart';
import 'package:shared_value/shared_value.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'dart:async';
import 'app_config.dart';
import 'package:active_ecommerce_flutter/services/push_notification_service.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'lang_config.dart';
import 'package:firebase_core/firebase_core.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print("app_mobile_language.1isEmpty${app_mobile_language.$.isEmpty}");
  AddonsHelper().setAddonsData();
  BusinessSettingHelper().setBusinessSettingData();
  app_language.load();
  app_mobile_language.load();
  app_language_rtl.load();

  access_token.load().whenComplete(() {
    AuthHelper().fetch_and_set();
  });

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (OtherConfig.USE_PUSH_NOTIFICATION) {
      Future.delayed(Duration(milliseconds: 100), () async {
        PushNotificationService().initialise();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
          return MaterialApp(
            builder: OneContext().builder,
            navigatorKey: OneContext().navigator.key,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              accentColor: MyTheme.accent_color,
              /*textTheme: TextTheme(
              bodyText1: TextStyle(),
              bodyText2: TextStyle(fontSize: 12.0),
            )*/
              //
              // the below code is getting fonts from http
              textTheme: GoogleFonts.sourceSansProTextTheme(textTheme).copyWith(
                bodyText1:
                    GoogleFonts.sourceSansPro(textStyle: textTheme.bodyText1),
                bodyText2: GoogleFonts.sourceSansPro(
                    textStyle: textTheme.bodyText2, fontSize: 12),
              ),
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: LangConfig().supportedLocales(),
            //home: CategoryList2()
            home: Splash(),
            //home: Main(),
          );
        }));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // The group value
  var _result;
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          //  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile(
                contentPadding: EdgeInsets.all(0),
                title: const Text(
                  'Home (7am - 9pm, All day )',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: 4,
                groupValue: _result,
                onChanged: (value) {
                  setState(() {
                    _result = value;
                  });
                }),
            RadioListTile(
                contentPadding: EdgeInsets.all(0),
                toggleable: true,
                title: const Text(
                  'Office ( 9am - 6pm, Weekdays )',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: 5.4,
                groupValue: _result,
                onChanged: (value) {
                  setState(() {
                    _result = value;
                  });
                }),
          ],
        ));
  }
}

// Container(
//   padding: EdgeInsets.all(5),
//   child: buildFlashDealLisst(context) ,)
// Row(
//   children: [
//     Container(
//       decoration: BoxDecoration(
//           borderRadius:
//               BorderRadius.circular(4),
//           color: Colors.black),
//       height: 20,
//       width: 24,
//       child: Center(
//         child: Text(
//           '10',
//           // AppLocalizations.of(context).home_screen_featured_categories,
//           style: TextStyle(
//               fontSize: 16,
//               color: Colors.white),
//         ),
//       ),
//     ),
//     SizedBox(
//         width: 18,
//         child: Text(
//           (':'),
//           textAlign: TextAlign.center,
//           style: TextStyle(
//               fontSize: 26,
//               color: Colors.black),
//         )),
//     SizedBox(
//       width: 2,
//     ),
//     Container(
//       decoration: BoxDecoration(
//           borderRadius:
//               BorderRadius.circular(4),
//           color: Colors.black),
//       height: 20,
//       width: 24,
//       child: Center(
//         child: Text(
//           '04',
//           // AppLocalizations.of(context).home_screen_featured_categories,
//           style: TextStyle(
//               fontSize: 16,
//               color: Colors.white),
//         ),
//       ),
//     ),
//     SizedBox(
//         width: 18,
//         child: Text(
//           (':'),
//           textAlign: TextAlign.center,
//           style: TextStyle(
//               fontSize: 26,
//               color: Colors.black),
//         )),
//     Container(
//       decoration: BoxDecoration(
//           borderRadius:
//               BorderRadius.circular(4),
//           color: Colors.black),
//       height: 20,
//       width: 24,
//       child: Center(
//         child: Text(
//           '17',
//           // AppLocalizations.of(context).home_screen_featured_categories,
//           style: TextStyle(
//               fontSize: 16,
//               color: Colors.white),
//         ),
//       ),
//     ),
//     SizedBox(
//         width: 18,
//         child: Text(
//           (':'),
//           textAlign: TextAlign.center,
//           style: TextStyle(
//               fontSize: 26,
//               color: Colors.black),
//         )),
//     Container(
//       decoration: BoxDecoration(
//           borderRadius:
//               BorderRadius.circular(4),
//           color: Colors.black),
//       height: 20,
//       width: 24,
//       child: Center(
//         child: Text(
//           '00',
//           // AppLocalizations.of(context).home_screen_featured_categories,
//           style: TextStyle(
//               fontSize: 16,
//               color: Colors.white),
//         ),
//       ),
//     )
//   ],
// ),

class MyApps extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: 
  
       MyStatefulWidget(),
    
    );
  }
}

class LinkedLabelRadio extends StatelessWidget {
  const LinkedLabelRadio({
    this.label,
    this.padding,
    this.groupValue,
    this.value,
    this.onChanged,
  }) : super();

  final String label;
  final EdgeInsets padding;
  final bool groupValue;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Radio<bool>(
            groupValue: groupValue,
            value: value,
            onChanged: (bool newValue) {
              onChanged(newValue);
            }),
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                debugPrint('Label has been tapped.');
              },
          ),
        ),
      ],
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool _isRadioSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LinkedLabelRadio(
            label: ('First tappable label text'),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            value: true,
            groupValue: _isRadioSelected,
            onChanged: (bool newValue) {
              setState(() {
                _isRadioSelected = newValue;
              });
            },
          ),
          LinkedLabelRadio(
            label: 'Second tappable label text',
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            value: false,
            groupValue: _isRadioSelected,
            onChanged: (bool newValue) {
              setState(() {
                _isRadioSelected = newValue;
              });
            },
          ),
        ],
      
    );
  }
}
