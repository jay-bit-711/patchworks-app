import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/job.dart';

class EvidenceViewer extends StatefulWidget {
  final List<JobEvidence> evidence;
  const EvidenceViewer({super.key, required this.evidence});

  @override
  State<EvidenceViewer> createState() => _EvidenceViewerState();
}

class _EvidenceViewerState extends State<EvidenceViewer> {
  @override
  Widget build(BuildContext context) {
    if (widget.evidence.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text('No evidence uploaded yet', style: TextStyle(color: Colors.white24)),
        ),
      );
    }

    return Column(
      children: widget.evidence.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: e.type == 'video' 
            ? VideoPlayerWidget(url: e.url)
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  e.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.orange));
                  },
                ),
              ),
        );
      }).toList(),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.orange,
        handleColor: Colors.orangeAccent,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white10,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );
  }
}
