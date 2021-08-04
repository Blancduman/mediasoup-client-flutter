import 'package:mediasoup_client_flutter/src/rtp_parameters.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/media_section.dart';

class UnifiedPlanUtils {
  static List<RtpEncodingParameters> getRtpEncodings(
    MediaObject offerMediaObject,
  ) {
    Set<int> ssrcs = Set<int>();

    for (Ssrc line in offerMediaObject.ssrcs ?? []) {
      int ssrc = line.id!;

      ssrcs.add(ssrc);
    }

    if (ssrcs.isEmpty) {
      throw ('no a=ssrc lines found');
    }

    Map<dynamic, dynamic> ssrcToRtxSsrc = <dynamic, dynamic>{};

    // First assume RTX is used.
    for (SsrcGroup line in offerMediaObject.ssrcGroups ?? []) {
      if (line.semantics != 'FID') {
        continue;
      }

      List<String> tokens = line.ssrcs.split(' ');

      int? ssrc;
      int? rtxSsrc;

      if (tokens.length > 0) {
        ssrc = int.parse(tokens[0]);
      }
      if (tokens.length > 1) {
        rtxSsrc = int.parse(tokens[1]);
      }

      if (ssrcs.contains(ssrc)) {
        // Remove both the SSRC and RTX SSRC from the set so later we know that they
        // are already handled.
        ssrcs.remove(ssrc);
        ssrcs.remove(rtxSsrc);

        // Add to the map.
        ssrcToRtxSsrc[ssrc] = rtxSsrc;
      }
    }

    // If the set of SSRCs is not empty it means that RTX is not being used, so take
    // media SSRCs from there.
    for (int ssrc in ssrcs) {
      // Add to the map.
      ssrcToRtxSsrc[ssrc] = null;
    }

    List<RtpEncodingParameters> encodings = <RtpEncodingParameters>[];

    ssrcToRtxSsrc.forEach((ssrc, rtxSsrc) {
      RtpEncodingParameters encoding = RtpEncodingParameters(
        ssrc: ssrc,
      );

      if (rtxSsrc != null) {
        encoding.rtx = RtxSsrc(rtxSsrc);
      }

      encodings.add(encoding);
    });

    return encodings;
  }

  static void addLegacySimulcast(
    MediaObject offerMediaObject,
    int numStreams,
  ) {
    if (numStreams <= 1) {
      throw ('numStreams must be greater than 1');
    }

    // Get the SSRC.
    Ssrc? ssrcMsidLine = (offerMediaObject.ssrcs ?? []).firstWhere(
      (Ssrc line) => line.attribute == 'msid',
      orElse: () => null as Ssrc,
    );

    if (ssrcMsidLine == null) {
      throw ('a=ssrc line with msid information not found');
    }

    List<String> tmp = ssrcMsidLine.value.split(' ');

    String streamId = '';
    String trackId = '';

    if (tmp.length > 0) {
      streamId = tmp[0];
    }
    if (tmp.length > 1) {
      trackId = tmp[1];
    }

    int? firstSsrc = ssrcMsidLine.id;
    int? firstRtxSsrc;

    // Get the SSRC for RTX.
    (offerMediaObject.ssrcGroups ?? []).any((SsrcGroup line) {
      if (line.semantics != 'FID') {
        return false;
      }

      List<String> ssrcs = line.ssrcs.split(' ');

      if (int.parse(ssrcs[0]) == firstSsrc) {
        firstRtxSsrc = int.parse(ssrcs[1]);

        return true;
      } else {
        return false;
      }
    });

    Ssrc? ssrcCnameLine = offerMediaObject.ssrcs?.firstWhere(
      (Ssrc line) => line.attribute == 'cname',
      orElse: () => null as Ssrc,
    );

    if (ssrcCnameLine == null) {
      throw ('a=ssrc line with cname information not found');
    }

    String cname = ssrcCnameLine.value;
    List<int> ssrcs = <int>[];
    List<int> rtxSsrcs = <int>[];

    for (int i = 0; i < numStreams; ++i) {
      ssrcs.add(firstSsrc! + i);

      if (firstRtxSsrc != null) {
        rtxSsrcs.add(firstRtxSsrc! + i);
      }
    }

    offerMediaObject.ssrcGroups = <SsrcGroup>[];
    offerMediaObject.ssrcs = <Ssrc>[];

    offerMediaObject.ssrcGroups!.add(SsrcGroup(
      semantics: 'SIM',
      ssrcs: ssrcs.join(' '),
    ));

    for (int i = 0; i < ssrcs.length; ++i) {
      int ssrc = ssrcs[i];

      offerMediaObject.ssrcs!.add(Ssrc(
        id: ssrc,
        attribute: 'cname',
        value: cname,
      ));

      offerMediaObject.ssrcs!.add(Ssrc(
        id: ssrc,
        attribute: 'msid',
        value: '$streamId $trackId',
      ));
    }

    for (int i = 0; i < rtxSsrcs.length; ++i) {
      int ssrc = ssrcs[i];
      int rtxSsrc = rtxSsrcs[i];

      offerMediaObject.ssrcs!.add(Ssrc(
        id: rtxSsrc,
        attribute: 'cname',
        value: cname,
      ));

      offerMediaObject.ssrcs!.add(Ssrc(
        id: rtxSsrc,
        attribute: 'msid',
        value: '$streamId $trackId',
      ));

      offerMediaObject.ssrcGroups!.add(SsrcGroup(
        semantics: 'FID',
        ssrcs: '$ssrc $rtxSsrc',
      ));
    }
  }
}
