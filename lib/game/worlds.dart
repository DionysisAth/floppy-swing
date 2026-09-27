import 'dart:ui' show Color;

/// A campaign world: 20 levels built around one mechanic.
class WorldInfo {
  const WorldInfo({
    required this.number,
    required this.name,
    required this.tagline,
    required this.starsNeeded,
    required this.color,
    required this.colorDark,
  });

  final int number;
  final String name;
  final String tagline;

  /// Total stars needed before the world opens.
  final int starsNeeded;

  /// Level select backdrop colours.
  final Color color;
  final Color colorDark;

  static const levelsPerWorld = 20;

  int get firstLevel => (number - 1) * levelsPerWorld + 1;
  int get lastLevel => number * levelsPerWorld;

  static int ofLevel(int id) => id < 1 ? 1 : (id - 1) ~/ levelsPerWorld + 1;

  static WorldInfo byNumber(int n) => worlds[(n - 1).clamp(0, worlds.length - 1)];
}

const worlds = [
  WorldInfo(
    number: 1,
    name: 'Playground',
    tagline: 'Hold. Swing. Let go. Scream.',
    starsNeeded: 0,
    color: Color(0xFF7CC8FF),
    colorDark: Color(0xFF3F9BE0),
  ),
  WorldInfo(
    number: 2,
    name: 'Factory',
    tagline: 'Rings on rails and hungry saws.',
    starsNeeded: 15,
    color: Color(0xFFE39A6B),
    colorDark: Color(0xFF8C5A48),
  ),
  WorldInfo(
    number: 3,
    name: 'Glass City',
    tagline: 'Smash through. Bounce off.',
    starsNeeded: 40,
    color: Color(0xFF6FA9E0),
    colorDark: Color(0xFF2E4E86),
  ),
  WorldInfo(
    number: 4,
    name: 'Sky Islands',
    tagline: 'Ride the wind. Fall upwards.',
    starsNeeded: 70,
    color: Color(0xFFF2A7C3),
    colorDark: Color(0xFF8F6BC7),
  ),
  WorldInfo(
    number: 5,
    name: 'Rocket Base',
    tagline: 'Floors crumble. Rockets fly.',
    starsNeeded: 100,
    color: Color(0xFF7A5C9E),
    colorDark: Color(0xFF221D45),
  ),
];
