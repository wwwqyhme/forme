import 'package:flutter/material.dart';

import 'forme_file.dart';

class Thumbnail extends StatefulWidget {
  final FormeFile file;
  final BoxFit fit;
  final Widget Function(
    BuildContext context,
    FormeFile item,
  ) imageLoadingBuilder;
  final Widget Function(
      BuildContext context,
      FormeFile item,
      VoidCallback retry,
      Object error,
      StackTrace? stackTrace) imageLoadingErrorBuilder;
  const Thumbnail({
    Key? key,
    required this.file,
    required this.fit,
    required this.imageLoadingBuilder,
    required this.imageLoadingErrorBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<Thumbnail> {
  late Future<ImageProvider> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.file.thumbnail;
  }

  void _retry() {
    setState(() {
      _future = widget.file.thumbnail;
    });
  }

  Widget _thumbnail(ImageProvider provider, FormeFile item) {
    return Image(
      image: provider,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return widget.imageLoadingErrorBuilder(
            context, item, _retry, error, stackTrace);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget thumbnail;
    // if (widget.file.cache != null) {
    //   thumbnail = _thumbnail(widget.file.cache!, widget.file);
    // } else {
    thumbnail = FutureBuilder<ImageProvider>(
      future: _future,
      builder: (context, builder) {
        if (builder.connectionState == ConnectionState.waiting) {
          return widget.imageLoadingBuilder(context, widget.file);
        } else {
          if (builder.hasError) {
            return widget.imageLoadingErrorBuilder(context, widget.file, _retry,
                builder.error!, builder.stackTrace);
          }
          if (builder.hasData) {
            widget.file.cache = builder.data;
            return _thumbnail(builder.data!, widget.file);
          }
        }
        return const SizedBox.shrink();
      },
    );
    // }
    return thumbnail;
  }
}
