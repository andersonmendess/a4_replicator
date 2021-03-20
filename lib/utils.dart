import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:paperbuilder/constants.dart';

int getTotalImagesPerPageCount({double width, double height}) {
  return getTotalImagesHeightCount(width, height) *
      getTotalImagesWidthCount(width, height);
}

int getTotalImagesHeightCount(double width, double height) {
  int size = 0;

  while ((size * height) < A4_SIZE_HEIGHT_CM) size++;

  return size - 1;
}

int getTotalImagesWidthCount(double width, double height) {
  int size = 0;

  while ((size * width) < A4_SIZE_WIDTH_CM) size++;

  return size - 1;
}

double cm2pixels(double cm) {
  if (cm == null) return null;
  return cm * PIXEL_PER_CM;
}

Uint8List resizeImage(Uint8List imageBytes, {double width, double height}) {
  final image = decodeImage(imageBytes);

  final newimage = copyResize(
    image,
    width: width?.toInt(),
    height: height?.toInt(),
  );

  return encodeJpg(newimage);
}
