import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

// ---------- Perfil ----------

const sexes = {'F': 'Femenino', 'M': 'Masculino', 'N': 'Prefiero no decir'};

class Option {
  final String id, label, hint;
  final IconData icon;
  const Option(this.id, this.label, this.hint, this.icon);
}

const activities = [
  Option('sedentario', 'Sedentario', 'Poco o nada de ejercicio', LucideIcons500.sofa),
  Option('ligero', 'Ligero', '1 a 2 días por semana', LucideIcons500.bike),
  Option('moderado', 'Moderado', '3 a 4 días por semana', LucideIcons500.activity),
  Option('activo', 'Activo', '5 días o más', LucideIcons500.dumbbell),
];

const goals = [
  Option('alimentacion', 'Mejorar mi alimentación', 'mejor alimentación', LucideIcons500.utensils),
  Option('moverme', 'Moverme más', 'moverme más', LucideIcons500.footprints),
  Option('rutina', 'Crear una rutina saludable', 'rutina saludable', LucideIcons500.sprout),
  Option('dormir', 'Dormir y descansar mejor', 'descansar mejor', LucideIcons500.moon),
];

Option optionById(List<Option> list, String? id) => list.firstWhere((o) => o.id == id, orElse: () => list.first);

// ---------- Test ----------

class Question {
  final String area, text;
  final String? examples;
  final IconData icon;
  final List<String> options;
  final List<int> points; // puntos por opción, 0 a 3
  const Question(this.area, this.icon, this.text, this.options, this.points, {this.examples});
}

const questions = [
  Question(
    'Actividad física',
    LucideIcons500.activity,
    '¿Con qué frecuencia haces actividad física?',
    ['Nunca', '1 a 2 días por semana', '3 a 4 días por semana', 'Todos los días'],
    [0, 1, 2, 3],
    examples: 'Cuenta caminar rápido, montar bicicleta, bailar, hacer deporte o ir al gimnasio',
  ),
  Question(
    'Bebidas',
    LucideIcons500.cupSoda,
    '¿Con qué frecuencia tomas bebidas azucaradas?',
    ['Todos los días', 'Varios días por semana', '1 a 2 veces por semana', 'Casi nunca'],
    [0, 1, 2, 3],
    examples:
        'Por ejemplo gaseosa, jugos de caja o de botella, té frío embotellado, bebidas energizantes, '
        'refrescos en polvo o tinto y aromática con mucha azúcar',
  ),
  Question(
    'Alimentación',
    LucideIcons500.carrot,
    '¿Cuántos días a la semana comes frutas y verduras?',
    ['0 a 1 días', '2 a 3 días', '4 a 5 días', 'Todos los días'],
    [0, 1, 2, 3],
  ),
  Question(
    'Emociones',
    LucideIcons500.brain,
    '¿Con qué frecuencia comes por ansiedad o estrés?',
    ['Todos los días', 'Varios días por semana', 'Rara vez', 'Nunca'],
    [0, 1, 2, 3],
  ),
  Question(
    'Sueño',
    LucideIcons500.moon,
    '¿Cuántas horas duermes normalmente?',
    ['Menos de 5 horas', '5 a 6 horas', '7 a 8 horas', 'Más de 8 horas'],
    [0, 1, 3, 2],
  ),
  Question(
    'Alimentación',
    LucideIcons500.cookie,
    '¿Con qué frecuencia comes alimentos ultraprocesados?',
    ['Todos los días', 'Varios días por semana', '1 a 2 veces por semana', 'Casi nunca'],
    [0, 1, 2, 3],
    examples:
        'Por ejemplo papas o chitos de paquete, galletas y ponqués empacados, salchichas, salchichón o jamón, '
        'nuggets, sopas instantáneas, cereales azucarados o comidas rápidas',
  ),
  Question(
    'Hidratación',
    LucideIcons500.droplet,
    '¿Cuántos vasos de agua tomas al día?',
    ['0 a 2 vasos', '3 a 4 vasos', '5 a 6 vasos', '7 vasos o más'],
    [0, 1, 2, 3],
  ),
  Question(
    'Rutina',
    LucideIcons500.sunrise,
    '¿Con qué frecuencia te saltas el desayuno?',
    ['Todos los días', 'Varios días por semana', 'Rara vez', 'Nunca lo salto'],
    [0, 1, 2, 3],
  ),
];

