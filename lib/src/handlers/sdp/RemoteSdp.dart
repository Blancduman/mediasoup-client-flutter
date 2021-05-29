import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasoup_client_flutter/SdpTransform/SdpTransform.dart';
import 'package:mediasoup_client_flutter/src/Producer.dart';
import 'package:mediasoup_client_flutter/src/RtpParameters.dart';
import 'package:mediasoup_client_flutter/src/SctpParameters.dart';
import 'package:mediasoup_client_flutter/src/SdpObject.dart';
import 'package:mediasoup_client_flutter/src/Transport.dart';
import 'package:mediasoup_client_flutter/src/common/Logger.dart';
import 'package:mediasoup_client_flutter/src/handlers/sdp/MediaSection.dart';

Logger logger = Logger('RemoteSdp');

class MediaSectionIdx {
  int idx;
  String reuseMid;

  MediaSectionIdx({this.idx, this.reuseMid,});

  MediaSectionIdx.fromMap(Map data) {
    idx = data['idx'];
    reuseMid = data['reuseMid'];
  }

  Map<String, dynamic> toMap() {
    return {
      'idx': idx,
      'reuseMid': reuseMid,
    };
  }
}

class RemoteSdp {
  // Remote ICE parameters.
  IceParameters _iceParameters;
  // Remote ICE candidates.
  List<IceCandidate> _iceCandidates;
  // Remote DTLS parameters.
  DtlsParameters _dtlsParameters;
  // Remote SCTP parameters.
  SctpParameters _sctpParameters;
  // Parameters for plain RTP (no SRTP nor DTLS no BUNDLE).
  PlainRtpParameters _plainRtpParameters;
  // Whether this is Plan-B SDP.
  bool _planB;
  // MediaSection instances with same order as in the SDP.
  List<MediaSection> _mediaSections = <MediaSection>[];
  // MediaSection indices indexed by MID.
  Map<String, int> _midToIndex = <String, int>{};
  // First MID.
  String _firstMid;
  // SDP object.
  SdpObject _sdpObject;

  RemoteSdp({
    IceParameters iceParameters,
    List<IceCandidate> iceCandidates,
    DtlsParameters dtlsParameters,
    SctpParameters sctpParameters,
    PlainRtpParameters plainRtpParameters,
    bool planB,
  }) {
    _iceParameters = iceParameters;
    _iceCandidates = iceCandidates;
    _dtlsParameters = dtlsParameters;
    _sctpParameters = sctpParameters;
    _plainRtpParameters = plainRtpParameters;
    _planB = planB;
    _sdpObject = SdpObject(
      version: 0,
      origin: Origin(
        address: '0.0.0.0',
        ipVer: 4,
        netType: 'IN',
        sessionId: 10000,
        sessionVersion: 0,
        username: 'mediasoup-client',
      ),
      name: '-',
      timing: Timing(start: 0, stop: 0,),
      media: <MediaObject>[],
    );

    // If ICE parameters are given, add ICE-Lite indicator.
    if (iceParameters != null && iceParameters.iceLite) {
      _sdpObject.icelite = 'ice-lite';
    }

    // if DTLS parameters are given, assume WebRTC and BUNDLE.
    if (dtlsParameters != null) {
      _sdpObject.msidSemantic = MsidSemantic(
        semantic: 'WMS',
        token: '*',
      );

      // NOTE: We take the latest fingerprint.
      int numFingerprints = _dtlsParameters.fingerprints.length;

      _sdpObject.fingerprint = Fingerprint(
        type: dtlsParameters.fingerprints[numFingerprints - 1].algorithm,
        hash: dtlsParameters.fingerprints[numFingerprints - 1].value,
      );

      _sdpObject.groups = [Group(type: 'BUNDLE', mids: '',),];
    }

    // If there are plain RPT parameters, override SDP origin.
    if (plainRtpParameters != null) {
      _sdpObject.origin.address = plainRtpParameters.ip;
      _sdpObject.origin.ipVer = plainRtpParameters.ipVersion;
    }
  }

