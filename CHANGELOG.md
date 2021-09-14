# Changelog

--------------------------------------------
[0.4.5] - 14.09.2021

* fix(example): dispose renderers after leaving room;
* docs: update readme and changelog;

[0.4.4] - 09.09.2021

* feat: Consumer, Producer now have copyWith and new methods `pauseCopy`, `resumeCopy` which return new instance;
* fix: remote_sdp errors;

[0.4.3] - 28.08.2021

* fix: logger messages
* fix: transport.produce now use `appData` from arguments
* fix: iceCandidate's fields (raddr, rport) null savety 

[0.4.2] - 28.08.2021

* fix: RtcpFb
* refactor: replace firstWhere to firstWhereOrNull

Thanks [Macrow](https://github.com/Macrow)

[0.4.1] - 22.08.2021

* Remove `dart:io` dependency, so pub.dev will show web support

[0.4.0] - 22.08.2021

* Add Unified plan for Chrome.

[0.2.1] - 2021.08.05

* Add link to example in README.md

[0.2.0] - 2021.08.04

* Initial release.