int points(List<int> answers, int q) => questions[q].points[answers[q]];

int totalScore(List<int> a) {
  var sum = 0;
  for (var i = 0; i < questions.length; i++) {
    sum += points(a, i);
  }
  return (sum * 100 / (questions.length * 3)).round();
}

const areas = {
  'Actividad física': [0],
  'Alimentación': [1, 2, 5, 6, 7],
  'Sueño y descanso': [4],
  'Manejo del estrés': [3],
};

int areaScore(List<int> a, List<int> qs) =>
    (qs.fold<int>(0, (s, q) => s + points(a, q)) * 100 / (qs.length * 3)).round();

(String, String) resultText(int score) {
  if (score >= 75) return ('Vas por buen camino', 'Tienes una base sólida y tu plan te ayuda a mantenerla');
  if (score >= 50) return ('Tienes una buena base', 'Hay rutinas que puedes fortalecer y tu plan empieza por ahí');
  return ('Hábitos que necesitan atención', 'Hay varias rutinas por cambiar, empieza por una sola y a tu ritmo');
}

// ---------- Hábitos ----------

enum Kind { check, count, meals }

class HabitDef {
  final String id, title, image, description, tip, advice, time;
  final IconData icon;
  final Color color;
  final Kind kind;
  final int question; // pregunta del test que lo mide, -1 si ninguna
  const HabitDef({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.image,
    required this.kind,
    required this.question,
    required this.time,
    required this.description,
    required this.tip,
    required this.advice,
  });
}

const meals = ['Desayuno', 'Almuerzo', 'Cena'];