  String getSdp() {
    // Increase SDP version.
    _sdpObject.origin.sessionVersion++;

    return write(_sdpObject.toMap(), null);
  }

  void updateIceParameters(IceParameters iceParameters) {
    logger.debug(
      'updateIceParameters() [iceParameters:$iceParameters]',
    );

    _iceParameters = iceParameters;
    _sdpObject.icelite = iceParameters.iceLite ? 'ice-lite' : null;
    
    for (MediaSection mediaSection in _mediaSections) {
      mediaSection.setIceParameters(iceParameters);
    }
  }

  void updateDtlsRole(DtlsRole role) {
    logger.debug('updateDtlsRole() [role:$role]');

    _dtlsParameters.role = role;

    for (MediaSection mediaSection in _mediaSections) {
      mediaSection.setDtlsRole(role);
    }
  }

  void disableMediaSection(String mid) {
    int idx = _midToIndex[mid];

    if (idx == null) {
      throw('no media section found with mid "$mid"');
    }

    MediaSection mediaSection = _mediaSections[idx];

    mediaSection.disable();
  }

  void closeMediaSection(String mid) {
    int idx = _midToIndex[mid];

    if (idx == null) {
      throw('no media section found with mid "$mid"');
    }

    MediaSection mediaSection = _mediaSections[idx];

    // NOTE: Closing the first m section is a pain since it invalidates the
    // bundled transport, so let's avoid it.
    if (mid == _firstMid) {
      logger.debug(
        'closeMediaSection() | cannot close first media section, disabling it instead [mid: $mid]',
      );

      disableMediaSection(mid);

      return;
    }

    mediaSection.close();

    // Regenerate BUNDLE mids.
    _regenerateBundleMids();
  }

  void planBStopReceiving(
    String mid,
    RtpParameters offerRtpParameters,
  ) {
    int idx = _midToIndex[mid];

    if (idx == null) {
      throw('no media section found with mid "$mid"');
    }

    OfferMediaSection mediaSection = _mediaSections[idx];

    mediaSection.planBStopReceiving(offerRtpParameters: offerRtpParameters);
    _replaceMediaSection(mediaSection, null);
  }

  void send({
    MediaObject offerMediaObject,
    String reuseMid,
    RtpParameters offerRtpParameters,
    RtpParameters answerRtpParameters,
    ProducerCodecOptions codecOptions,
    bool extmapAllowMixed = false,
  }) {
    AnswerMediaSection mediaSection = AnswerMediaSection(
      iceParameters: _iceParameters,
      iceCandidates: _iceCandidates,
      dtlsParameters: _dtlsParameters,
      plainRtpParameters: _plainRtpParameters,
      planB: _planB,
      offerMediaObject: offerMediaObject,
      offerRtpParameters: offerRtpParameters,
      answerRtpParameters: answerRtpParameters,
      codecOptions: codecOptions,
      extmapAllowMixed: extmapAllowMixed,
    );

    // Unified-Plan with closed media section replacement.
    if (reuseMid != null) {
      _replaceMediaSection(mediaSection, reuseMid);
    } else if (!_midToIndex.containsKey(mediaSection.mid)) { // Unified-Plann or Plan-B with different media kind.
      _addMediaSection(mediaSection);
    } else { // Plan-B with same media kind.
      _replaceMediaSection(mediaSection, null);
    }
  }

  void receive({
    String mid,
    RTCRtpMediaType kind,
    RtpParameters offerRtpParameters,
    String streamId,
    String trackId,
  }) {
    int idx = _midToIndex[mid];
    OfferMediaSection mediaSection;

    if (idx != null) {
      mediaSection = _mediaSections[idx];
    }

    // Unified-Plan or different media kind.
    if (mediaSection == null) {
      mediaSection = OfferMediaSection(
        iceParameters: _iceParameters,
        iceCandidates: _iceCandidates,
        dtlsParameters: _dtlsParameters,
        plainRtpParameters: _plainRtpParameters,
        planB: _planB,
        mid: mid,
        kind: RTCRtpMediaTypeExtension.value(kind),
        offerRtpParameters: offerRtpParameters,
        streamId: streamId,
        trackId: trackId,
      );

      // Let's try to recycle a closed media section (if any).
      // NOTE: Yes, we can recycle a closed m=audio section with a new m=video.
      MediaSection oldMediaSection = _mediaSections.firstWhere((MediaSection m) => m.closed, orElse: () => null,);

      if (oldMediaSection != null) {
        _replaceMediaSection(mediaSection, oldMediaSection.mid);
      } else {
        _addMediaSection(mediaSection);
      }
    } else { // Plan-B.
      mediaSection.planBReceive(
        offerRtpParameters: offerRtpParameters,
        streamId: streamId,
        trackId: trackId,
      );

      _replaceMediaSection(mediaSection, null);
    }
  }

