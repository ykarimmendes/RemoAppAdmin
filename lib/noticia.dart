import 'foto.dart';

class Noticia{

  Noticia(){
    fotoPrincipal = new Foto();
    fotos = new List<Foto>();
  }

  Foto fotoPrincipal;
  List<Foto> fotos;
  String titulo;
  String autor;
  String data;
  String texto;

}