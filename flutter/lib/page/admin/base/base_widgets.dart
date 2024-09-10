import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/container_config.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file.dart';
import 'package:flutter_smart_genome/page/admin/track/track_file_type.dart';

Widget simpleTip(String msg, {Color color = Colors.black, Color? backgroundColor}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(Icons.error, size: 36, color: color),
      SizedBox(width: 10),
      Container(
        decoration: BoxDecoration(
          // border: Border.all(color: color, width: 1.0),
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text(
          msg,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ),
    ],
  );
}

Widget UnknownFilesDialog(BuildContext context, List<TrackFile> unknownFiles) {
  return AlertDialog(
    title: Text('Warning! unknown type files will be ignored!\nStill commit ?'),
    content: Container(
      constraints: BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(
                tiles: unknownFiles.map((e) => ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      title: Text(e.remoteFile.path!),
                      onTap: () {},
                      dense: true,
                      trailing: FileTypeWidget(e.remoteFile.fileType),
                    )),
                context: context)
            .toList(),
      ),
    ),
    actions: [
      ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('No, Back to set type')),
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('Ignore and Commit')),
    ],
  );
}

Widget FileTypeWidget(TrackFileType? type) {
  bool isFasta = type == TrackFileType.fasta;
  var color = isFasta ? Colors.green : trackFileColorMapper[type];
  return Container(
    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    decoration: BoxDecoration(
      color: color ?? Colors.red.shade800,
      borderRadius: BorderRadius.circular(4),
      // border:isUnknown ? null: Border.all(color: color),
    ),
    child: Text(
      '${type ?? 'unknown'}'.split('.').last,
      style: TextStyle(color: Colors.white, fontFamily: MONOSPACED_FONT, fontFamilyFallback: MONOSPACED_FONT_BACK),
    ),
  );
}
