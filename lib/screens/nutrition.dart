import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'habit.dart';

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key});
  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  String category = 'Todas', query = '';
  bool onlySaved = false;

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  @override
  Widget build(BuildContext context) {
    final q = _norm(query.trim());
    final list = guides.where((g) {
      if (category != 'Todas' && g.category != category) return false;
      if (onlySaved && !app.saved.contains(g.id)) return false;
      return q.isEmpty || _norm('${g.title} ${g.intro} ${g.steps.join(' ')}').contains(q);
    }).toList();
    final tip = tips[DateTime.now().difference(DateTime(2026)).inDays % tips.length];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text('Aprende a comer mejor', style: title(32)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Buscar guías y consejos',
                    prefixIcon: Icon(LucideIcons500.search),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  gradient: onlySaved ? G.primary : null,
                  color: onlySaved ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: onlySaved ? S.colored(C.green) : S.soft,
                ),
                child: IconButton(
                  tooltip: onlySaved ? 'Ver todas las guías' : 'Ver solo guardadas',
                  isSelected: onlySaved,
                  onPressed: () => setState(() => onlySaved = !onlySaved),
                  style: IconButton.styleFrom(
                    fixedSize: const Size(54, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(
                    onlySaved ? LucideIcons500.bookmarkCheck : LucideIcons500.bookmark,
                    color: onlySaved ? Colors.white : C.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final c in guideCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: category == c ? Colors.white : C.body,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (category == 'Todas' && !onlySaved && q.isEmpty) ...[
            const SizedBox(height: 16),
            FeaturedGuide(guides.first),
          ],
          SectionTitle(
            onlySaved ? 'Guías guardadas' : 'Todas las guías',
            action: '${list.length} ${list.length == 1 ? 'guía' : 'guías'}',
          ),
          if (list.isEmpty)
            Panel(
              child: Column(
                children: [
                  const IconTile(LucideIcons500.search, C.muted, size: 52),
                  const SizedBox(height: 10),
                  Text(
                    onlySaved ? 'Aún no guardas guías' : 'No encontramos guías con esa búsqueda',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    onlySaved ? 'Toca el marcador dentro de una guía para guardarla' : 'Prueba con otra palabra',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: C.muted),
                  ),
                ],
              ),
            )
          else
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .86,
              children: [for (final g in list) GuideCard(g)],
            ),
          const SectionTitle('Herramientas'),
          Callout(tip, note: Note.tip, icon: LucideIcons500.lightbulb, heading: 'Consejo del día'),
          const SizedBox(height: 12),
          _tool(
            context,
            LucideIcons500.heart,
            C.orange,
            '¿Tienes un antojo?',
            'Registra cómo te sientes y obtén apoyo',
            () => push(context, const CravingsScreen()),
          ),
          const SizedBox(height: 12),
          _tool(
            context,
            LucideIcons500.pencilLine,
            const Color(0xFFD9620F),
            'Registra lo que comes',
            'Anota desayuno, almuerzo y cena',
            () => push(context, HabitScreen('registro', today())),
          ),
        ],
      ),
    );
  }

  Widget _tool(BuildContext context, IconData icon, Color color, String head, String sub, VoidCallback onTap) => Panel(
    onTap: onTap,
    child: Row(
      children: [
        IconTile(icon, color, filled: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(head, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(sub, style: const TextStyle(color: C.muted, fontSize: 14)),
            ],
          ),
        ),
        const Icon(LucideIcons500.chevronRight, color: C.muted),
      ],
    ),
  );
}

