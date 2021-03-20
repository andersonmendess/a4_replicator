import 'package:flutter/material.dart';
import 'package:paperbuilder/main_page_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final bloc = MainPageBloc();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Replicador A4"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                bloc.reset();
              });
            },
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
                  Center(
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.all(16),
                        ),
                      ),
                      icon: Icon(Icons.image),
                      onPressed: () async {
                        await bloc.pickImage();
                        setState(() {});
                      },
                      label: Text("SELECIONAR IMAGEM"),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "CONFIGURAÇÕES",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SwitchListTile(
                    value: bloc.canSetHeight,
                    onChanged: bloc.canSetWidth
                        ? (value) {
                            setState(() {
                              bloc.canSetHeight = value;
                            });
                          }
                        : null,
                    title: Text("Proporção customizada"),
                    subtitle:
                        Text("Permite setar uma altura diferente da largura"),
                  ),
                  Padding(
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
                            onChanged: (String value) async {
                              final cm = double.tryParse(value);

                              if (cm != null && cm > 0) {
                                bloc.widthCM = cm;
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
                            onChanged: (String value) async {
                              final cm = double.tryParse(value);

                              if (cm != null && cm > 0) {
                                bloc.heightCM = cm;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  EdgeInsets.all(16),
                ),
              ),
              onPressed: bloc.canRender
                  ? () async {
                      await bloc.renderPDF();
                      setState(() {});
                    }
                  : null,
              label: Text("GERAR"),
            ),
          ),
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
            height: 800,
            child: PdfPreview(
              build: (format) async => bloc.pdfContent,
              initialPageFormat: PdfPageFormat.a4,
              canChangeOrientation: false,
              useActions: true,
              canChangePageFormat: false,
            ),
          )
        ],
      ),
    );
  }
}