const habits = [
  HabitDef(
    id: 'agua',
    title: 'Tomar agua',
    icon: LucideIcons500.droplet,
    color: Color(0xFF0E8FB0),
    image: 'hidratacion',
    kind: Kind.count,
    question: 6,
    time: '1 min',
    description: 'Mantenerte hidratado regula el metabolismo, te da energía y te ayuda a controlar el apetito',
    tip: 'Lleva una botella contigo y rellénala durante el día',
    advice: 'Sube poco a poco hasta 8 vasos de agua al día',
  ),
  HabitDef(
    id: 'actividad',
    title: 'Actividad física',
    icon: LucideIcons500.activity,
    color: Color(0xFF167A3E),
    image: 'actividad_fisica',
    kind: Kind.check,
    question: 0,
    time: '30 min',
    description: 'Moverte a diario mejora tu ánimo, tu sueño y tu corazón, y caminar ya cuenta',
    tip: 'Usa las escaleras y bájate del bus una parada antes',
    advice: 'Muévete al menos 30 minutos al día, caminar cuenta',
  ),
  HabitDef(
    id: 'frutas',
    title: 'Frutas y verduras',
    icon: LucideIcons500.carrot,
    color: Color(0xFF5E8F12),
    image: 'frutas_y_verduras',
    kind: Kind.count,
    question: 2,
    time: '5 min',
    description: 'Las frutas y verduras te dan vitaminas, minerales y fibra para tener energía todo el día',
    tip: 'Deja la fruta lavada y a la vista para tenerla a mano',
    advice: 'Incluye frutas y verduras en cada comida hasta llegar a 5 porciones',
  ),
  HabitDef(
    id: 'azucar',
    title: 'Menos bebidas azucaradas',
    icon: LucideIcons500.cupSoda,
    color: Color(0xFFC2416B),
    image: 'hidratacion',
    kind: Kind.check,
    question: 1,
    time: '1 min',
    description:
        'Las bebidas azucaradas suman mucha azúcar sin que lo notes, una gaseosa personal puede tener más de 8 cucharaditas',
    tip: 'Prueba agua con limón y hierbabuena o una aromática fría sin azúcar',
    advice: 'Cambia gaseosas y jugos de caja por agua o aromática sin azúcar',
  ),
  HabitDef(
    id: 'ultra',
    title: 'Menos ultraprocesados',
    icon: LucideIcons500.cookie,
    color: Color(0xFFB7791F),
    image: 'ultraprocesados',
    kind: Kind.check,
    question: 5,
    time: '1 día',
    description:
        'Comer menos paquetes, embutidos y comida rápida baja la sal, el azúcar y la grasa que consumes sin darte cuenta',
    tip: 'Ten a mano maní, fruta o huevo cocido para los antojos',
    advice: 'Reduce paquetes, embutidos y comida rápida',
  ),
  HabitDef(
    id: 'desayuno',
    title: 'Desayunar',
    icon: LucideIcons500.sunrise,
    color: Color(0xFFC9850C),
    image: 'bowl_saludable',
    kind: Kind.check,
    question: 7,
    time: '15 min',
    description: 'Desayunar te da energía para la mañana y evita que llegues con mucha hambre al almuerzo',
    tip: 'Algo sencillo sirve, como huevo con arepa y una fruta',
    advice: 'Desayuna todos los días antes de salir',
  ),
  HabitDef(
    id: 'registro',
    title: 'Registrar alimentación',
    icon: LucideIcons500.pencilLine,
    color: Color(0xFFD9620F),
    image: 'registro_de_comidas',
    kind: Kind.meals,
    question: -1,
    time: '2 min',
    description: 'Anotar lo que comes te ayuda a ver tus patrones y a decidir con más calma durante el día',
    tip: 'Anota justo después de cada comida para no olvidarlo',
    advice: 'Anota tus comidas para descubrir tus patrones',
  ),
  HabitDef(
    id: 'respirar',
    title: 'Pausa para respirar',
    icon: LucideIcons500.wind,
    color: Color(0xFF7A4FC4),
    image: 'calma',
    kind: Kind.check,
    question: 3,
    time: '5 min',
    description: 'Una pausa corta baja el estrés y te ayuda a no comer por ansiedad',
    tip: 'Inhala 4 segundos, sostén 4 y exhala 6, repite cinco veces',
    advice: 'Haz una pausa para respirar cuando sientas ansiedad',
  ),
  HabitDef(
    id: 'sueno',
    title: 'Dormir bien',
    icon: LucideIcons500.moon,
    color: Color(0xFF4F5BD5),
    image: 'dormir_bien',
    kind: Kind.check,
    question: 4,
    time: '8 h',
    description:
        'Dormir bien regula las hormonas del apetito, te da energía y ayuda a que tu cuerpo y tu mente se recuperen',
    tip: 'Deja las pantallas 30 minutos antes de acostarte',
    advice: 'Busca dormir entre 7 y 8 horas cada noche',
  ),
];

HabitDef habitById(String id) => habits.firstWhere((h) => h.id == id);

const shortNames = {
  'agua': 'Agua',
  'actividad': 'Actividad',
  'frutas': 'Frutas',
  'azucar': 'Azúcar',
  'ultra': 'Paquetes',
  'desayuno': 'Desayuno',
  'registro': 'Comidas',
  'respirar': 'Respirar',
  'sueno': 'Sueño',
};

int activityMinutes(String activity) =>
    const {'sedentario': 15, 'ligero': 20, 'moderado': 30, 'activo': 45}[activity] ?? 30;

/// Meta del día según el perfil y el test: el plan arranca donde está cada persona
int targetFor(String id, String activity, List<int>? answers) {
  final a = answers;
  switch (id) {
    case 'agua':
      return a == null ? 8 : const [5, 6, 8, 8][a[6]];
    case 'frutas':
      return a == null ? 5 : const [3, 4, 5, 5][a[2]];
    case 'registro':
      return 3;
    default:
      return 1;
  }
}

