class ProfileLevelId {
  int profile;
  int level;
  ProfileLevelId({this.profile, this.level});
}

// Class for converting between profile_idc/profile_iop to Profile.
class ProfilePattern {
  final profile_idc;
  final BitPattern profile_iop;
  final profile;

  const ProfilePattern(
    this.profile_idc,
    this.profile_iop,
    this.profile,
  );
}

// Class for matching bit patterns such as "x1xx0000" where 'x' is allowed to be
// either 0 or 1.
class BitPattern {
  var _mask;
  var _maskedValue;

  BitPattern(String str) {
    _mask = ~H264Utils.byteMaskString('x', str);
    _maskedValue = H264Utils.byteMaskString('1', str);
  }

  bool isMatch(value) => _maskedValue == (value & _mask);
}

// This is from https://tools.ietf.org/html/rfc6184#section-8.1.
List<ProfilePattern> ProfilePatterns = [
  ProfilePattern(
      0x42, BitPattern('x1xx0000'), H264Utils.ProfileConstrainedBaseline),
  ProfilePattern(
      0x4D, BitPattern('1xxx0000'), H264Utils.ProfileConstrainedBaseline),
  ProfilePattern(
      0x58, BitPattern('11xx0000'), H264Utils.ProfileConstrainedBaseline),
  ProfilePattern(0x42, BitPattern('x0xx0000'), H264Utils.ProfileBaseline),
  ProfilePattern(0x58, BitPattern('10xx0000'), H264Utils.ProfileBaseline),
  ProfilePattern(0x4D, BitPattern('0x0x0000'), H264Utils.ProfileMain),
  ProfilePattern(0x64, BitPattern('00000000'), H264Utils.ProfileHigh),
  ProfilePattern(0x64, BitPattern('00001100'), H264Utils.ProfileConstrainedHigh)
];

class H264Utils {
  // For level_idc=11 and profile_idc=0x42, 0x4D, or 0x58, the constraint set3
  // flag specifies if level 1b or level 1.1 is used.
  static const ConstraintSet3Flag = 0x10;
  // All values are equal to ten times the level number, except level 1b which is
  // special.
  static const int Level1_b = 0;
  static const int Level1 = 10;
  static const int Level1_1 = 11;
  static const int Level1_2 = 12;
  static const int Level1_3 = 13;
  static const int Level2 = 20;
  static const int Level2_1 = 21;
  static const int Level2_2 = 22;
  static const int Level3 = 30;
  static const int Level3_1 = 31;
  static const int Level3_2 = 32;
  static const int Level4 = 40;
  static const int Level4_1 = 41;
  static const int Level4_2 = 42;
  static const int Level5 = 50;
  static const int Level5_1 = 51;
  static const int Level5_2 = 52;

  static const int ProfileConstrainedBaseline = 1;
  static const int ProfileBaseline = 2;
  static const int ProfileMain = 3;
  static const int ProfileConstrainedHigh = 4;
  static const int ProfileHigh = 5;

  /// Convert a string of 8 characters into a byte where the positions containing
  /// character c will have their bit set. For example, c = 'x', str = "x1xx0000"
  /// will return 0b10110000.
  static dynamic byteMaskString(String c, String str) {
    int str0 = str[0] == c ? 1 : 0;
    int str1 = str[1] == c ? 1 : 0;
    int str2 = str[2] == c ? 1 : 0;
    int str3 = str[3] == c ? 1 : 0;
    int str4 = str[4] == c ? 1 : 0;
    int str5 = str[5] == c ? 1 : 0;
    int str6 = str[6] == c ? 1 : 0;
    int str7 = str[7] == c ? 1 : 0;

    return ((str0 << 7) |
        (str1 << 6) |
        (str2 << 5) |
        (str3 << 4) |
        (str4 << 3) |
        (str5 << 2) |
        (str6 << 1) |
        (str7 << 0));
  }

  static ProfileLevelId defaultProfileLevelId() {
    return ProfileLevelId(
      level: Level3_1,
      profile: ProfileConstrainedBaseline,
    );
  }

  static ProfileLevelId parseProfileLevelId(String str) {
    // The string should consist of 3 bytes in hexadecimal format.
    if (str == null || str.length != 6) {
      return null;
    }

    int profile_level_id_numeric = int.parse(str, radix: 16);

    if (profile_level_id_numeric == 0) {
      return null;
    }

    // Separate into three bytes.
    int level_idc = profile_level_id_numeric & 0xFF;
    int profile_iop = (profile_level_id_numeric >> 8) & 0xFF;
    int profile_idc = (profile_level_id_numeric >> 16) & 0xFF;

    // Prase level based on level_idc and constraint set 3 flag.
    var level;

    switch (level_idc) {
      case Level1_1:
        {
          level = (profile_iop & ConstraintSet3Flag) != 0 ? Level1_b : Level1_1;
          break;
        }
      case Level1:
      case Level1_2:
      case Level1_3:
      case Level2:
      case Level2_1:
      case Level2_2:
      case Level3:
      case Level3_1:
      case Level3_2:
      case Level4:
      case Level4_1:
      case Level4_2:
      case Level5:
      case Level5_1:
      case Level5_2:
        {
          level = level_idc;
          break;
        }

      // Unrecognized level_idc.
      default:
        {
          print('parseProfileLevelId() | unrecognized level_idc:$level_idc');

          return null;
        }
    }

    // Parse profile_idc/profile_iop into a Profile enum.
    for (ProfilePattern pattern in ProfilePatterns) {
      if (profile_idc == pattern.profile_idc &&
          pattern.profile_iop.isMatch(profile_iop)) {
        return ProfileLevelId(profile: pattern.profile, level: level);
      }
    }

    print(
        'parseProfileLevelId() | unrecognized profile_idc/profile_iop combination');

    return null;
  }

