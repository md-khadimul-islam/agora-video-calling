import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling/setting.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key, this.channelName, this.role});

  final String? channelName;
  final ClientRoleType? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await createAgoraRtcEngine();

    await _engine.initialize(const RtcEngineContext(
      appId: Token.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: Token.appToken,
      channelId: widget.channelName!,
      options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
      uid: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}

// final _user = <int>[];
// final _infoString = <String>[];
// bool mute = false;
// bool viewPanel = false;
// late RtcEngine _engine;
//
// @override
// void initState() {
//   initialize();
//   super.initState();
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('Video Call'),
//       centerTitle: true,
//     ),
//   );
// }
//
// @override
// void dispose() {
//   _user.clear();
//   _engine.leaveChannel();
//   super.dispose();
// }
//
// Widget _viewsRows() {
//   final List<StatefulWidget> list = [];
//   if (widget.role == ClientRoleType.clientRoleBroadcaster) {
//     list.add(rtc_local_view.SurfaceView());
//   }
// }
//
// Future<void> initialize() async {
//   if (Token.appId.isEmpty) {
//     setState(() {
//       _infoString.add('App id is missing please provide app id');
//       _infoString.add('agora engine is not starting');
//     });
//     return;
//   }
//
//   // Initialize the RtcEngine
//   // _engine =  await AgoraRtcEngine.create(Token.appId);
//   _engine = createAgoraRtcEngine(sharedNativeHandle: Token.appId);
//
//   // Enable video
//   await _engine.enableVideo();
//   await _engine
//       .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
//   await _engine.setClientRole(role: widget.role!);
//
//   // _addAgoraEventHandlers();
//
//   const VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//   // configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
//   await _engine.setVideoEncoderConfiguration(configuration);
//   await _engine.joinChannel(
//     token: Token.appToken,
//     channelId: widget.channelName!,
//     uid: 0,
//     options: ChannelMediaOptions(clientRoleType: widget.role),
//   );
// }
