
class ScenarioEffect {
  final int money;
  final int army;
  final int people;
  final int religion;

  const ScenarioEffect({
    this.money = 0,
    this.army = 0,
    this.people = 0,
    this.religion = 0,
  });
}

class Choice {
  final String text;
  final ScenarioEffect effect;

  const Choice({
    required this.text,
    required this.effect,
  });
}

class Scenario {
  final String id;
  final String text;
  final String? imagePath;
  final Choice leftChoice;
  final Choice rightChoice;

  const Scenario({
    required this.id,
    required this.text,
    this.imagePath,
    required this.leftChoice,
    required this.rightChoice,
  });
}
