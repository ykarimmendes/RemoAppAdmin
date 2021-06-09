import 'dart:html';
import 'dart:typed_data';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppColor {
  static Color corPadrao = Color(0xff060D1D);
  static Color corAmarelo = Color(0xffB18000);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Image> imagens = new List<Image>();
  Image _imagemPricipal;
  Uint8List _arquivoPrincipal;
  final picker = ImagePicker();
  var tituloController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      backgroundColor: AppColor.corPadrao,
      appBar: AppBar(
        backgroundColor: AppColor.corPadrao,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Notícias",
                          style: TextStyle(
                              color: AppColor.corAmarelo,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      buildTextField("Titulo", 800, 85, Icons.title,
                          controller: tituloController),

                      Row(
                        children: [
                          buildTextField("Autor", 400, 30, Icons.person),
                          buildTextField("Data", 200, 10, Icons.calendar_today,
                              mask: "00/00/0000")
                        ],
                      ),
                      buildTextField("Texto", 800, 99999, Icons.title,
                          maximoLinhas: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(primary: AppColor.corAmarelo),
                            onPressed: () {
                              uploadPic(_arquivoPrincipal);
                            },
                            label: Text('Salvar'),
                            icon: Icon(Icons.save),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                buildExpanded(context),

              ],
            ),
          ),
        ),
      ),
    );
  }

  buildExpanded(BuildContext context) {
    return Expanded(
      flex: 30,
      child: Container(
        color: AppColor.corPadrao,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text("Imagem Principal", style: TextStyle(color: Colors.white),),
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 2,
              child: GestureDetector(
                onTap: getImage,
                child: Card(
                    elevation: 5,
                    child: _imagemPricipal == null
                        ? Center(
                            child: Text(
                              "Selecione a imagem principal",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.corAmarelo),
                            ),
                          )
                        : _imagemPricipal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: Text("Galeria da Notícia", style: TextStyle(color: Colors.white),),
            ),
            GestureDetector(
              onTap: getImages,
              child: Container(
                padding: EdgeInsets.only(left: 8,right: 8,top: 0),
                height: 30,
                child: Card(
                  child: Center(child: Text("Adicionar Imagem para Galeria", style: TextStyle(color: AppColor.corAmarelo),)),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: imagens.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(flex: 85,  child: imagens[index]),
                        Expanded(flex: 15, child: GestureDetector(onTap:(){
                          removerImagem(index);
                        }, child: Text("Remover", style: TextStyle(fontSize: 11, color: Colors.red),)))
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  getImage() async {
    final image = await picker.getImage(source: ImageSource.camera);
    //_arquivoPrincipal =new Blob(await image.readAsBytes());
    image.readAsBytes().then((value) => _arquivoPrincipal = value);

    setState(() {
      if (image != null) {
        if (true) {
          _imagemPricipal = Image.network(image.path);

      }
        } else {
          //_imagemPricipal = Image.file(File(pickedFile.path));
        }
      }
    );
  }

  Future getImages() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
        if (true) {
          imagens.add(Image.network(pickedFile.path));
        } else {
          //imagens.add(Image.file(File(pickedFile.path)));
        }
    });
  }

  Container buildTextField(String tituloCampo, double tamanhoTextField,
      int TamanhoMaximoText, IconData icon,
      {String mask = null,
      int maximoLinhas = 1,
      TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: tamanhoTextField,
      child: TextField(
        maxLines: maximoLinhas,
        controller: mask != null ? buildMask(mask) : controller,
        maxLength: TamanhoMaximoText,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          icon: Icon(icon),
          labelText: tituloCampo,
        ),
      ),
    );
  }

  MaskedTextController buildMask(String mask) {
    return MaskedTextController(mask: mask);
  }

  void removerImagem(int index) {
    setState(() {
      imagens.removeAt(index);
    });
  }

  Future uploadPic(Uint8List _image) async {
    final Reference storageReference = FirebaseStorage.instance.ref().child('Uploads/teste3.jpeg');
    TaskSnapshot uploadTask  = await storageReference.putData(_image, SettableMetadata(contentType: 'image/jpeg'));
    String docUrl = await uploadTask.ref.getDownloadURL();
  }
}