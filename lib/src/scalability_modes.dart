RegExp scalabilityModeRegex = RegExp('^[LS]([1-9]\\d{0,1})T([1-9]\\d{0,1})');

class ScalabilityMode {
  final int spatialLayers;
  final int temporalLayers;

  const ScalabilityMode({
    required this.spatialLayers,
    required this.temporalLayers,
  });

  static ScalabilityMode parse(String? scalabilityMode) {
    List<RegExpMatch> match =
        scalabilityModeRegex.allMatches(scalabilityMode ?? '').toList();

    if (match.isNotEmpty) {
      return ScalabilityMode(
        spatialLayers: int.parse(match[0].group(1)!),
        temporalLayers: int.parse(match[0].group(2)!),
      );
    } else {
      return ScalabilityMode(
        spatialLayers: 1,
        temporalLayers: 1,
      );
    }
  }
}
