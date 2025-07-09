// lib/themes/app_theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,

  // 2. Cor de fundo padrão para TODOS os Scaffolds no aplicativo
  // Este é o principal responsável pela cor de fundo da página
  scaffoldBackgroundColor: Colors.grey[850], // Cinza escuro de fundo
  // 3. Configurando ColorScheme (Paleta de Cores do Material Design)
  // Use ColorScheme.dark() como base para um tema escuro e defina suas cores principais
  colorScheme: ColorScheme.dark(
    // Cores Primárias (usadas para elementos principais, botões, etc.)
    primary: const Color(0xFF007BFF), // Azul Principal
    onPrimary: Colors.white, // Cor do texto/ícone em cima do primary
    // Cores Secundárias (para ações flutuantes, destaques, etc.)
    secondary: const Color(0xFFB8860B), //  Dourado Envelhecido
    onSecondary: Colors.white, // Cor do texto/ícone em cima do background
    // surface: Cor de "superfícies" como cards, dialogs, sheets
    surface:
        Colors
            .grey[900]!, // Fundo para cards, inputs, etc. (mais escuro que o background)
    onSurface: Colors.white, // Cor do texto/ícone em cima da surface
    // Cores de Erro
    error: const Color(0xFFDC3545), // Vermelho de Alerta
    onError: Colors.white, // Cor do texto/ícone em cima do erro
  ),

  // 4. Tema da AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900], // Fundo dark do AppBar
    foregroundColor: Colors.white, // Cor dos ícones e textos no AppBar
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
    ), // Estilo do título
    iconTheme: const IconThemeData(
      color: Colors.white,
    ), // Cor dos ícones de voltar/menu
  ),

  // 5. Tema dos Inputs (TextFormField/TextField) - MUITO IMPORTANTE para o design!
  inputDecorationTheme: InputDecorationTheme(
    filled: true, // Indica que o input tem cor de preenchimento
    fillColor:
        Colors
            .grey[900], // Cor de fundo dos TextFields (mais escura que o background)
    hintStyle: TextStyle(color: Colors.grey[600]), // Cor do placeholder
    labelStyle: TextStyle(
      color: Colors.white,
    ), // Cor dos labels acima dos inputs
    // Configuração das bordas
    border: OutlineInputBorder(
      // Borda padrão (fallback)
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    enabledBorder: OutlineInputBorder(
      // Borda quando o campo não está em foco
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    focusedBorder: OutlineInputBorder(
      // Borda quando o campo ESTÁ em foco (Dourado Envelhecido)
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Color(0xFFB8860B),
        width: 2.0,
      ), // Cor de destaque
    ),
  ),

  // 6. Tema dos Botões Elevados (ElevatedButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(
        0xFF007BFF,
      ), // Azul Principal como cor padrão do botão
      foregroundColor: Colors.white, // Cor do texto do botão
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Cantos arredondados
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  // 7. Tema de Texto (para cores padrão de Text widgets)
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      color: Colors.white,
      fontSize: 50,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
    ), // Ex: para títulos muito grandes
    headlineMedium: const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ), // Ex: para títulos de seção
    bodyMedium: const TextStyle(
      color: Colors.white,
    ), // Cor padrão para a maioria dos textos
  ),

  // Opcional: Para usar Material 3, adicione esta linha
  useMaterial3: true,
);
