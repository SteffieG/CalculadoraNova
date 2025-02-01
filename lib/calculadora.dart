import 'package:flutter/material.dart';
// ignore: unused_import
import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calculadora(),
    );
  }
}

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String expression = '';
  String result = '';
  List<String> history = [];
  bool _isScrollLockEnabled = true;

  final List<String> buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '0', '.', '=', '+',
    'C', 'sin', 'cos', 'tan', '%', '√',
    'Histórico',
  ];

  void _handleButtonPress(String buttonText) {
    setState(() {
      switch (buttonText) {
        case '=':
          try {
            result = _evaluateExpression(expression).toString();
            history.add('$expression = $result');
            expression = '';
          } catch (e) {
            result = 'Erro';
            expression = '';
          }
          break;
        case 'C':
          expression = '';
          result = '';
          break;
        case 'sin':
          expression = 'sin($expression)';
          break;
        case 'cos':
          expression = 'cos($expression)';
          break;
        case 'tan':
          expression = 'tan($expression)';
          break;
        case '%':
          expression = '$expression/100';
          break;
        case '√':
          expression = 'sqrt($expression)';
          break;
        case 'Histórico':
          _showHistory();
          break;
        default:
          expression += buttonText;
      }
    });
  }

  double _evaluateExpression(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return 0.0;
    }
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(history: history),
      ),
    );
  }

  void _toggleScrollLock() {
    setState(() {
      _isScrollLockEnabled = !_isScrollLockEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Text(
                expression,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Text(
                result,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _toggleScrollLock,
            child: Text(_isScrollLockEnabled ? 'Scroll Lock: ON' : 'Scroll Lock: OFF'),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              physics: _isScrollLockEnabled
                  ? const NeverScrollableScrollPhysics()
                  : const ScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: buttons.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return CalculatorButton(
                  text: buttons[index],
                  onPressed: () {
                    _handleButtonPress(buttons[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<String> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(history[index]),
          );
        },
      ),
    );
  }
}