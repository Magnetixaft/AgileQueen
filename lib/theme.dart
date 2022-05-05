import 'package:flutter/material.dart';

class ElliTheme {
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          primary: ElliColors.darkBlue,
          secondary: ElliColors.pink,
          onSecondary: ElliColors.white,
          onPrimary: ElliColors.white,
          background: ElliColors.white,
          brightness: Brightness.light,
          error: ElliColors.darkPink,
          onBackground: ElliColors.black,
          onError: ElliColors.white,
          onSurface: ElliColors.black,
          surface: ElliColors.white,
        ),
        scaffoldBackgroundColor: ElliColors.white,

        // Appbar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: ElliColors.white,
          foregroundColor: ElliColors.black,
          elevation: 0.0, // To match mockup
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(double.maxFinite, 50),
          ),
        ),
      );
}

class ElliColors {
  static const black = Color(0xff202020);
  static const grey = Color(0xff8E8E8E);
  static const mediumGrey = Color(0xffD9D9D9);
  static const lightGrey = Color(0xffE8E8E8);
  static const whiteGrey = Color(0xffF4F4F4);
  static const white = Color(0xffffffff);

  static const darkBlue = Color(0xff121A35);
  static const darkPink = Color(0xffCB575E);
  static const pink = Color(0xffFF6374);
  static const lightPink = Color(0xffFEDEE1);
}

class ElliText {
  static const _title1 = 67.0;
  static const _title2 = 34.0;
  static const _headline = 22.0;
  static const _body = 17.0;
  static const _subHead = 14.0;
  static const _caption = 8.0;
  static const _navBar = 10.0;

  static const _regular = FontWeight.w400;
  static const _bold = FontWeight.w700;

  static const _black = ElliColors.black;
  static const _grey = ElliColors.black;
  static const _pink = ElliColors.pink;
  static const _white = ElliColors.white;

  static const _font = "Poppins";

  static const regularTilte1 = TextStyle(
    inherit: false,
    color: _black,
    height: 80,
    fontSize: _title1,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  static const regularTilte2 = TextStyle(
    inherit: false,
    color: _black,
    height: 40,
    fontSize: _title2,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  static const regularHeadLine = TextStyle(
    inherit: false,
    color: _black,
    height: 27,
    fontSize: _headline,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  static const regularBody = TextStyle(
    inherit: false,
    color: _black,
    height: 20,
    fontSize: _body,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  static const regularSubHead = TextStyle(
    inherit: false,
    color: _black,
    height: 16,
    fontSize: _subHead,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  static const regularCaption = TextStyle(
    inherit: false,
    color: _black,
    height: 10,
    fontSize: _caption,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  static const regularNavBar = TextStyle(
    inherit: false,
    color: _black,
    height: 10,
    fontSize: _navBar,
    fontFamily: _font,
    fontWeight: _regular,
    textBaseline: TextBaseline.ideographic,
  );

  //Regular
  static final regularWhiteTitle1 = regularTilte1.copyWith(color: _white);
  static final regularWhiteTitle2 = regularTilte2.copyWith(color: _white);
  static final regularWhiteHeadLine = regularHeadLine.copyWith(color: _white);
  static final regularWhiteBody = regularBody.copyWith(color: _white);
  static final regularWhiteSubHead = regularSubHead.copyWith(color: _white);
  static final regularWhiteCaption = regularCaption.copyWith(color: _white);

  static final regularGreyTitle1 = regularTilte1.copyWith(color: _grey);
  static final regularGreyTitle2 = regularTilte2.copyWith(color: _grey);
  static final regularGreyHeadLine = regularHeadLine.copyWith(color: _grey);
  static final regularGreyBody = regularBody.copyWith(color: _grey);
  static final regularGreySubHead = regularSubHead.copyWith(color: _grey);
  static final regularGreyCaption = regularCaption.copyWith(color: _grey);

  static final regularPinkTitle1 = regularTilte1.copyWith(color: _pink);
  static final regularPinkTitle2 = regularTilte2.copyWith(color: _pink);
  static final regularPinkHeadLine = regularHeadLine.copyWith(color: _pink);
  static final regularPinkBody = regularBody.copyWith(color: _pink);
  static final regularPinkSubHead = regularSubHead.copyWith(color: _pink);
  static final regularPinkCaption = regularCaption.copyWith(color: _pink);

  //Bold
  static final boldTitle1 = regularTilte1.copyWith(fontWeight: _bold);
  static final boldTitle2 = regularTilte2.copyWith(fontWeight: _bold);
  static final boldHeadLine = regularHeadLine.copyWith(fontWeight: _bold);
  static final boldBody = regularBody.copyWith(fontWeight: _bold);
  static final boldSubHead = regularSubHead.copyWith(fontWeight: _bold);
  static final boldCaption = regularCaption.copyWith(fontWeight: _bold);

  static final boldWhiteTitle1 =
      regularTilte1.copyWith(fontWeight: _bold, color: _white);
  static final boldWhiteTitle2 =
      regularTilte2.copyWith(fontWeight: _bold, color: _white);
  static final boldWhiteHeadLine =
      regularHeadLine.copyWith(fontWeight: _bold, color: _white);
  static final boldWhiteBody =
      regularBody.copyWith(fontWeight: _bold, color: _white);
  static final boldWhiteSubHead =
      regularSubHead.copyWith(fontWeight: _bold, color: _white);
  static final boldWhiteCaption =
      regularCaption.copyWith(fontWeight: _bold, color: _white);

  static final boldGreyTitle1 =
      regularTilte1.copyWith(fontWeight: _bold, color: _grey);
  static final boldGreyTitle2 =
      regularTilte2.copyWith(fontWeight: _bold, color: _grey);
  static final boldGreyHeadLine =
      regularHeadLine.copyWith(fontWeight: _bold, color: _grey);
  static final boldGreyBody =
      regularBody.copyWith(fontWeight: _bold, color: _grey);
  static final boldGreySubHead =
      regularSubHead.copyWith(fontWeight: _bold, color: _grey);
  static final boldGreyCaption =
      regularCaption.copyWith(fontWeight: _bold, color: _grey);

  static final boldPinkTitle1 =
      regularTilte1.copyWith(fontWeight: _bold, color: _pink);
  static final boldPinkTitle2 =
      regularTilte2.copyWith(fontWeight: _bold, color: _pink);
  static final boldPinkHeadLine =
      regularHeadLine.copyWith(fontWeight: _bold, color: _pink);
  static final boldPinkBody =
      regularBody.copyWith(fontWeight: _bold, color: _pink);
  static final boldPinkSubHead =
      regularSubHead.copyWith(fontWeight: _bold, color: _pink);
  static final boldPinkCaption =
      regularCaption.copyWith(fontWeight: _bold, color: _pink);
}

class UiHelper {
  //Spaces
  static const fullSpace = 20;
  static const halfSpace = 10;
  static const quarterSpace = 5;

  //Corner Radius
  static const cornerRadius = 5;

  //Sizes
  static const normalWidgetWidth = 350;
  static const normalWidgetHeight = 60;
}
