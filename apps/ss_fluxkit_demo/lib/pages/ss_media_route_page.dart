import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_media/ss_media.dart';

import 'ss_media_demo_host.dart';

class SSMediaRoutePage extends StatelessWidget {
  const SSMediaRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media 演示')),
      body: const Column(
        children: [
          Expanded(child: SSMediaDemoHost()),
          _SSMediaUploadPanel(),
        ],
      ),
    );
  }
}

class _SSMediaUploadPanel extends ConsumerStatefulWidget {
  const _SSMediaUploadPanel();

  @override
  ConsumerState<_SSMediaUploadPanel> createState() =>
      _SSMediaUploadPanelState();
}

class _SSMediaUploadPanelState extends ConsumerState<_SSMediaUploadPanel> {
  String? _status;

  Future<void> _uploadDemoPng() async {
    if (SSEnv.config.useMock) {
      setState(() => _status = 'Mock 模式跳过真实上传');
      return;
    }
    setState(() => _status = '上传中…');
    final png = _minimalPng();
    final result =
        await ref.read(ssMediaUploadServiceProvider).uploadBytes(
              bytes: png,
              fileName: 'ssflux-demo.png',
              contentType: 'image/png',
            );
    setState(() {
      _status = result.when(
        success: (asset) => '上传成功: ${asset.id} ${asset.url ?? ""}',
        failure: (e) => '上传失败: ${e.message}',
      );
    });
  }

  List<int> _minimalPng() {
    return <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '真实 API 上传（presign + PUT + confirm）',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _uploadDemoPng,
              child: const Text('上传 1×1 PNG'),
            ),
            if (_status != null) ...[
              const SizedBox(height: 8),
              Text(_status!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
