import 'dart:io';
import '../lib/SdpTransform/SdpTransform.dart';
import "package:test/test.dart";

main() {
  test("NormalSdp", _testNormalSdp);
  test("HackySdp", _testHackySdp);
  test("IceliteSdp", _testIceliteSdp);
  test("InvalidSdp", _testInvalidSdp);
  test("JssipSdp", _testJssipSdp);
  test("JsepSdp", _testJsepSdp);
  test("AlacSdp", _testAlacSdp);
  test("SsrcSdp", _testSsrcSdp);
  test("SimulcastSdp", _testSimulcastSdp);
  test("St2202_6Sdp", _testSt2202_6Sdp);
  test("St2110_20Sdp", _testSt2110_20Sdp);
  test("SctpDtls26Sdp", _testSctpDtls26Sdp);
  test("ExtmapEncryptSdp", _testExtmapEncryptSdp);
  test("DanteAes67", _testDanteAes67);
  test("TcpActive", _testTcpActive);
  test("TcpPassive", _testTcpPassive);
  test("asterisk", _testAsterisk);
}

void ok(dynamic test, String message) {
  if (test != null) {
    print(message);
  } else {
    assert(false);
  }
}

void equal(dynamic value, dynamic match, String message) {
  if (value != match) {
    print(message);
    assert(false, message);
  }
}

deepEqual(dynamic value, dynamic match, String message) {}

_testAsterisk() async {
  String sdp =
      await new File('./test/sdp_test_data/asterisk.sdp').readAsString();
  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
}