String goalFor(String id, int target, String activity) {
  final min = activityMinutes(activity);
  return switch (id) {
    'agua' => '$target vasos al día',
    'frutas' => '$target porciones al día',
    'actividad' =>
      min >= 45
          ? 'Entrenar $min minutos'
          : min >= 30
          ? 'Moverte $min minutos'
          : 'Caminar $min minutos',
    'azucar' => 'Agua en vez de gaseosa o jugo',
    'ultra' => 'Un día sin paquetes ni embutidos',
    'desayuno' => 'Antes de las 10 de la mañana',
    'registro' => 'Anotar mis 3 comidas',
    'respirar' => '5 minutos lejos de la pantalla',
    'sueno' => '7 a 8 horas de sueño',
    _ => '',
  };
}

String timeFor(HabitDef h, String activity) => h.id == 'actividad' ? '${activityMinutes(activity)} min' : h.time;

/// Elige 5 hábitos: primero los que el test marca como más débiles, luego el objetivo de la persona
List<String> personalPlan(List<int> answers, String goal) {
  const boost = {
    'alimentacion': {'frutas': .6, 'registro': .6, 'ultra': .6, 'azucar': .6},
    'moverme': {'actividad': 1.5},
    'rutina': {'desayuno': .6, 'agua': .6, 'registro': .6},
    'dormir': {'sueno': 1.5, 'respirar': .6},
  };
  double need(HabitDef h) =>
      (h.question < 0 ? 1.2 : 3 - points(answers, h.question).toDouble()) + (boost[goal]?[h.id] ?? 0);
  final ranked = [...habits]..sort((a, b) => need(b).compareTo(need(a)));
  final chosen = ranked.take(5).map((h) => h.id).toSet();
  return [
    for (final h in habits)
      if (chosen.contains(h.id)) h.id,
  ];
}

// ---------- Guías ----------

class Part {
  final String label, value;
  final Color color;
  final double share;
  const Part(this.label, this.value, this.color, [this.share = 0]);
}

class Guide {
  final String id, title, short, level, category, image, intro, note;
  final int minutes;
  final String? visualTitle;
  final List<Part> parts; // con share > 0 se dibuja como barra, si no como mosaico
  final List<String> steps;
  const Guide({
    required this.id,
    required this.title,
    required this.short,
    required this.minutes,
    required this.level,
    required this.category,
    required this.image,
    required this.intro,
    required this.steps,
    required this.note,
    this.visualTitle,
    this.parts = const [],
  });
}

const guideCategories = ['Todas', 'Comidas', 'Porciones', 'Hidratación', 'Antojos'];

