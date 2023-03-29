import 'package:bit_updater/const/enums.dart';
import 'package:bit_updater/cubit/bit_updater_cubit.dart';
import 'package:bit_updater/services/bit_updater_service.dart';
import 'package:bit_updater/services/locator_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../models/update_model.dart';

class BitUpdaterDialog extends StatefulWidget {
  BitUpdaterDialog({
    Key? key,
    required this.context,
    required this.titleText,
    required this.contentText,
    required this.checkBoxText,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.downloadUrl,
    this.dialogShape,
    this.dialogAlignment,
    this.dialogBackgroundColor,
    this.dialogTextColor,
    this.dialogElevation,
    this.dialogClipBehavior,
    this.dialogInsetAnimationCurve,
    this.dialogInsetAnimationDuration,
    this.dialogInsetPadding,
  }) : super(key: key);

  final BuildContext context;
  final String titleText;
  final String contentText;
  final String checkBoxText;
  final String confirmButtonText;
  final String cancelButtonText;
  final String downloadUrl;
  ShapeBorder? dialogShape;
  AlignmentGeometry? dialogAlignment;
  Color? dialogBackgroundColor;
  Color? dialogTextColor;
  double? dialogElevation;
  Clip? dialogClipBehavior;
  Curve? dialogInsetAnimationCurve;
  Duration? dialogInsetAnimationDuration;
  EdgeInsets? dialogInsetPadding;

  @override
  State<BitUpdaterDialog> createState() => _BitUpdaterDialogState();
}

class _BitUpdaterDialogState extends State<BitUpdaterDialog> {
  double progress = 0.0;
  String progressPercent = "";
  String progressSize = "";

  bool _changeDialog = false;
  var token = CancelToken();
  bool checkBoxValue = false;

  UpdateModel updateModel = bitUpdaterGetIt<BitUpdaterCubit>().updateModel;

  @override
  void dispose() {
    progress = 0.0;
    progressPercent = "";
    progressSize = "";

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Dialog(
        shape: widget.dialogShape,
        alignment: widget.dialogAlignment,
        backgroundColor: widget.dialogBackgroundColor,
        elevation: widget.dialogElevation,
        clipBehavior: widget.dialogClipBehavior ?? Clip.none,
        insetAnimationCurve: widget.dialogInsetAnimationCurve ?? Curves.easeIn,
        insetAnimationDuration: widget.dialogInsetAnimationDuration ??
            const Duration(milliseconds: 100),
        insetPadding: widget.dialogInsetPadding,
        child: _changeDialog ? _downloadContent() : _updateContent(),
      ),
    );
  }

  Widget _updateContent() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text(
              widget.titleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.dialogTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
          ),
          const SizedBox(
            height: 8,
          ),
          // widget.content,
          Container(
            child: Text(
              widget.contentText,
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.dialogTextColor),
            ),
            alignment: Alignment.center,
          ),
          const SizedBox(
            height: 18,
          ),
          if (!updateModel.isUpdateForced!) ...[_buildCheckBox()],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _changeDialog = true;
                  });
                  if (Platform.isIOS) {
                    _launchUrl(updateModel.downloadUrl!);
                  } else if (bitUpdaterGetIt<BitUpdaterService>()
                      .launchUrlInsteadOfDownloading) {
                    _launchUrl(updateModel.downloadUrl!);
                  } else {
                    bitUpdaterGetIt<BitUpdaterCubit>()
                        .changeUpdateStatus(UpdateStatus.pending);
                    bitUpdaterGetIt<BitUpdaterService>().downloadApp();
                  }
                },
                icon: const Icon(Icons.upgrade),
                label: Text(
                  widget.confirmButtonText,
                  style: TextStyle(color: widget.dialogTextColor),
                ),
              ),
              if (!updateModel.isUpdateForced!)
                OutlinedButton.icon(
                  onPressed: () {
                    bitUpdaterGetIt<BitUpdaterCubit>()
                        .changeUpdateStatus(UpdateStatus.dialogDismissed);
                    _dismiss();
                  },
                  icon: const Icon(Icons.cancel),
                  label: Text(
                    widget.cancelButtonText,
                    style: TextStyle(color: widget.dialogTextColor),
                  ),
                ),
              if (updateModel.isUpdateForced!)
                OutlinedButton.icon(
                  onPressed: () => exit(1),
                  icon: const Icon(Icons.logout),
                  label: const Text("Exit"),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downloadContent() {
    return BlocBuilder<BitUpdaterCubit, BitUpdaterState>(
      bloc: bitUpdaterGetIt<BitUpdaterCubit>(),
      builder: (context, state) {
        if (state is DownloadProgressState) {
          var percent = state.current * 100 / state.total;
          progress = state.current / state.total;
          progressPercent = "${percent.toStringAsFixed(2)} %";
          progressSize =
              '${_formatBytes(state.current, 1)} / ${_formatBytes(state.total, 1)}';

          if (state.current == state.total) {
            _dismiss();
          }
        }
        return Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Downloading...',
                style: TextStyle(
                  color: widget.dialogTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progressSize,
                    style: TextStyle(
                        color: widget.dialogTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    progressPercent,
                    style: TextStyle(
                        color: widget.dialogTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress == 0.0 ? null : progress,
                      //backgroundColor: Colors.grey,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      bitUpdaterGetIt<BitUpdaterService>().token.cancel();
                      bitUpdaterGetIt<BitUpdaterCubit>()
                          .changeUpdateStatus(UpdateStatus.cancelled);
                      _dismiss();
                      if (updateModel.isUpdateForced!) {
                        exit(1);
                      }
                    },
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.clear_rounded,
                      color: widget.dialogTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckBox() {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.checkBoxText,
            style: TextStyle(color: widget.dialogTextColor),
          ),
          Checkbox(
            side: BorderSide(color: widget.dialogTextColor ?? Colors.black),
            value: checkBoxValue,
            onChanged: (bool? value) {
              setState(() {
                checkBoxValue = value!;
              });
              bitUpdaterGetIt<BitUpdaterCubit>().setDismissedVersion(value!
                  ? int.parse(updateModel.latestVersion!.replaceAll(".", ""))
                  : 0);
            },
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    String formattedByte =
        ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
    return formattedByte;
  }

  _dismiss() {
    Navigator.of(context).pop();
    bitUpdaterGetIt<BitUpdaterCubit>().disposeBitUpdater();
  }

  _launchUrl(String url) async {
    if (await launchUrl(Uri.parse(url))) {
      throw "Could not launch ${updateModel.downloadUrl}";
    }
  }
}