_testNormalSdp() async {
  String sdp =
      await new File('./test/sdp_test_data/normal.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  equal(session['origin']['username'], '-', 'origin username');
  equal(session['origin']['sessionId'], 20518, 'origin sessionId');
  equal(session['origin']['sessionVersion'], 0, 'origin sessionVersion');
  equal(session['origin']['netType'], 'IN', 'origin netType');
  equal(session['origin']['ipVer'], 4, 'origin ipVer');
  equal(session['origin']['address'], '203.0.113.1', 'origin address');

  equal(session['connection']['ip'], '203.0.113.1', 'session connect ip');
  equal(session['connection']['version'], 4, 'session connect ip ver');

  // global ICE and fingerprint
  equal(session['iceUfrag'], 'F7gI', 'global ufrag');
  equal(session['icePwd'], 'x9cml/YzichV2+XlhiMu8g', 'global pwd');

  dynamic audio = media[0];
  equal(audio['type'], 'audio', 'audio type');
  equal(audio['port'], 54400, 'audio port');
  equal(audio['protocol'], 'RTP/SAVPF', 'audio protocol');
  equal(audio['direction'], 'sendrecv', 'audio direction');
  equal(audio['rtp'][0]['payload'], 0, 'audio rtp 0 payload');
  equal(audio['rtp'][0]['codec'], 'PCMU', 'audio rtp 0 codec');
  equal(audio['rtp'][0]['rate'], 8000, 'audio rtp 0 rate');
  equal(audio['rtp'][1]['payload'], 96, 'audio rtp 1 payload');
  equal(audio['rtp'][1]['codec'], 'opus', 'audio rtp 1 codec');
  equal(audio['rtp'][1]['rate'], 48000, 'audio rtp 1 rate');
  deepEqual(
      audio['ext'][0], {'value': 1, 'uri': 'URI-toffset'}, 'audio extension 0');
  deepEqual(
      audio['ext'][1],
      {'value': 2, 'direction': 'recvonly', 'uri': 'URI-gps-string'},
      'audio extension 1');
  //equal(audio['extmapAllowMixed'], 'extmap-allow-mixed',
  //   'extmap-allow-mixed present');

  dynamic video = media[1];
  equal(video['type'], 'video', 'video type');
  equal(video['port'], 55400, 'video port');
  equal(video['protocol'], 'RTP/SAVPF', 'video protocol');
  equal(video['direction'], 'sendrecv', 'video direction');
  equal(video['rtp'][0]['payload'], 97, 'video rtp 0 payload');
  equal(video['rtp'][0]['codec'], 'H264', 'video rtp 0 codec');
  equal(video['rtp'][0]['rate'], 90000, 'video rtp 0 rate');
  equal(video['fmtp'][0]['payload'], 97, 'video fmtp 0 payload');
  dynamic vidFmtp = parseParams(video['fmtp'][0]['config']);
  equal(vidFmtp['profile-level-id'], '4d0028', 'video fmtp 0 profile-level-id');
  equal(vidFmtp['packetization-mode'], 1, 'video fmtp 0 packetization-mode');
  equal(vidFmtp['sprop-parameter-sets'], 'Z0IAH5WoFAFuQA==,aM48gA==',
      'video fmtp 0 sprop-parameter-sets');
  equal(video['fmtp'][1]['payload'], 98, 'video fmtp 1 payload');
  dynamic vidFmtp2 = parseParams(video['fmtp'][1]['config']);
  equal(vidFmtp2['minptime'], 10, 'video fmtp 1 minptime');
  equal(vidFmtp2['useinbandfec'], 1, 'video fmtp 1 useinbandfec');
  equal(video['rtp'][1]['payload'], 98, 'video rtp 1 payload');
  equal(video['rtp'][1]['codec'], 'VP8', 'video rtp 1 codec');
  equal(video['rtp'][1]['rate'], 90000, 'video rtp 1 rate');
  equal(video['rtcpFb'][0]['payload'], '*', 'video rtcp-fb 0 payload');
  equal(video['rtcpFb'][0]['type'], 'nack', 'video rtcp-fb 0 type');
  equal(video['rtcpFb'][1]['payload'], 98, 'video rtcp-fb 0 payload');
  equal(video['rtcpFb'][1]['type'], 'nack', 'video rtcp-fb 0 type');
  equal(video['rtcpFb'][1]['subtype'], 'rpsi', 'video rtcp-fb 0 subtype');
  equal(video['rtcpFbTrrInt'][0]['payload'], 98,
      'video rtcp-fb trr-int 0 payload');
  equal(
      video['rtcpFbTrrInt'][0]['value'], 100, 'video rtcp-fb trr-int 0 value');
  equal(video['crypto'][0]['id'], 1, 'video crypto 0 id');
  equal(video['crypto'][0]['suite'], 'AES_CM_128_HMAC_SHA1_32',
      'video crypto 0 suite');
  equal(
      video['crypto'][0]['config'],
      'inline:keNcG3HezSNID7LmfDa9J4lfdUL8W1F7TNJKcbuy|2^20|1:32',
      'video crypto 0 config');
  equal(video['ssrcs'].length, 3, 'video got 3 ssrc lines');
  // test ssrc with attr:value
  deepEqual(
      video['ssrcs'][0],
      {'id': 1399694169, 'attribute': 'foo', 'value': 'bar'},
      'video 1st ssrc line attr:value');
  // test ssrc with attr only
  deepEqual(
      video['ssrcs'][1],
      {
        'id': 1399694169,
        'attribute': 'baz',
      },
      'video 2nd ssrc line attr only');
  // test ssrc with at-tr:value
  deepEqual(
      video['ssrcs'][2],
      {'id': 1399694169, 'attribute': 'foo-bar', 'value': 'baz'},
      'video 3rd ssrc line attr with dash');

  // ICE candidates (same for both audio and video in this case)
  int i = 0;
  [audio['candidates'], video['candidates']].forEach((cs) {
    dynamic str = (i == 0) ? 'audio ' : 'video ';
    dynamic port = (i == 0) ? 54400 : 55400;

    equal(cs.length, 4, str + 'got 4 candidates');
    equal(cs[0]['foundation'], 0, str + 'ice candidate 0 foundation');
    equal(cs[0]['component'], 1, str + 'ice candidate 0 component');
    equal(cs[0]['transport'], 'UDP', str + 'ice candidate 0 transport');
    equal(cs[0]['priority'], 2113667327, str + 'ice candidate 0 priority');
    equal(cs[0]['ip'], '203.0.113.1', str + 'ice candidate 0 ip');
    equal(cs[0]['port'], port, str + 'ice candidate 0 port');
    equal(cs[0]['type'], 'host', str + 'ice candidate 0 type');
    equal(cs[1]['foundation'], 1, str + 'ice candidate 1 foundation');
    equal(cs[1]['component'], 2, str + 'ice candidate 1 component');
    equal(cs[1]['transport'], 'UDP', str + 'ice candidate 1 transport');
    equal(cs[1]['priority'], 2113667326, str + 'ice candidate 1 priority');
    equal(cs[1]['ip'], '203.0.113.1', str + 'ice candidate 1 ip');
    equal(cs[1]['port'], port + 1, str + 'ice candidate 1 port');
    equal(cs[1]['type'], 'host', str + 'ice candidate 1 type');
    equal(cs[2]['foundation'], 2, str + 'ice candidate 2 foundation');
    equal(cs[2]['component'], 1, str + 'ice candidate 2 component');
    equal(cs[2]['transport'], 'UDP', str + 'ice candidate 2 transport');
    equal(cs[2]['priority'], 1686052607, str + 'ice candidate 2 priority');
    equal(cs[2]['ip'], '203.0.113.1', str + 'ice candidate 2 ip');
    equal(cs[2]['port'], port + 2, str + 'ice candidate 2 port');
    equal(cs[2]['type'], 'srflx', str + 'ice candidate 2 type');
    equal(cs[2]['raddr'], '192.168.1.145', str + 'ice candidate 2 raddr');
    equal(cs[2]['rport'], port + 2, str + 'ice candidate 2 rport');
    equal(cs[2]['generation'], 0, str + 'ice candidate 2 generation');
    equal(cs[2]['network-id'], 3, str + 'ice candidate 2 network-id');
    equal(cs[2]['network-cost'], (i == 0 ? 10 : null),
        str + 'ice candidate 2 network-cost');
    equal(cs[3]['foundation'], 3, str + 'ice candidate 3 foundation');
    equal(cs[3]['component'], 2, str + 'ice candidate 3 component');
    equal(cs[3]['transport'], 'UDP', str + 'ice candidate 3 transport');
    equal(cs[3]['priority'], 1686052606, str + 'ice candidate 3 priority');
    equal(cs[3]['ip'], '203.0.113.1', str + 'ice candidate 3 ip');
    equal(cs[3]['port'], port + 3, str + 'ice candidate 3 port');
    equal(cs[3]['type'], 'srflx', str + 'ice candidate 3 type');
    equal(cs[3]['raddr'], '192.168.1.145', str + 'ice candidate 3 raddr');
    equal(cs[3]['rport'], port + 3, str + 'ice candidate 3 rport');
    equal(cs[3]['generation'], 0, str + 'ice candidate 3 generation');
    equal(cs[3]['network-id'], 3, str + 'ice candidate 3 network-id');
    equal(cs[3]['network-cost'], (i == 0 ? 10 : null),
        str + 'ice candidate 3 network-cost');
    i++;
  });

  equal(media.length, 2, 'got 2 m-lines');
}

/*
 * Test for an sdp that started out as something from chrome
 * it's since been hacked to include tests for other stuff
 * ignore the name
 */
_testHackySdp() async {
  String sdp = await new File('./test/sdp_test_data/hacky.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  equal(
      session['origin']['sessionId'], 3710604898417546434, 'origin sessionId');
  ok(session['groups'], 'parsing session groups');
  equal(session['groups'].length, 1, 'one grouping');
  equal(session['groups'][0]['type'], 'BUNDLE', 'grouping is BUNDLE');
  equal(session['groups'][0]['mids'], 'audio video', 'bundling audio video');
  ok(session['msidSemantic'], 'have an msid semantic');
  equal(session['msidSemantic']['semantic'], 'WMS', 'webrtc semantic');
  equal(session['msidSemantic']['token'],
      'Jvlam5X3SX1OP6pn20zWogvaKJz5Hjf9OnlV', 'semantic token');

  // verify a=rtcp:65179 IN IP4 193.84.77.194
  equal(media[0]['rtcp']['port'], 1, 'rtcp port');
  equal(media[0]['rtcp']['netType'], 'IN', 'rtcp netType');
  equal(media[0]['rtcp']['ipVer'], 4, 'rtcp ipVer');
  equal(media[0]['rtcp']['address'], '0.0.0.0', 'rtcp address');

  // verify ice tcp types
  equal(media[0]['candidates'][0]['tcptype'], null, 'no tcptype');
  equal(media[0]['candidates'][1]['tcptype'], 'active', 'active tcptype');
  equal(media[0]['candidates'][1]['transport'], 'tcp', 'tcp transport');
  equal(media[0]['candidates'][1]['generation'], 0, 'generation 0');
  equal(media[0]['candidates'][1]['type'], 'host', 'tcp host');
  equal(media[0]['candidates'][2]['generation'], null, 'no generation');
  equal(media[0]['candidates'][2]['type'], 'host', 'tcp host');
  equal(media[0]['candidates'][2]['tcptype'], 'active', 'active tcptype');
  equal(media[0]['candidates'][3]['tcptype'], 'passive', 'passive tcptype');
  equal(media[0]['candidates'][4]['tcptype'], 'so', 'so tcptype');
  // raddr + rport + tcptype + generation
  equal(media[0]['candidates'][5]['type'], 'srflx', 'tcp srflx');
  equal(media[0]['candidates'][5]['rport'], 9, 'tcp rport');
  equal(media[0]['candidates'][5]['raddr'], '10.0.1.1', 'tcp raddr');
  equal(media[0]['candidates'][5]['tcptype'], 'active', 'active tcptype');
  equal(media[0]['candidates'][6]['tcptype'], 'passive', 'passive tcptype');
  equal(media[0]['candidates'][6]['rport'], 8998, 'tcp rport');
  equal(media[0]['candidates'][6]['raddr'], '10.0.1.1', 'tcp raddr');
  equal(media[0]['candidates'][6]['generation'], 5, 'tcp generation');

  // and verify it works without specifying the ip
  equal(media[1]['rtcp']['port'], 12312, 'rtcp port');
  equal(media[1]['rtcp']['netType'], null, 'rtcp netType');
  equal(media[1]['rtcp']['ipVer'], null, 'rtcp ipVer');
  equal(media[1]['rtcp']['address'], null, 'rtcp address');

  // verify a=rtpmap:126 telephone-event/8000
  dynamic lastRtp = media[0]['rtp'].length - 1;
  equal(media[0]['rtp'][lastRtp]['codec'], 'telephone-event', 'dtmf codec');
  equal(media[0]['rtp'][lastRtp]['rate'], 8000, 'dtmf rate');

  equal(media[0]['iceOptions'], 'google-ice', 'ice options parsed');
  equal(media[0]['maxptime'], 60, 'maxptime parsed');
  equal(media[0]['rtcpMux'], 'rtcp-mux', 'rtcp-mux present');

  equal(media[0]['rtp'][0]['codec'], 'opus', 'audio rtp 0 codec');
  equal(media[0]['rtp'][0]['encoding'], 2, 'audio rtp 0 encoding');

  ok(media[0]['ssrcs'], 'have ssrc lines');
  equal(media[0]['ssrcs'].length, 4, 'got 4 ssrc lines');
  dynamic ssrcs = media[0]['ssrcs'];
  deepEqual(
      ssrcs[0],
      {'id': 2754920552, 'attribute': 'cname', 'value': 't9YU8M1UxTF8Y1A1'},
      '1st ssrc line');

  deepEqual(
      ssrcs[1],
      {
        'id': 2754920552,
        'attribute': 'msid',
        'value':
            'Jvlam5X3SX1OP6pn20zWogvaKJz5Hjf9OnlV Jvlam5X3SX1OP6pn20zWogvaKJz5Hjf9OnlVa0'
      },
      '2nd ssrc line');

  deepEqual(
      ssrcs[2],
      {
        'id': 2754920552,
        'attribute': 'mslabel',
        'value': 'Jvlam5X3SX1OP6pn20zWogvaKJz5Hjf9OnlV'
      },
      '3rd ssrc line');

  deepEqual(
      ssrcs[3],
      {
        'id': 2754920552,
        'attribute': 'label',
        'value': 'Jvlam5X3SX1OP6pn20zWogvaKJz5Hjf9OnlVa0'
      },
      '4th ssrc line');

  // verify a=sctpmap:5000 webrtc-datachannel 1024
  ok(media[2]['sctpmap'], 'we have sctpmap');
  equal(media[2]['sctpmap']['sctpmapNumber'], 5000, 'sctpmap number is 5000');
  equal(media[2]['sctpmap']['app'], 'webrtc-datachannel',
      'sctpmap app is webrtc-datachannel');
  equal(media[2]['sctpmap']['maxMessageSize'], 1024,
      'sctpmap maxMessageSize is 1024');

  // verify a=framerate:29.97
  ok(media[2]['framerate'], 'we have framerate');
  equal(media[2]['framerate'], '29.97', 'framerate is 29.97');

  // verify a=label:1
  ok(media[0]['label'], 'we have label');
  equal(media[0]['label'], 1, 'label is 1');
}

_testIceliteSdp() async {
  String sdp =
      await new File('./test/sdp_test_data/icelite.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  equal(session['icelite'], 'ice-lite', 'icelite parsed');

  dynamic rew = write(session, null);
  ok(rew.indexOf('a=ice-lite\r\n') >= 0, 'got ice-lite');
  ok(rew.indexOf('m=') > rew.indexOf('a=ice-lite'), 'session level icelite');
}

_testInvalidSdp() async {
  String sdp =
      await new File('./test/sdp_test_data/invalid.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  // verify a=rtcp:65179 IN IP4 193.84.77.194
  equal(media[0]['rtcp']['port'], 1, 'rtcp port');
  equal(media[0]['rtcp']['netType'], 'IN', 'rtcp netType');
  equal(media[0]['rtcp']['ipVer'], 7, 'rtcp ipVer');
  equal(media[0]['rtcp']['address'], 'X', 'rtcp address');
  equal(
      media[0]['invalid'].length, 1, 'found exactly 1 invalid line'); // f= lost
  equal(media[0]['invalid'][0]['value'], 'goo:hithere', 'copied verbatim');
}

_testJssipSdp() async {
  String sdp = await new File('./test/sdp_test_data/jssip.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic audio = media[0];
  dynamic audCands = audio['candidates'];
  equal(audCands.length, 6, '6 candidates');

  // testing ice optionals:
  deepEqual(
      audCands[0],
      {
        'foundation': 1162875081,
        'component': 1,
        'transport': 'udp',
        'priority': 2113937151,
        'ip': '192.168.34.75',
        'port': 60017,
        'type': 'host',
        'generation': 0,
      },
      'audio candidate 0');
  deepEqual(
      audCands[2],
      {
        'foundation': 3289912957,
        'component': 1,
        'transport': 'udp',
        'priority': 1845501695,
        'ip': '193.84.77.194',
        'port': 60017,
        'type': 'srflx',
        'raddr': '192.168.34.75',
        'rport': 60017,
        'generation': 0,
      },
      'audio candidate 2 (raddr rport)');
  deepEqual(
      audCands[4],
      {
        'foundation': 198437945,
        'component': 1,
        'transport': 'tcp',
        'priority': 1509957375,
        'ip': '192.168.34.75',
        'port': 0,
        'type': 'host',
        'generation': 0
      },
      'audio candidate 4 (tcp)');
}

_testJsepSdp() async {
  String sdp = await new File('./test/sdp_test_data/jsep.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length == 2, 'got media');

  dynamic video = media[1];
  equal(video['ssrcGroups'].length, 1, '1 ssrc grouping');
  deepEqual(video['ssrcGroups'][0],
      {'semantics': 'FID', 'ssrcs': '1366781083 1366781084'}, 'ssrc-group');

  equal(
      video['msid'],
      '61317484-2ed4-49d7-9eb7-1414322a7aae f30bdb4a-5db8-49b5-bcdc-e0c9a23172e0',
      'msid');

  ok(video['rtcpRsize'], 'rtcp-rsize present');
  ok(video['bundleOnly'], 'bundle-only present');

  // video contains 'a=end-of-candidates'
  // we want to ensure this comes after the candidate lines
  // so this is the only place we actually test the writer in here
  ok(video['endOfCandidates'], 'have end of candidates marker');
  dynamic rewritten = write(session, null).split('\r\n');
  dynamic idx = rewritten.indexOf('a=end-of-candidates');
  equal((rewritten[idx - 1] as String).substring(0, 11), 'a=candidate',
      'marker after candidate');
}

_testAlacSdp() async {
  String sdp = await new File('./test/sdp_test_data/alac.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic audio = media[0];
  equal(audio['type'], 'audio', 'audio type');
  equal(audio['protocol'], 'RTP/AVP', 'audio protocol');
  equal(audio['fmtp'][0]['payload'], 96, 'audio fmtp 0 payload');
  equal(audio['fmtp'][0]['config'], '352 0 16 40 10 14 2 255 0 0 44100',
      'audio fmtp 0 config');
  equal(audio['rtp'][0]['payload'], 96, 'audio rtp 0 payload');
  equal(audio['rtp'][0]['codec'], 'AppleLossless', 'audio rtp 0 codec');
  equal(audio['rtp'][0]['rate'], null, 'audio rtp 0 rate');
  equal(audio['rtp'][0]['encoding'], null, 'audio rtp 0 encoding');
}

testOnvifSdp() async {
  String sdp = await new File('./test/sdp_test_data/onvif.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic audio = media[0];
  equal(audio['type'], 'audio', 'audio type');
  equal(audio['port'], 0, 'audio port');
  equal(audio['protocol'], 'RTP/AVP', 'audio protocol');
  equal(audio['control'], 'rtsp://example.com/onvif_camera/audio',
      'audio control');
  equal(audio['payloads'], 0, 'audio payloads');

  dynamic video = media[1];
  equal(video['type'], 'video', 'video type');
  equal(video['port'], 0, 'video port');
  equal(video['protocol'], 'RTP/AVP', 'video protocol');
  equal(video['control'], 'rtsp://example.com/onvif_camera/video',
      'video control');
  equal(video['payloads'], 26, 'video payloads');

  dynamic application = media[2];
  equal(application['type'], 'application', 'application type');
  equal(application['port'], 0, 'application port');
  equal(application['protocol'], 'RTP/AVP', 'application protocol');
  equal(application['control'], 'rtsp://example.com/onvif_camera/metadata',
      'application control');
  equal(application['payloads'], 107, 'application payloads');
  equal(application['direction'], 'recvonly', 'application direction');
  equal(application['rtp'][0]['payload'], 107, 'application rtp 0 payload');
  equal(application['rtp'][0]['codec'], 'vnd.onvif.metadata',
      'application rtp 0 codec');
  equal(application['rtp'][0]['rate'], 90000, 'application rtp 0 rate');
  equal(application['rtp'][0]['encoding'], null, 'application rtp 0 encoding');
}

_testSsrcSdp() async {
  String sdp = await new File('./test/sdp_test_data/ssrc.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic video = media[1];
  equal(video['ssrcGroups'].length, 2, 'video got 2 ssrc-group lines');

  dynamic expectedSsrc = [
    {'semantics': 'FID', 'ssrcs': '3004364195 1126032854'},
    {'semantics': 'FEC-FR', 'ssrcs': '3004364195 1080772241'}
  ];
  deepEqual(video['ssrcGroups'], expectedSsrc, 'video ssrc-group obj');
}

_testSimulcastSdp() async {
  String sdp =
      await new File('./test/sdp_test_data/simulcast.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic video = media[1];
  equal(video['type'], 'video', 'video type');

  // test rid lines
  equal(video['rids'].length, 5, 'video got 5 rid lines');
  // test rid 1
  deepEqual(
      video['rids'][0],
      {
        'id': 1,
        'direction': 'send',
        'params': 'pt=97;max-width=1280;max-height=720;max-fps=30'
      },
      'video 1st rid line');
  // test rid 2
  deepEqual(video['rids'][1], {'id': 2, 'direction': 'send', 'params': 'pt=98'},
      'video 2nd rid line');
  // test rid 3
  deepEqual(video['rids'][2], {'id': 3, 'direction': 'send', 'params': 'pt=99'},
      'video 3rd rid line');
  // test rid 4
  deepEqual(video['rids'][3],
      {'id': 4, 'direction': 'send', 'params': 'pt=100'}, 'video 4th rid line');
  // test rid 5
  deepEqual(
      video['rids'][4],
      {'id': 'c', 'direction': 'recv', 'params': 'pt=97'},
      'video 5th rid line');
  // test rid 1 params
  dynamic rid1Params = parseParams(video['rids'][0]['params']);
  deepEqual(
      rid1Params,
      {'pt': 97, 'max-width': 1280, 'max-height': 720, 'max-fps': 30},
      'video 1st rid params');
  // test rid 2 params
  dynamic rid2Params = parseParams(video['rids'][1]['params']);
  deepEqual(rid2Params, {'pt': 98}, 'video 2nd rid params');
  // test rid 3 params
  dynamic rid3Params = parseParams(video['rids'][2]['params']);
  deepEqual(rid3Params, {'pt': 99}, 'video 3rd rid params');
  // test rid 4 params
  dynamic rid4Params = parseParams(video['rids'][3]['params']);
  deepEqual(rid4Params, {'pt': 100}, 'video 4th rid params');
  // test rid 5 params
  dynamic rid5Params = parseParams(video['rids'][4]['params']);
  deepEqual(rid5Params, {'pt': 97}, 'video 5th rid params');

  // test imageattr lines
  equal(video['imageattrs'].length, 5, 'video got 5 imageattr lines');
  // test imageattr 1
  deepEqual(
      video['imageattrs'][0],
      {
        'pt': 97,
        'dir1': 'send',
        'attrs1': '[x=1280,y=720]',
        'dir2': 'recv',
        'attrs2': '[x=1280,y=720] [x=320,y=180] [x=160,y=90]'
      },
      'video 1st imageattr line');
  // test imageattr 2
  deepEqual(
      video['imageattrs'][1],
      {'pt': 98, 'dir1': 'send', 'attrs1': '[x=320,y=180]'},
      'video 2nd imageattr line');
  // test imageattr 3
  deepEqual(
      video['imageattrs'][2],
      {'pt': 99, 'dir1': 'send', 'attrs1': '[x=160,y=90]'},
      'video 3rd imageattr line');
  // test imageattr 4
  deepEqual(
      video['imageattrs'][3],
      {
        'pt': 100,
        'dir1': 'recv',
        'attrs1': '[x=1280,y=720] [x=320,y=180]',
        'dir2': 'send',
        'attrs2': '[x=1280,y=720]'
      },
      'video 4th imageattr line');
  // test imageattr 5
  deepEqual(video['imageattrs'][4], {'pt': '*', 'dir1': 'recv', 'attrs1': '*'},
      'video 5th imageattr line');
  // test imageattr 1 send params
  dynamic imageattr1SendParams =
      parseImageAttributes(video['imageattrs'][0]['attrs1']);
  deepEqual(
      imageattr1SendParams,
      [
        {'x': 1280, 'y': 720}
      ],
      'video 1st imageattr send params');
  // test imageattr 1 recv params
  dynamic imageattr1RecvParams =
      parseImageAttributes(video['imageattrs'][0]['attrs2']);
  deepEqual(
      imageattr1RecvParams,
      [
        {'x': 1280, 'y': 720},
        {'x': 320, 'y': 180},
        {'x': 160, 'y': 90},
      ],
      'video 1st imageattr recv params');
  // test imageattr 2 send params
  dynamic imageattr2SendParams =
      parseImageAttributes(video['imageattrs'][1]['attrs1']);
  deepEqual(
      imageattr2SendParams,
      [
        {'x': 320, 'y': 180}
      ],
      'video 2nd imageattr send params');
  // test imageattr 3 send params
  dynamic imageattr3SendParams =
      parseImageAttributes(video['imageattrs'][2]['attrs1']);
  deepEqual(
      imageattr3SendParams,
      [
        {'x': 160, 'y': 90}
      ],
      'video 3rd imageattr send params');
  // test imageattr 4 recv params
  dynamic imageattr4RecvParams =
      parseImageAttributes(video['imageattrs'][3]['attrs1']);
  deepEqual(
      imageattr4RecvParams,
      [
        {'x': 1280, 'y': 720},
        {'x': 320, 'y': 180},
      ],
      'video 4th imageattr recv params');
  // test imageattr 4 send params
  dynamic imageattr4SendParams =
      parseImageAttributes(video['imageattrs'][3]['attrs2']);
  deepEqual(
      imageattr4SendParams,
      [
        {'x': 1280, 'y': 720}
      ],
      'video 4th imageattr send params');
  // test imageattr 5 recv params
  equal(
      video['imageattrs'][4]['attrs1'], '*', 'video 5th imageattr recv params');

  // test simulcast line
  deepEqual(
      video['simulcast'],
      {'dir1': 'send', 'list1': '1,~4;2;3', 'dir2': 'recv', 'list2': 'c'},
      'video simulcast line');
  // test simulcast send streams
  dynamic simulcastSendStreams =
      parseSimulcastStreamList(video['simulcast']['list1']);
  deepEqual(
      simulcastSendStreams,
      [
        [
          {'scid': 1, 'paused': false},
          {'scid': 4, 'paused': true}
        ],
        [
          {'scid': 2, 'paused': false}
        ],
        [
          {'scid': 3, 'paused': false}
        ]
      ],
      'video simulcast send streams');
  // test simulcast recv streams
  dynamic simulcastRecvStreams =
      parseSimulcastStreamList(video['simulcast']['list2']);
  deepEqual(
      simulcastRecvStreams,
      [
        [
          {'scid': 'c', 'paused': false}
        ]
      ],
      'video simulcast recv streams');

  // test simulcast version 03 line
  // test simulcast line
  deepEqual(
      video['simulcast_03'],
      {'value': 'send rid=1,4;2;3 paused=4 recv rid=c'},
      'video simulcast draft 03 line');
}

_testSt2202_6Sdp() async {
  String sdp =
      await new File('./test/sdp_test_data/st2022-6.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic video = media[0];
  dynamic sourceFilter = video['sourceFilter'];
  equal(sourceFilter['filterMode'], 'incl', 'filter-mode is "incl"');
  equal(sourceFilter['netType'], 'IN', 'nettype is "IN"');
  equal(sourceFilter['addressTypes'], 'IP4', 'address-type is "IP4"');
  equal(
      sourceFilter['destAddress'], '239.0.0.1', 'dest-address is "239.0.0.1"');
  equal(
      sourceFilter['srcList'], '192.168.20.20', 'src-list is "192.168.20.20"');
}

_testSt2110_20Sdp() async {
  String sdp =
      await new File('./test/sdp_test_data/st2110-20.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  dynamic video = media[0];
  dynamic sourceFilter = video['sourceFilter'];
  equal(sourceFilter['filterMode'], 'incl', 'filter-mode is "incl"');
  equal(sourceFilter['netType'], 'IN', 'nettype is "IN"');
  equal(sourceFilter['addressTypes'], 'IP4', 'address-type is "IP4"');
  equal(sourceFilter['destAddress'], '239.100.9.10',
      'dest-address is "239.100.9.10"');
  equal(
      sourceFilter['srcList'], '192.168.100.2', 'src-list is "192.168.100.2"');

  equal(video['type'], 'video', 'video type');
  dynamic fmtp0Params = parseParams(video['fmtp'][0]['config']);
  deepEqual(
      fmtp0Params,
      {
        'sampling': 'YCbCr-4:2:2',
        'width': 1280,
        'height': 720,
        'interlace': null,
        'exactframerate': '60000/1001',
        'depth': 10,
        'TCS': 'SDR',
        'colorimetry': 'BT709',
        'PM': '2110GPM',
        'SSN': 'ST2110-20:2017'
      },
      'video 5th rid params');
}

_testSctpDtls26Sdp() async {
  String sdp =
      await new File('./test/sdp_test_data/sctp-dtls-26.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  equal(
      session['origin']['sessionId'], 5636137646675714991, 'origin sessionId');
  ok(session['groups'], 'parsing session groups');
  equal(session['groups'].length, 1, 'one grouping');
  equal(session['groups'][0]['type'], 'BUNDLE', 'grouping is BUNDLE');
  equal(session['groups'][0]['mids'], 'data', 'bundling data');
  ok(session['msidSemantic'], 'have an msid semantic');
  equal(session['msidSemantic']['semantic'], 'WMS', 'webrtc semantic');

  // verify media is data application
  equal(media[0]['type'], 'application', 'media type application');
  equal(media[0]['mid'], 'data', 'media  id pplication');

  // verify protocol and ports
  equal(media[0]['protocol'], 'UDP/DTLS/SCTP', 'protocol is UDP/DTLS/SCTP');
  equal(media[0]['port'], 9, 'the UDP port value is 9');
  equal(
      media[0]['sctpPort'], 5000, 'the offerer/answer SCTP port value is 5000');

  // verify maxMessageSize
  equal(media[0]['maxMessageSize'], 10000, 'maximum message size is 10000');
}

_testExtmapEncryptSdp() async {
  String sdp =
      await new File('./test/sdp_test_data/extmap-encrypt.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length > 0, 'got media');

  equal(session['origin']['username'], '-', 'origin username');
  equal(session['origin']['sessionId'], 20518, 'origin sessionId');
  equal(session['origin']['sessionVersion'], 0, 'origin sessionVersion');
  equal(session['origin']['netType'], 'IN', 'origin netType');
  equal(session['origin']['ipVer'], 4, 'origin ipVer');
  equal(session['origin']['address'], '203.0.113.1', 'origin address');

  equal(session['connection']['ip'], '203.0.113.1', 'session connect ip');
  equal(session['connection']['version'], 4, 'session connect ip ver');

  dynamic audio = media[0];
  equal(audio['type'], 'audio', 'audio type');
  equal(audio['port'], 54400, 'audio port');
  equal(audio['protocol'], 'RTP/SAVPF', 'audio protocol');
  equal(audio['rtp'][0]['payload'], 96, 'audio rtp 0 payload');
  equal(audio['rtp'][0]['codec'], 'opus', 'audio rtp 0 codec');
  equal(audio['rtp'][0]['rate'], 48000, 'audio rtp 0 rate');

  // extmap and encrypted extmap
  deepEqual(
      audio['ext'][0],
      {'value': 1, 'direction': 'sendonly', 'uri': 'URI-toffset'},
      'audio extension 0');
  deepEqual(
      audio['ext'][1],
      {'value': 2, 'uri': 'urn:ietf:params:rtp-hdrext:toffset'},
      'audio extension 1');
  deepEqual(
      audio['ext'][2],
      {
        'value': 3,
        'encrypt-uri': 'urn:ietf:params:rtp-hdrext:encrypt',
        'uri': 'urn:ietf:params:rtp-hdrext:smpte-tc',
        'config': '25@600/24'
      },
      'audio extension 2');
  deepEqual(
      audio['ext'][3],
      {
        'value': 4,
        'direction': 'recvonly',
        'encrypt-uri': 'urn:ietf:params:rtp-hdrext:encrypt',
        'uri': 'URI-gps-string'
      },
      'audio extension 3');

  equal(media.length, 1, 'got 1 m-lines');
}

_testDanteAes67() async {
  String sdp =
      await new File('./test/sdp_test_data/dante-aes67.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length == 1, 'got single media');

  equal(session['origin']['username'], '-', 'origin username');
  equal(session['origin']['sessionId'], 1423986, 'origin sessionId');
  equal(session['origin']['sessionVersion'], 1423994, 'origin sessionVersion');
  equal(session['origin']['netType'], 'IN', 'origin netType');
  equal(session['origin']['ipVer'], 4, 'origin ipVer');
  equal(session['origin']['address'], '169.254.98.63', 'origin address');

  equal(session['name'], 'AOIP44-serial-1614 : 2', 'Session Name');
  //equal(session['keywords'], 'Dante', 'Keywords');

  equal(session['connection']['ip'], '239.65.125.63/32', 'session connect ip');
  equal(session['connection']['version'], 4, 'session connect ip ver');

  dynamic audio = media[0];
  equal(audio['type'], 'audio', 'audio type');
  equal(audio['port'], 5004, 'audio port');
  equal(audio['protocol'], 'RTP/AVP', 'audio protocol');
  equal(audio['direction'], 'recvonly', 'audio direction');
  equal(audio['description'], '2 channels: TxChan 0, TxChan 1',
      'audio description');
  equal(audio['ptime'], 1, 'audio packet duration');
  equal(audio['rtp'][0]['payload'], 97, 'audio rtp payload type');
  equal(audio['rtp'][0]['codec'], 'L24', 'audio rtp codec');
  equal(audio['rtp'][0]['rate'], 48000, 'audio sample rate');
  equal(audio['rtp'][0]['encoding'], 2, 'audio channels');
}

_testTcpActive() async {
  String sdp =
      await new File('./test/sdp_test_data/tcp-active.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length == 1, 'got single media');

  equal(session['origin']['username'], '-', 'origin username');
  equal(session['origin']['sessionId'], 1562876543, 'origin sessionId');
  equal(session['origin']['sessionVersion'], 11, 'origin sessionVersion');
  equal(session['origin']['netType'], 'IN', 'origin netType');
  equal(session['origin']['ipVer'], 4, 'origin ipVer');
  equal(session['origin']['address'], '192.0.2.3', 'origin address');

  dynamic image = media[0];
  equal(image['type'], 'image', 'image type');
  equal(image['port'], 9, 'port');
  equal(image['connection']['version'], 4, 'Connection is IPv4');
  equal(image['connection']['ip'], '192.0.2.3', 'Connection address');
  equal(image['protocol'], 'TCP', 'TCP protocol');
  equal(image['payloads'], 't38', 'TCP payload');
  equal(image['setup'], 'active', 'setup active');
  //equal(image['connectionType'], 'new', 'new connection');
}

_testTcpPassive() async {
  String sdp =
      await new File('./test/sdp_test_data/tcp-passive.sdp').readAsString();

  Map<String, dynamic> session = parse(sdp + '');
  ok(session, 'got session info');
  dynamic media = session['media'];
  ok(media != null && media.length == 1, 'got single media');

  equal(session['origin']['username'], '-', 'origin username');
  equal(session['origin']['sessionId'], 1562876543, 'origin sessionId');
  equal(session['origin']['sessionVersion'], 11, 'origin sessionVersion');
  equal(session['origin']['netType'], 'IN', 'origin netType');
  equal(session['origin']['ipVer'], 4, 'origin ipVer');
  equal(session['origin']['address'], '192.0.2.2', 'origin address');

  dynamic image = media[0];
  equal(image['type'], 'image', 'image type');
  equal(image['port'], 54111, 'port');
  equal(image['connection']['version'], 4, 'Connection is IPv4');
  equal(image['connection']['ip'], '192.0.2.2', 'Connection address');
  equal(image['protocol'], 'TCP', 'TCP protocol');
  equal(image['payloads'], 't38', 'TCP payload');
  equal(image['setup'], 'passive', 'setup passive');
  //  equal(image['connectionType'], 'existing', 'existing connection');
}
