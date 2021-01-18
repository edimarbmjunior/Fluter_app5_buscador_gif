import 'dart:convert';
import 'dart:io';

import 'package:app5buscadorgif/ui/gif_Page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offSet = 0;
  int _limit = 25;

  Future<Map> _getGifs() async {
    http.Response response;
    if((_search == null || _search.isEmpty)) {
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=7zymdBhbS5pRFq6F3sRlk6DG3UZkVgkz&limit=19&rating=PG");
    } else {
      String _urlPesquisa = "https://api.giphy.com/v1/gifs/search?api_key=7zymdBhbS5pRFq6F3sRlk6DG3UZkVgkz&q=$_search&limit=19&offset=$_offSet&rating=PG&lang=en";

      // metodo usando stream
      /*HttpClientRequest request = await HttpClient().getUrl(Uri.parse(_urlPesquisa));
      HttpClientResponse responseRequest = await request.close();
      Stream respStream = responseRequest.transform(utf8.decoder);
      await for(var data in respStream) {
        print(data);
      }*/

      // metodo usando Dio
      /*Response reponseDio = await Dio().request(_urlPesquisa);
      return reponseDio.data;*/

      //Metodo usando Dio
      response = await http.get(_urlPesquisa);
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(// Monta um widget com appBar
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(// Extente o filho para cobrir o resto da tela
              child: FutureBuilder(// Trabalha com futuro, podendo colocar uma tela de espera qnquanto não acaba o processamento de recuperação de dados
                future: _getGifs(),
                builder: (context, snapshot){//Vai construir ou a tela de espera ou a tela que se deseja mostrar os dados
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error ao carregar dados :(",
                            style: TextStyle(color: Colors.red, fontSize: 25.0),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                }
              ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data){
    if ((_search == null || _search.isEmpty)) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(//monta uma grade de informações
          crossAxisCount: 2, // quantos itens pode haver um do lado ao outro na tela
          crossAxisSpacing: 10.0, //Espaço entre as grades ao lado
          mainAxisSpacing: 10.0//Espaço entre as grades a cima e abaixo
        ),
        itemCount: _getCount(snapshot.data["data"]), // especifica a quantidade máxima que vai ser mostrada na grade
        itemBuilder: (context, index){
          if ((_search == null || _search.isEmpty) || index < snapshot.data["data"].length){
            return GestureDetector(//Habilita a ação de clicar na imagem
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                fit: BoxFit.cover,
                height: 300.0,
              ),
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: (){
                Share.share(
                    snapshot.data["data"][index]["images"]["fixed_height"]["url"]
                );
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                        Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Carregar mais ...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offSet += 19;
                  });
                },
              ),
            );
          }
        }
    );
  }
}