const guides = [
  Guide(
    id: 'plato',
    title: 'El plato equilibrado',
    short: 'Plato equilibrado',
    minutes: 4,
    level: 'Básico',
    category: 'Comidas',
    image: 'plato_equilibrado',
    intro:
        'Imagina tu plato dividido en cuatro partes, la mitad para verduras y frutas de colores, un cuarto para carbohidratos y otro cuarto para proteínas',
    visualTitle: 'Así se ve tu plato',
    parts: [
      Part('Verduras y frutas', '50 %', Color(0xFF2E9D57), 50),
      Part('Carbohidratos', '25 %', Color(0xFFE0A526), 25),
      Part('Proteínas', '25 %', Color(0xFFD9620F), 25),
    ],
    steps: [
      'Llena la mitad del plato con verduras y frutas de distintos colores',
      'Suma un carbohidrato como arroz integral, papa, yuca o arepa de maíz',
      'Agrega proteína en cada comida, como huevo, pollo, pescado o fríjoles',
      'Cocina con poco aceite vegetal',
    ],
    note: 'No necesitas dietas estrictas, el equilibrio en las proporciones es lo que hace la diferencia',
  ),
  Guide(
    id: 'porciones',
    title: 'Porciones adecuadas',
    short: 'Porciones',
    minutes: 3,
    level: 'Básico',
    category: 'Porciones',
    image: 'porciones',
    intro:
        'Tu mano es la mejor medida para servir porciones sin básculas ni complicaciones y siempre la llevas contigo',
    visualTitle: 'Mide con tu mano',
    parts: [
      Part('Puño', 'Carbohidratos', Color(0xFFE0A526)),
      Part('Palma', 'Proteínas', Color(0xFFD9620F)),
      Part('Pulgar', 'Grasas', Color(0xFF8A6D3B)),
      Part('Dos manos', 'Verduras', Color(0xFF2E9D57)),
    ],
    steps: [
      'Carbohidratos del tamaño de tu puño cerrado',
      'Proteínas del tamaño de la palma de tu mano',
      'Grasas saludables del tamaño de tu pulgar',
      'Verduras y ensaladas, lo que quepa en tus dos manos juntas',
    ],
    note: 'Come despacio, la sensación de llenura tarda unos 20 minutos en llegar',
  ),
  Guide(
    id: 'frutas',
    title: 'Frutas y verduras',
    short: 'Frutas y verduras',
    minutes: 3,
    level: 'Básico',
    category: 'Comidas',
    image: 'frutas_y_verduras',
    intro:
        'Cinco porciones al día de frutas y verduras variadas te dan vitaminas, fibra y minerales que protegen tu salud',
    visualTitle: 'Una porción de cada color',
    parts: [
      Part('Rojo', '', Color(0xFFD6453D), 20),
      Part('Naranja', '', Color(0xFFEA8A2E), 20),
      Part('Amarillo', '', Color(0xFFE9C13B), 20),
      Part('Verde', '', Color(0xFF3E9B4F), 20),
      Part('Morado', '', Color(0xFF7B4BA8), 20),
    ],
    steps: [
      'Varía los colores porque cada uno aporta nutrientes distintos',
      'Come fruta en el desayuno y verdura en el almuerzo y la cena',
      'Prefiere la fruta entera al jugo porque conserva la fibra',
      'Las verduras congeladas sin sal también cuentan',
    ],
    note: 'No hay frutas ni verduras malas, lo que cuenta es la variedad y la frecuencia',
  ),
  Guide(
    id: 'proteinas',
    title: 'Proteínas saludables',
    short: 'Proteínas',
    minutes: 4,
    level: 'Intermedio',
    category: 'Comidas',
    image: 'proteinas',
    intro:
        'Las proteínas construyen y reparan tus tejidos y no solo vienen de la carne, también hay muchas fuentes vegetales',
    steps: [
      'Fríjoles, lentejas y garbanzos son económicos y muy nutritivos',
      'El huevo es una proteína completa y fácil de preparar',
      'Prefiere pollo y pescado antes que carnes rojas',
      'Los lácteos bajos en grasa también aportan proteína de calidad',
    ],
    note: 'Con una alimentación variada cubres la proteína que necesitas',
  ),
  Guide(
    id: 'hidratacion',
    title: 'Hidratación',
    short: 'Hidratación',
    minutes: 2,
    level: 'Básico',
    category: 'Hidratación',
    image: 'hidratacion',
    intro:
        'Tu cuerpo es en buena parte agua y estar bien hidratado mejora la concentración, la energía y el control del apetito',
    visualTitle: 'Tu cuerpo es 60 % agua',
    parts: [Part('Agua', '60 %', Color(0xFF0E8FB0), 60), Part('Otros componentes', '40 %', Color(0xFFC9D8CE), 40)],
    steps: [
      'Toma unos 8 vasos de agua al día, cerca de 2 litros',
      'Bebe agua antes, durante y después del ejercicio',
      'Come frutas y verduras con mucha agua como sandía, pepino o naranja',
      'Cambia gaseosas, jugos de caja y bebidas energizantes por agua o aromática sin azúcar',
    ],
    note: 'Si tu orina es amarillo oscuro es señal de que necesitas más agua',
  ),
  Guide(
    id: 'ultra',
    title: 'Alimentos ultraprocesados',
    short: 'Ultraprocesados',
    minutes: 5,
    level: 'Intermedio',
    category: 'Antojos',
    image: 'ultraprocesados',
    intro:
        'Son productos industriales con mucha azúcar, sal y grasa añadidas, y comerlos seguido afecta tu salud con el tiempo',
    visualTitle: 'Ejemplos comunes',
    parts: [
      Part('Paquetes', 'Papas, chitos y galletas', Color(0xFFB7791F)),
      Part('Embutidos', 'Salchicha, salchichón y jamón', Color(0xFFC2416B)),
      Part('Bebidas', 'Gaseosa, jugos de caja y energizantes', Color(0xFF0E8FB0)),
      Part('Para calentar', 'Nuggets y sopas instantáneas', Color(0xFF7A4FC4)),
    ],
    steps: [
      'Lee la etiqueta, una lista larga de ingredientes suele indicar ultraprocesado',
      'Limita paquetes, gaseosas, embutidos y comidas rápidas',
      'Cocinar en casa te da control sobre lo que comes',
      'Si los comes, que sea de vez en cuando y en porción pequeña',
    ],
    note: 'No se trata de prohibirlos para siempre sino de comerlos con menos frecuencia',
  ),
];

