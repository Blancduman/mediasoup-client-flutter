import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/MediaSection.dart';

class PlanBUtils {
  static List<RtpEncodingParameters> getRtpEncodings(
    MediaObject offerMediaObject,
    MediaStreamTrack track,
  ) {
    // First media SSRC (or the only one).
    int firstSsrc;
    Set<int> ssrcs = Set<int>();

    for (Ssrc line in offerMediaObject.ssrcs ?? []) {
      if (line.attribute != 'msid') {
        continue;
      }

      String trackId = line.value.split(' ')[1];

      if (trackId == track.id) {
        int ssrc = line.id;

        ssrcs.add(ssrc);

        if (firstSsrc == null) {
          firstSsrc = ssrc;
        }
      }
    }

    if (ssrcs.isEmpty) {
      throw ('a=ssrc line with msid information not found [track.id:${track.id}]');
    }

    Map<dynamic, dynamic> ssrcToRtxSsrc = {};

    // First assume RTX is used.
    for (SsrcGroup line in offerMediaObject.ssrcGroups ?? []) {
      if (line.semantics != 'FID') {
        continue;
      }

      List<String> tokens = line.ssrcs.split(' ');

      int ssrc;
      if (tokens.length > 0) {
        ssrc = int.parse(tokens.first);
      }

      int rtxSsrc;
      if (tokens.length > 1) {
        rtxSsrc = int.parse(tokens.last);
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

  /// Adds multi-ssrc based simulcast into the given SDP media section offer.
  static void addLegacySimulcast(
    MediaObject offerMediaObject,
    MediaStreamTrack track,
    int numStreams,
  ) {
    if (numStreams <= 1) {
      throw ('numStreams must be greater than 1');
    }

    int firstSsrc;
    int firstRtxSsrc;
    String streamId;

    // Get the SSRC.
    Ssrc ssrcMsidLine = (offerMediaObject.ssrcs ?? []).firstWhere(
      (Ssrc line) {
        if (line.attribute != 'msid') {
          return false;
        }

        String trackId = line.value.split(' ')[1];

        if (trackId == track.id) {
          firstSsrc = line.id;
          streamId = line.value.split(' ')[0];

          return true;
        } else {
          return false;
        }
      },
      orElse: () => null,
    );

    if (ssrcMsidLine == null) {
      throw ('a=ssrc line with msid information not found [track.id:${track.id}]');
    }

    // Get the SSRC for RTX.
    (offerMediaObject.ssrcGroups ?? []).any((SsrcGroup line) {
      if (line.semantics != 'FID') {
        return false;
      }

      List<String> ssrcs = line.ssrcs.split(' ');

      if (int.parse(ssrcs.first) == firstSsrc) {
        firstRtxSsrc = int.parse(ssrcs[1]);

        return true;
      } else {
        return false;
      }
    });

    Ssrc ssrcCnameLine = offerMediaObject.ssrcs.firstWhere(
      (Ssrc line) => line.attribute == 'cname' && line.id == firstSsrc,
      orElse: () => null,
    );

    if (ssrcCnameLine == null) {
      throw ('a=ssrc line with cname information not found [track.id:${track.id}]');
    }

    String cname = ssrcCnameLine.value;
    List<int> ssrcs = <int>[];
    List<int> rtxSsrcs = <int>[];

    for (int i = 0; i < numStreams; ++i) {
      ssrcs.add(firstSsrc + i);

      if (firstRtxSsrc != null) {
        rtxSsrcs.add(firstRtxSsrc + i);
      }
    }

    offerMediaObject.ssrcGroups = offerMediaObject.ssrcGroups ?? [];
    offerMediaObject.ssrcs = offerMediaObject.ssrcs ?? [];

    offerMediaObject.ssrcGroups.add(SsrcGroup(
      semantics: 'SIM',
      ssrcs: ssrcs.join(' '),
    ));

    for (int i = 0; i < ssrcs.length; ++i) {
      int ssrc = ssrcs[i];

      offerMediaObject.ssrcs.add(Ssrc(
        id: ssrc,
        attribute: 'cname',
        value: cname,
      ));

      offerMediaObject.ssrcs.add(Ssrc(
        id: ssrc,
        attribute: 'msid',
        value: '$streamId ${track.id}',
      ));
    }

    for (int i = 0; i < rtxSsrcs.length; ++i) {
      int ssrc = ssrcs[i];
      int rtxSsrc = rtxSsrcs[i];

      offerMediaObject.ssrcs.add(Ssrc(
        id: rtxSsrc,
        attribute: 'cname',
        value: cname,
      ));

      offerMediaObject.ssrcs.add(Ssrc(
        id: rtxSsrc,
        attribute: 'msid',
        value: '$streamId ${track.id}',
      ));

      offerMediaObject.ssrcGroups.add(SsrcGroup(
        semantics: 'FID',
        ssrcs: '$ssrc $rtxSsrc',
      ));
    }
  }
}
