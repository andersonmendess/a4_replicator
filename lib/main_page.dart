import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paperbuilder/main_page_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:printing/printing.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final bloc = MainPageBloc();

  void unFocus() {
    var currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Replicador A4"),
        elevation: 0,
        actions: [
          Visibility(
            visible: bloc.imageFile != null,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  bloc.reset();
                });
              },
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  _buildButton(
                    label: "SELECIONAR IMAGEM",
                    icon: Icons.image,
                    action: () async {
                      bloc.pickImage().then((_) => setState(() {}));
                    },
                  ),
                  bloc.imageFile?.path != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black.withOpacity(.1),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8)
                                .copyWith(left: 16, right: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                kIsWeb
                                    ? Image.network(bloc.imageFile.path,
                                        width: 80)
                                    : Image.file(File(bloc.imageFile.path),
                                        width: 80),
                                SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text(
                                      bloc.imageFile.path.split("/").last,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 15),
                  _buildSettingsContainer(),
                ],
              ),
            ),
          ),
          _buildButton(
            label: "GERAR",
            icon: Icons.picture_as_pdf,
            enabled: bloc.canRender,
            action: () async {
              unFocus();
              bloc.renderPDF().then((_) => setState(() {}));
            },
          ),
          _buildPdfPreview(),
        ],
      ),
    );
  }

  Widget _buildButton({
    String label,
    Function action,
    IconData icon,
    bool enabled = true,
  }) {
    return Center(
      child: ElevatedButton.icon(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.all(16).copyWith(top: 14, bottom: 14),
          ),
        ),
        icon: Icon(icon),
        onPressed: enabled ? action : null,
        label: Text(label),
      ),
    );
  }

  Container _buildSettingsContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black.withOpacity(.1),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 15),
          Text(
            "CONFIGURAÇÕES",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SwitchListTile(
            value: bloc.canSetHeight,
            onChanged: bloc.canSetWidth
                ? (value) {
                    setState(() {
                      bloc.canSetHeight = value;
                      bloc.heightTEC.clear();
                    });
                  }
                : null,
            title: Text("Proporção customizada"),
            subtitle: Text("Permite setar uma altura diferente da largura"),
          ),
          _buildTextField(),
        ],
      ),
    );
  }

  Padding _buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            child: TextField(
              keyboardType: TextInputType.number,
              enabled: bloc.canSetWidth,
              decoration: InputDecoration(
                labelText: "LARGURA (CM)",
                border: OutlineInputBorder(),
              ),
              style: TextStyle(),
              controller: bloc.widthTEC,
              onChanged: (String value) async {
                final cm = double.tryParse(value);

                if (cm != null && cm > 0) {
                  setState(() {
                    bloc.canRender = true;
                  });
                }
              },
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: TextField(
              keyboardType: TextInputType.number,
              enabled: bloc.canSetHeight,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "ALTURA (CM)",
              ),
              style: TextStyle(),
              controller: bloc.heightTEC,
            ),
          ),
        ],
      ),
    );
  }

  Visibility _buildPdfPreview() {
    return Visibility(
      visible: bloc.pdfContent != null,
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "PREVIEW",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 400,
            height: 620,
            child: PdfPreview(
              build: (format) async => bloc.pdfContent,
              initialPageFormat: PdfPageFormat.a4,
              canChangeOrientation: false,
              useActions: true,
              canChangePageFormat: false,
            ),
          ),
        ],
      ),
    );
  }
}