  void sendSctpAssociation(MediaObject offerMediaObject) {
    AnswerMediaSection mediaSection = AnswerMediaSection(
      iceParameters: _iceParameters,
      iceCandidates: _iceCandidates,
      dtlsParameters: _dtlsParameters,
      plainRtpParameters: _plainRtpParameters,
      offerMediaObject: offerMediaObject,
    );

    _addMediaSection(mediaSection);
  }

  void receiveSctpAssociation({bool oldDataChannelSpec = false}) {
    OfferMediaSection mediaSection = OfferMediaSection(
      iceParameters:  _iceParameters,
      iceCandidates: _iceCandidates,
      dtlsParameters: _dtlsParameters,
      sctpParameters: _sctpParameters,
      plainRtpParameters: _plainRtpParameters,
      mid: 'datachannel',
      kind: 'application',
      oldDataChannelSpec: oldDataChannelSpec,
    );

    _addMediaSection(mediaSection);
  }

  MediaSectionIdx getNextMediaSectionIdx() {
    // If a closed media section is found, return its index.
    for (int idx = 0; idx < _mediaSections.length; ++idx) {
      MediaSection mediaSection = _mediaSections[idx];

      if (mediaSection.closed) {
        return MediaSectionIdx(idx: idx, reuseMid: mediaSection.mid,);
      }
    }

    // If no closed media section is found, return next one.
    return MediaSectionIdx(idx: _mediaSections.length);
  }

  void _regenerateBundleMids() {
    if (_dtlsParameters == null) {
      return;
    }

    _sdpObject.groups[0].mids = _mediaSections
      .where((MediaSection mediaSection) => !mediaSection.closed)
      .map((MediaSection mediaSection) => mediaSection.mid)
      .join(' ');
  }

  void _addMediaSection(MediaSection newMediaSection) {
    if (_firstMid == null) {
      _firstMid = newMediaSection.mid;
    }

    // Add to the vector.
    _mediaSections.add(newMediaSection);

    // Add to the map.
    _midToIndex[newMediaSection.mid] = _mediaSections.length - 1;

    // Add to the SDP object.
    _sdpObject.media.add(newMediaSection.getObject);

    // Regenrate Bundle mids.
    _regenerateBundleMids();
  }

  void _replaceMediaSection(MediaSection newMediaSection, dynamic reuseMid) {
    // Store it in the map.
    if (reuseMid is String) {
      int idx = _midToIndex[reuseMid];

      if (idx == null) {
        throw('no media section found for reuseMid "$reuseMid"');
      }

      MediaSection oldMediaSection = _mediaSections[idx];

      // Replace the index in the vector with the new media section.
      _mediaSections[idx] =newMediaSection;

      // Update the map.
      _midToIndex.remove(oldMediaSection.mid);
      _midToIndex[newMediaSection.mid] = idx;

      // Update the SDP object.
      _sdpObject.media[idx] = newMediaSection.getObject;

      // Regenerate BUNDLE mids.
      _regenerateBundleMids();
    } else {
      int idx = _midToIndex[newMediaSection.mid];

      if (idx == null) {
        throw('no media section found with mid "${newMediaSection.mid}"');
      }

      // Replace the index in the vector with the new media section.
      _mediaSections[idx] = newMediaSection;

      // Update the SDP object.
      _sdpObject.media[idx] = newMediaSection.getObject;
    }
  }
}