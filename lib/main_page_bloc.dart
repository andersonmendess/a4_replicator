import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:paperbuilder/utils.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

class MainPageBloc {
  Uint8List pdfContent;
  PickedFile imageFile;
  final picker = ImagePicker();
  var doc = pw.Document();

  bool canSetWidth = false;
  bool canSetHeight = false;
  bool canRender = false;

  double widthCM;
  double heightCM;

  reset() {
    canSetWidth = false;
    canSetHeight = false;
    canRender = false;

    widthCM = null;
    heightCM = null;

    doc = pw.Document();
    pdfContent = null;
    imageFile = null;
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      imageFile = pickedFile;
      canSetWidth = true;
    } catch (e) {}
  }

  renderPDF() async {
    if (heightCM == null || heightCM == 0) heightCM = widthCM;

    final totalImages =
        getTotalImagesPerPageCount(width: widthCM, height: heightCM);

    final image = await imageFile.readAsBytes();
    doc = pw.Document();

    doc.addPage(
      pw.Page(
          margin: pw.EdgeInsets.all(8),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.GridView(
                crossAxisCount: getTotalImagesWidthCount(widthCM, heightCM),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  ...List.generate(
                    totalImages,
                    (index) => pw.Image(
                      pw.MemoryImage(image),
                      width: cm2pixels(widthCM),
                      height: cm2pixels(heightCM),
                    ),
                  ).toList()
                ]); // Center
          }),
    ); // Page

    pdfContent = await doc.save();
  }
}
