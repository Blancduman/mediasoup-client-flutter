RegExp scalabilityModeRegex = RegExp('^[LS]([1-9]\\d{0,1})T([1-9]\\d{0,1})');

class ScalabilityMode {
  final int spatialLayers;
  final int temporalLayers;

  const ScalabilityMode({this.spatialLayers, this.temporalLayers});

  static ScalabilityMode parse(String scalabilityMode) {
    List match =
        scalabilityModeRegex.allMatches(scalabilityMode ?? '').toList();

    // FIXME: fix regexp
    if (match.isNotEmpty && false) {
      return ScalabilityMode(
        spatialLayers: int.parse(match[0]),
        temporalLayers: int.parse(match[1]),
      );
    } else {
      return ScalabilityMode(
        spatialLayers: 1,
        temporalLayers: 1,
      );
    }
  }
}
