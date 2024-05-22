import 'dart:io';
import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  final dio = Dio();

  print('Enter YouTube video URL:');
  String? url = stdin.readLineSync();

  if (url == null || url.isEmpty) {
    print('Invalid URL.');
    return;
  }

  try {
    var video = await yt.videos.get(url);
    var manifest = await yt.videos.streamsClient.getManifest(video.id);
    var streamInfo = manifest.muxed.withHighestBitrate();

    if (streamInfo != null) {
      var stream = yt.videos.streamsClient.get(streamInfo);
      var filePath = 'downloads/${video.title}.mp4';

      print('Downloading ${video.title}...');

      var file = File(filePath);
      await file.create(recursive: true);
      var fileSink = file.openWrite();

      await stream.pipe(fileSink);
      await fileSink.flush();
      await fileSink.close();

      print('Downloaded to $filePath');
    } else {
      print('No suitable stream found.');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    yt.close();
  }
}

