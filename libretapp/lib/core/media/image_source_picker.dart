/// Shared Camera/Gallery source selector.
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<ImageSource?> showImageSourcePicker(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<ImageSource>(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.mediaTakePhoto),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.mediaChooseGallery),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}
