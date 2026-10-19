import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _schemeDirectory = 'ios/Runner.xcodeproj/xcshareddata/xcschemes';

String _scheme(String name) =>
    File('$_schemeDirectory/$name.xcscheme').readAsStringSync();

String _action(String scheme, String name) {
  final match = RegExp('<$name\\b[^>]*>').firstMatch(scheme);
  expect(match, isNotNull, reason: '$name must exist in the shared scheme');
  return match!.group(0)!;
}

String? _attribute(String tag, String name) =>
    RegExp('$name\\s*=\\s*"([^"]*)"').firstMatch(tag)?.group(1);

void main() {
  test('default Xcode Run builds a standalone release without LLDB', () {
    final launch = _action(_scheme('Runner'), 'LaunchAction');
    expect(_attribute(launch, 'buildConfiguration'), 'Release');
    expect(_attribute(launch, 'selectedDebuggerIdentifier'), isNull);
    expect(
      _attribute(launch, 'selectedLauncherIdentifier'),
      'Xcode.IDEFoundation.Launcher.PosixSpawn',
    );
    expect(_attribute(launch, 'customLLDBInitFile'), isNull);
  });

  test('explicit debug scheme keeps Flutter debugger support', () {
    final launch = _action(_scheme('Runner-Debug'), 'LaunchAction');
    expect(_attribute(launch, 'buildConfiguration'), 'Debug');
    expect(
      _attribute(launch, 'selectedDebuggerIdentifier'),
      'Xcode.DebuggerFoundation.Debugger.LLDB',
    );
    expect(
      _attribute(launch, 'selectedLauncherIdentifier'),
      'Xcode.DebuggerFoundation.Launcher.LLDB',
    );
    expect(
      _attribute(launch, 'customLLDBInitFile'),
      r'$(SRCROOT)/Flutter/ephemeral/flutter_lldbinit',
    );
  });

  test('both schemes retain Flutter preparation and native test setup', () {
    for (final name in ['Runner', 'Runner-Debug']) {
      final scheme = _scheme(name);
      expect(scheme, contains('xcode_backend.sh&quot; prepare'));
      expect(scheme, contains('BuildableName = "Runner.app"'));
      expect(scheme, contains('BuildableName = "RunnerTests.xctest"'));
      expect(
        _attribute(_action(scheme, 'TestAction'), 'buildConfiguration'),
        'Debug',
      );
      expect(
        _attribute(_action(scheme, 'ArchiveAction'), 'buildConfiguration'),
        'Release',
      );
    }
  });
}
