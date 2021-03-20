import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paperbuilder/utils.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

class MainPageBloc {
  final picker = ImagePicker();
  PickedFile pickedFileImage;
  Uint8List pickedFileImageBytes;

  var doc = pw.Document();
  Uint8List pdfContent;

  Uint8List resizedImageBytes;

  bool canSetWidth = false;
  bool canSetHeight = false;
  bool canRender = false;
  bool isLoading = false;

  var widthTEC = TextEditingController();
  var heightTEC = TextEditingController();

  reset() {
    canSetWidth = false;
    canSetHeight = false;
    canRender = false;

    widthTEC.clear();
    heightTEC.clear();

    doc = pw.Document();
    pdfContent = null;
    pickedFileImage = null;
    pickedFileImageBytes = null;
    resizedImageBytes = null;
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
      reset();
      pickedFileImage = pickedFile;
      canSetWidth = true;
      pickedFileImageBytes = await pickedFile.readAsBytes();
    } catch (e) {
      print(e);
    }
  }

  resize() async {
    var heightCM = double.tryParse(heightTEC.text);
    var widthCM = double.tryParse(widthTEC.text);

    resizedImageBytes = resizeImage(
      pickedFileImageBytes,
      width: cm2pixels(widthCM),
      height: cm2pixels(heightCM),
    );
  }

  renderPDF() async {
    resize();

    if (resizedImageBytes == null) return;

    var heightCM = double.tryParse(heightTEC.text);
    var widthCM = double.tryParse(widthTEC.text);

    if (heightCM == null || heightCM == 0) heightCM = widthCM;

    final totalImages =
        getTotalImagesPerPageCount(width: widthCM, height: heightCM);

    doc = pw.Document();

    doc.addPage(
      pw.Page(
          margin: pw.EdgeInsets.all(10),
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
                      pw.MemoryImage(resizedImageBytes),
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