Guide guideById(String id) => guides.firstWhere((g) => g.id == id);

const tips = [
  'Lee las etiquetas, si el azúcar aparece entre los primeros ingredientes es mejor comerlo de vez en cuando',
  'Sirve tu comida en un plato más pequeño y comerás porciones adecuadas sin sentir que te privas',
  'Deja la fruta picada desde la noche anterior y tendrás el desayuno listo',
  'Antes de picar algo toma un vaso de agua y espera unos minutos, a veces la sed parece hambre',
  'Cambia la gaseosa del almuerzo por agua con limón o una aromática fría sin azúcar',
  'Cocinar en casa te deja controlar la sal, el azúcar y el aceite de tus comidas',
];

// ---------- Antojos ----------

class Emotion {
  final String id;
  final IconData icon;
  final Color color;
  final List<String> ideas;
  const Emotion(this.id, this.icon, this.color, this.ideas);
}

const emotions = [
  Emotion('Ansiedad', LucideIcons500.zap, Color(0xFFD9620F), [
    'Respira profundo, inhala 4 segundos y exhala 4',
    'Toma un vaso de agua despacio',
    'Sal a caminar 5 minutos',
    'Escribe qué te preocupa en este momento',
  ]),
  Emotion('Estrés', LucideIcons500.cloudRain, Color(0xFF4F5BD5), [
    'Haz 5 respiraciones lentas antes de comer',
    'Estira el cuerpo durante 2 minutos',
    'Escucha una canción que te relaje',
    'Habla con alguien de confianza',
  ]),
  Emotion('Hambre', LucideIcons500.utensils, Color(0xFF167A3E), [
    'Elige una fruta o un puñado de maní',
    'Revisa cuánto falta para tu próxima comida',
    'Acompaña con un vaso de agua',
    'Sirve una porción en un plato y no comas del paquete',
  ]),
  Emotion('Aburrimiento', LucideIcons500.meh, Color(0xFF7A4FC4), [
    'Distráete con una actividad corta',
    'Da una vuelta a la manzana',
    'Lee una guía de PROA de 2 minutos',
    'Prepárate una aromática sin azúcar',
  ]),
  Emotion('Antojo', LucideIcons500.candy, Color(0xFFC2416B), [
    'Espera 15 minutos antes de ceder',
    'Toma un vaso de agua primero',
    'Distráete con una actividad corta',
    'Si sigue, elige una porción pequeña o una fruta',
  ]),
];

Emotion emotionById(String id) => emotions.firstWhere((e) => e.id == id, orElse: () => emotions.first);
