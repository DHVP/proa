import 'package:flutter_test/flutter_test.dart';
import 'package:proa/data.dart';

void main() {
  test('puntaje va de 0 a 100', () {
    expect(totalScore(List.filled(8, 0)), 0);
    expect(totalScore([3, 3, 3, 3, 2, 3, 3, 3]), 100);
  });

  test('dos personas con respuestas distintas reciben planes distintos', () {
    // A: sedentaria con mucha gaseosa, B: activa pero duerme poco y con estrés
    final a = personalPlan([0, 0, 2, 3, 2, 1, 3, 3], 'alimentacion');
    final b = personalPlan([3, 3, 3, 0, 0, 3, 3, 3], 'dormir');
    expect(a.length, 5);
    expect(b.length, 5);
    expect(a, containsAll(['actividad', 'azucar']));
    expect(b, containsAll(['sueno', 'respirar']));
    expect(a, isNot(equals(b)));
  });

  test('las metas arrancan donde está la persona', () {
    expect(targetFor('agua', 'sedentario', [0, 0, 0, 0, 0, 0, 0, 0]), 5);
    expect(targetFor('agua', 'sedentario', [0, 0, 0, 0, 0, 0, 3, 0]), 8);
    expect(goalFor('actividad', 1, 'sedentario'), 'Caminar 15 minutos');
  });
}
