import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling/view/call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _channelController = TextEditingController();
  bool _validateError = false;
  ClientRoleType? _role = ClientRoleType.clientRoleBroadcaster;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call'), centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _channelController,
                decoration: InputDecoration(
                    errorText:
                        _validateError ? 'Channel name is mandatory' : null,
                    hintText: 'Channel name'),
              ),
              RadioListTile(
                title: const Text('Broadcaster'),
                value: ClientRoleType.clientRoleBroadcaster,
                groupValue: _role,
                onChanged: (ClientRoleType? value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
              RadioListTile(
                title: const Text('Audience'),
                value: ClientRoleType.clientRoleAudience,
                groupValue: _role,
                onChanged: (ClientRoleType? value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
              ElevatedButton(onPressed: onJoin, child: const Text('Join'))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  Future<void> onJoin() async {
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(
              channelName: _channelController.text,
              role: _role,
            ),
          ));
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }
}
