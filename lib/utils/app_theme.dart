// ignore: deprecated_member_use
import 'package:flutter/material.dart';

const String nomeDesenvolvedor = 'Emanuel Amaral Nascimento';
const Color corAzulEscuro = Color(0xFF14284B);
const Color corOffWhite = Color(0xFFF6F3EA);
const Color corPapel = Color(0xFFFFFDF8);
const Color corFundoEscuro = Color(0xFF0F172A);
const Color corPapelEscuro = Color(0xFF1E293B);
const Color corDestaqueEscuro = Color(0xFF7CB7FF);
const Color corTextoEscuro = Color(0xFFE2E8F0);
const Color corBordaEscuro = Color(0xFF475569);

Color corPapelDe(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? corPapelEscuro : corPapel;

ThemeData criarTemaClaro() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: corAzulEscuro,
    primary: corAzulEscuro,
    onPrimary: corOffWhite,
  ),
  scaffoldBackgroundColor: corOffWhite,
  appBarTheme: const AppBarTheme(
    backgroundColor: corAzulEscuro,
    foregroundColor: corOffWhite,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: corAzulEscuro,
    foregroundColor: corOffWhite,
  ),
);

ThemeData criarTemaEscuro() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: corDestaqueEscuro,
    brightness: Brightness.dark,
  ).copyWith(
    primary: corDestaqueEscuro,
    onPrimary: corFundoEscuro,
    surface: corPapelEscuro,
    onSurface: corTextoEscuro,
    outline: corBordaEscuro,
  ),
  scaffoldBackgroundColor: corFundoEscuro,
  appBarTheme: const AppBarTheme(
    backgroundColor: corPapelEscuro,
    foregroundColor: corTextoEscuro,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: corDestaqueEscuro,
    foregroundColor: corFundoEscuro,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: corDestaqueEscuro,
      foregroundColor: corFundoEscuro,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: corBordaEscuro),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: corDestaqueEscuro, width: 2),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: corPapelEscuro,
  ),
);
