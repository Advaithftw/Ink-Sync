import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

class MeetingScreen extends StatefulWidget {
  final String documentId;
  const MeetingScreen({super.key, required this.documentId});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  void initState() {
    super.initState();
    joinMeeting();
  }

  void joinMeeting() async {
    try {
      final options = JitsiMeetingOptions(
        roomNameOrUrl: widget.documentId,
        userDisplayName: 'Collaborator',
        isAudioMuted: false,
        isVideoMuted: false,
        featureFlags: {
          'isWelcomePageEnabled': false,
        },
      );

      await JitsiMeetWrapper.joinMeeting(options: options);
    } catch (error) {
      print("❌ Error joining meeting: $error");
    }
  }

  @override
  void dispose() {
    super.dispose();
    // No removeAllListeners method in jitsi_meet_wrapper as of latest version
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Joining meeting '${widget.documentId}'...")),
    );
  }
}