class GuideCard extends StatelessWidget {
  final Guide g;
  const GuideCard(this.g, {super.key});
  @override
  Widget build(BuildContext context) => Panel(
    padding: EdgeInsets.zero,
    onTap: () => push(context, GuideScreen(g)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Image.asset('assets/images/${g.image}.jpg', fit: BoxFit.cover, width: double.infinity),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                g.short,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons500.clock, size: 14, color: C.muted),
                  const SizedBox(width: 4),
                  Text('${g.minutes} min', style: const TextStyle(color: C.muted, fontSize: 13.5)),
                  if (app.saved.contains(g.id)) ...[
                    const Spacer(),
                    const Icon(LucideIcons500.bookmarkCheck, size: 16, color: C.green),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class GuideScreen extends StatelessWidget {
  final Guide g;
  const GuideScreen(this.g, {super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final saved = app.saved.contains(g.id);
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: C.bg,
                    leadingWidth: 64,
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Center(child: BackBtn()),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: RoundBtn(
                          saved ? LucideIcons500.bookmarkCheck : LucideIcons500.bookmark,
                          tooltip: saved ? 'Quitar de guardadas' : 'Guardar guía',
                          color: saved ? C.green : C.ink,
                          onPressed: () {
                            app.toggleSaved(g.id);
                            toast(saved ? 'Guía quitada de guardadas' : 'Guía guardada');
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset('assets/images/${g.image}.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    sliver: SliverList.list(
                      children: [
                        Row(
                          children: [
                            Pill('${g.minutes} min de lectura', icon: LucideIcons500.clock, color: C.muted),
                            const SizedBox(width: 8),
                            Pill(g.level),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(g.title, style: title(32)),
                        const SizedBox(height: 12),
                        Text(g.intro, style: const TextStyle(fontSize: 17.5, height: 1.5)),
                        if (g.visualTitle != null) ...[
                          SectionTitle(g.visualTitle!),
                          Panel(child: g.parts.first.share > 0 ? _bar() : _tiles()),
                        ],
                        const SectionTitle('Qué puedes hacer'),
                        Panel(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          child: Column(
                            children: [
                              for (final (i, s) in g.steps.indexed)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: G.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: S.colored(C.green),
                                        ),
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(s, style: const TextStyle(fontSize: 16, height: 1.45))),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Callout(
                          g.note,
                          note: Note.warn,
                          icon: LucideIcons500.lightbulb,
                          heading: 'Para tener en cuenta',
                        ),
                        const SectionTitle('Más guías'),
                        SizedBox(
                          height: 190,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            children: [
                              for (final o in guides.where((o) => o.id != g.id))
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: SizedBox(width: 200, child: GuideCard(o)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BottomAction(
              Btn(
                'Ir a mi plan',
                icon: LucideIcons500.arrowRight,
                onPressed: () async {
                  app.setTab(1);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _bar() => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            for (final p in g.parts)
              Expanded(
                flex: p.share.round(),
                child: Container(height: 22, color: p.color),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      for (final p in g.parts)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(p.label, style: const TextStyle(fontSize: 15.5))),
              Text(
                p.value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: tabular),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _tiles() => GridView.count(
    padding: EdgeInsets.zero,
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1.7,
    children: [
      for (final p in g.parts)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: soft(p.color), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                p.label,
                style: TextStyle(fontWeight: FontWeight.w700, color: p.color, fontSize: 15.5),
              ),
              const SizedBox(height: 2),
              Text(p.value, style: const TextStyle(fontSize: 14, height: 1.3)),
            ],
          ),
        ),
    ],
  );
}

// ---------- Antojos ----------

class CravingsScreen extends StatefulWidget {
  const CravingsScreen({super.key});
  @override
  State<CravingsScreen> createState() => _CravingsScreenState();
}

class _CravingsScreenState extends State<CravingsScreen> {
  Emotion? picked;
  final tried = <String>{};

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Header('¿Tienes un antojo?', sub: 'Identifica lo que sientes, aquí no hay respuestas malas'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Qué sientes ahora mismo?',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.05,
                          children: [for (final e in emotions) _emotion(e)],
                        ),
                        if (picked != null) ...[
                          const SizedBox(height: 20),
                          Callout(
                            'Marca lo que intentaste, cuenta aunque sea una sola',
                            note: Note.warn,
                            icon: LucideIcons500.sparkles,
                            heading: 'Prueba esto antes de ceder',
                            child: Column(children: [for (final idea in picked!.ideas) _idea(idea)]),
                          ),
                        ],
                        SectionTitle(
                          'Tu historial',
                          action: app.cravings.isEmpty
                              ? null
                              : '${app.cravings.length} ${app.cravings.length == 1 ? 'registro' : 'registros'}',
                        ),
                        if (app.cravings.isEmpty)
                          const Text(
                            'Aún no tienes momentos registrados, cuando sientas un antojo vuelve aquí sin juicios',
                            style: TextStyle(color: C.muted, fontSize: 15.5, height: 1.4),
                          )
                        else
                          for (final c in app.cravings.take(20)) cravingTile(c),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (picked != null)
              BottomAction(
                Btn(
                  'Registrar momento',
                  icon: LucideIcons500.check,
                  onPressed: () async {
                    app.addCraving(picked!.id, tried.toList());
                    setState(() {
                      picked = null;
                      tried.clear();
                    });
                    toast('Momento registrado, bien hecho por detenerte a mirarlo');
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _emotion(Emotion e) {
    final on = picked == e;
    return Semantics(
      container: true,
      button: true,
      selected: on,
      label: e.id,
      child: GestureDetector(
        onTap: () => setState(() {
          picked = e;
          tried.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: on ? soft(e.color) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: on ? e.color : C.line, width: on ? 2 : 1),
            boxShadow: on ? S.colored(e.color) : S.soft,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: on ? G.of(e.color) : null,
                  color: on ? null : soft(e.color),
                  shape: BoxShape.circle,
                ),
                child: Icon(e.icon, color: on ? Colors.white : e.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                e.id,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: on ? e.color : C.body),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _idea(String idea) {
    final on = tried.contains(idea);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => on ? tried.remove(idea) : tried.add(idea)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(idea, style: const TextStyle(fontSize: 15, height: 1.35, color: C.body)),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? C.amber : Colors.white,
                    border: on ? null : Border.all(color: const Color(0xFFD1D5DB), width: 2),
                  ),
                  child: on ? const Icon(LucideIcons500.check, color: Colors.white, size: 16) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Guía grande con foto, como el destacado del Figma
class FeaturedGuide extends StatelessWidget {
  final Guide g;
  const FeaturedGuide(this.g, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 200,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: S.raised),
    child: Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => push(context, GuideScreen(g)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/${g.image}.jpg', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [.35, 1],
                  colors: [Color(0x00000000), Color(0xCC0B1A12)],
                ),
              ),
            ),
            const Positioned(
              left: 14,
              top: 14,
              child: Pill('Destacado', icon: LucideIcons500.flame, color: C.green, background: Colors.white),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.title, style: title(26, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${g.minutes} min de lectura, ${g.level.toLowerCase()}',
                    style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String whenText(DateTime t) {
  final d = DateTime(t.year, t.month, t.day);
  final hour = clock(t.hour, t.minute);
  if (d == today()) return 'Hoy, $hour';
  if (d == today().subtract(const Duration(days: 1))) return 'Ayer, $hour';
  return '${DateFormat("d 'de' MMM", 'es').format(t).replaceAll('.', '')}, $hour';
}

Widget cravingTile(Craving c) {
  final e = emotionById(c.emotion);
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(e.icon, e.color, size: 42, filled: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                Text(
                  c.tried.isEmpty
                      ? 'Lo registraste'
                      : 'Probaste ${c.tried.length} ${c.tried.length == 1 ? 'idea' : 'ideas'}',
                  style: const TextStyle(color: C.muted, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(whenText(c.at), style: const TextStyle(color: C.muted, fontSize: 13)),
        ],
      ),
    ),
  );
}
