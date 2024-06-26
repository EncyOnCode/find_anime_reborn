import 'package:breakpoint/breakpoint.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracemoe_repository/tracemoe_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../core/generated/localization/l10n.dart';


class ResultListItem extends StatelessWidget {
  const ResultListItem({
    super.key,
    required this.result,
    required this.device,
  });
  final Result result;
  final LayoutClass device;

  @override
  Widget build(BuildContext context) {
    final double verticalPadding = device == LayoutClass.desktop ? 12.0 : 8.0;
    final double horizontalPadding = device == LayoutClass.desktop ? 24.0 : 8.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 20.0,
              ),
              child: ResultTitleBlock(),
            ),
            ResultMediaViewer(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ResultInfoText(),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ResultEpisodeInfo(),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ResultButtonBar(),
            ),
          ],
        ),
      ),
    );
  }

  static Result getResultOf(BuildContext context) =>
      context.findAncestorWidgetOfExactType<ResultListItem>()!.result;
}

class ResultButtonBar extends StatelessWidget {
  const ResultButtonBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: [
        SizedBox(
          height: 42.0,
          child: OutlinedButton(
            onPressed: () => launchUrl(Uri.parse(
              'https://myanimelist.net/anime/${ResultListItem.getResultOf(context).idMal}',
            )),
            child: Text(S.of(context).viewInAnilist),
          ),
        ),
        SizedBox(
          height: 42.0,
          child: ElevatedButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: ResultListItem.getResultOf(context).romajiName ??
                      ResultListItem.getResultOf(context).japaneseName ??
                      '',
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(S.of(context).copiedText),
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Text(S.of(context).copyNameButton),
          ),
        ),
      ],
    );
  }
}

class ResultTitleBlock extends StatelessWidget {
  const ResultTitleBlock({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TextAvatar(
        shape: Shape.Circular,
        text: ResultListItem.getResultOf(context).romajiName ??
            S.of(context).noRomajiName,
      ),
      title: SelectableText(
        ResultListItem.getResultOf(context).romajiName ??
            S.of(context).noRomajiName,
        style: TextStyle(
          fontSize: 24.0,
          fontFamily: 'Roboto',
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      subtitle: SelectableText(
        ResultListItem.getResultOf(context).japaneseName ??
            S.of(context).noJapaneseName,
        style: TextStyle(
          fontSize: 14.0,
          fontFamily: 'Roboto',
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }
}

class ResultMediaViewer extends StatefulWidget {
  const ResultMediaViewer({
    super.key,
  });

  @override
  State<ResultMediaViewer> createState() => _ResultMediaViewerState();
}

class _ResultMediaViewerState extends State<ResultMediaViewer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      ResultListItem.getResultOf(context).video,
    )..initialize().then((value) {
        _controller.setVolume(0.0).then((_) => _controller.pause());
        setState;
      });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: constraints.maxWidth / 1.78, // 1.78 cuz aspect ratio is 16:9
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              MouseRegion(
                onExit: (event) async {
                  await _controller.setLooping(false);
                  await _controller.setVolume(0.0);
                  await _controller.pause();
                },
                onHover: (event) async {
                  await _controller.setLooping(true);
                  await _controller.setVolume(0.1);
                  await _controller.play();
                },
                child: VideoPlayer(
                  _controller,
                ),
              ),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ResultInfoText extends StatelessWidget {
  const ResultInfoText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S
              .of(context)
              .similarityText(ResultListItem.getResultOf(context).similarity),
          style: TextStyle(
            fontSize: 22.0,
            fontFamily: 'Roboto',
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        if (ResultListItem.getResultOf(context).adultOnly)
          Text(
            S.of(context).adultOnly,
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'Roboto',
              color: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}

class ResultEpisodeInfo extends StatelessWidget {
  const ResultEpisodeInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).episodeText(
                ResultListItem.getResultOf(context).episode.toInt(),
                prettyDuration(
                  Duration(
                    seconds: ResultListItem.getResultOf(context).moment.toInt(),
                  ),
                  abbreviated: true,
                ),
              ),
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: 'Roboto',
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
}
