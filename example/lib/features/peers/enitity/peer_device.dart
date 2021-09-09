class PeerDevice {
  final String? flag;
  final String? name;
  final String? version;

  const PeerDevice({this.flag, this.name, this.version});

  PeerDevice.fromMap(Map data)
      : flag = data['flag'],
        name = data['name'],
        version = '${data['version']}';
}