  static bool isLevelAsymmetryAllowed({Map<dynamic, dynamic> params = const {}}) {
    var level_asymmetry_allowed = params['level-asymmetry-allowed'];

    return (level_asymmetry_allowed == 1 || level_asymmetry_allowed == '1');
  }

  static ProfileLevelId parseSdpProfileLevelId(Map<dynamic, dynamic> params) {
    var profile_level_id = params['profile-level-id'];

    return profile_level_id == null
        ? defaultProfileLevelId()
        : parseProfileLevelId(profile_level_id);
  }

  static bool isSameProfile(Map<dynamic, dynamic> params1, Map<dynamic, dynamic> params2) {
    var profile_level_id_1 = parseSdpProfileLevelId(params1);
    var profile_level_id_2 = parseSdpProfileLevelId(params2);

    return profile_level_id_1 != null && profile_level_id_2 != null && profile_level_id_1.profile == profile_level_id_2.profile;
  }

  // Compare H264 levels and handle the level 1b case.
  static bool isLessLevel(int a , int b) {
    if (a == Level1_b) {
      return b != Level1 && b != Level1_b;
    }

    if (b == Level1_b) {
      return a != Level1;
    }

    return a < b;
  }

  static int minLevel(int a, int b) {
    return isLessLevel(a, b) ? a : b;
  }

  /// Returns canonical string representation as three hex bytes of the profile
  /// level id, or returns nothing for invalid profile level ids.
  /// @param {ProfileLevelId} profile_level_id
  /// @returns {String}
  static String profileLevelIdToString(ProfileLevelId profile_level_id) {
    // Handle special case level == 1b.
    if (profile_level_id.level == Level1_b) {
      switch (profile_level_id.profile) {
        case ProfileConstrainedBaseline: return '42f00b';
        case ProfileBaseline: return '42100b';
        case ProfileMain: return '4d100b';
        // level 1_b is not allowed for other profiles.
        default: {
          print('profileLevelidToString() | Level 1_b not is allowed for profile:${profile_level_id.profile}');

          return null;
        }
      }
    }

    String profile_idc_iop_string;

    switch(profile_level_id.profile) {
      case ProfileConstrainedBaseline: {
        profile_idc_iop_string = '42e0';
        break;
      }
      case ProfileBaseline: {
        profile_idc_iop_string = '4200';
        break;
      }
      case ProfileMain: {
        profile_idc_iop_string = '4d00';
        break;
      }
      case ProfileConstrainedHigh: {
        profile_idc_iop_string = '640c';
        break;
      }
      case ProfileHigh: {
        profile_idc_iop_string = '6400';
        break;
      }
      default: {
        print('profileLevelIdToString() | unrecognized profile:${profile_level_id.profile}');

        return null;
      }
    }

    String levelStr = profile_level_id.level.toRadixString(16);

    if (levelStr.length == 1) {
      levelStr = '0$levelStr';
    }

    return '$profile_idc_iop_string$levelStr';
  }

  static String generateProfileLevelIdForAnswer({
    Map<dynamic, dynamic> local_supported_params = const {},
    Map<dynamic, dynamic> remote_offered_params = const {},
  }) {
    // If both local and remote params do not contain profile-level-id, they are
	  // both using the default profile. In this case, don't return anything.
    if (local_supported_params['profile-level-id'] == null && remote_offered_params['profile-level-id'] == null) {
      print('generateProfileLevelIdForAnswer() | no profile-level-id in local and remote params');

      return null;
    }

    // Parse profile-level-ids.
    var local_profile_level_id = parseSdpProfileLevelId(local_supported_params);
    var remote_profile_level_id = parseSdpProfileLevelId(remote_offered_params);

    // The local and remote codec must have valid and equal H264 Profiles.
    if (local_profile_level_id == null) {
      throw('invalid local_profile_level_id');
    }
    if (remote_profile_level_id == null) {
      throw('invalid remote_profile_level_id');
    }

    if (local_profile_level_id.profile != local_profile_level_id.profile) {
      throw('H264 Profile mismatch');
    }

    // Parse level information.
    bool level_asymmetry_allowed = (isLevelAsymmetryAllowed(params: local_supported_params) && isLevelAsymmetryAllowed(params: remote_offered_params));

    int local_level = local_profile_level_id.level;
    int remote_level = remote_profile_level_id.level;
    int min_level = minLevel(local_level, remote_level);

    // Determine answer level. When level asymmetry is not allowed, level upgrade
	  // is not allowed, i.e., the level in the answer must be equal to or lower
	  // than the level in the offer.
    int answer_level = level_asymmetry_allowed ? local_level : min_level;

    print('generateProfileLevelIdForAnswer() | result: [profile:${local_profile_level_id.profile}, level:${answer_level}');

    // Return the resulting profile-level-id for the answer parameters.
    return profileLevelIdToString(ProfileLevelId(profile: local_profile_level_id.profile, level: answer_level,));
  }
}
