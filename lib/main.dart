import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'Model/filecheckModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String git_token="Bearer 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";

  TextEditingController textcon=new TextEditingController();

  String contenturl="https://api.github.com/repos/GoalDRoger/helloworld/contents";
  String rsspath="https://raw.githubusercontent.com/GoalDRoger/helloworld/main";
  String servertxt="From git";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.center,
            mainAxisAlignment:MainAxisAlignment.center,
            children: [

              Text(servertxt,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'ar')),

              Container(
                margin: EdgeInsets.only(top: 30),
                width: 370,
                height: 50,
                child: ElevatedButton(

                  onPressed: () {

                    Refresh();

                  },
                  child: Text('Refresh',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'ar')),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 10),
                child: TextField(

                  controller: textcon,
                  style:  TextStyle(
                    fontFamily: 'ar',
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  maxLines: null,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(

                    hintText: 'Your text',
                    hintStyle: const TextStyle(
                      fontFamily: 'ar',
                      color: Colors.brown,
                      fontSize: 16,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),

                    ),
                    filled: true,
                    //contentPadding: EdgeInsets.all(16),
                    fillColor:  Colors.white,
                  ),
                ),
              ),

              Container(
                width: 370,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                    Update();

                  },
                  child: Text('Create',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'ar')),
                ),
              ),



            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  List<filecheckModel> filelist=[];

  Future<void> Refresh() async {
    try {
      String url=contenturl+"/"+"home";

      var urlserver = Uri.parse(url);
      Response response = await get(urlserver);
    //  print(response.body.toString());
      List<dynamic> list = json.decode(response.body.toString());
      filelist = List<filecheckModel>.from(
          list.map((i) => filecheckModel.fromJson(i)));
      String? filename=filelist[0].name;

      String rawurl=rsspath+"/"+"home/"+filename.toString();
      var rawurlserver = Uri.parse(rawurl);
      Response responseraw = await get(rawurlserver);

      var myjson=json.decode(responseraw.body.toString());
      servertxt=myjson['title'];
      setState(() {

      });

    } catch (e) {
      print(e.toString());
    }

  }

  Future<void> Update() async {

    await Delete();
    await UpdateToserver();
    textcon.text="";
    await Refresh();

  }


  Future<String> _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.json');
    await file.writeAsString(text);
    String path = '${directory.path}/my_file.json';
    return path;
  }

  Future<void> Delete() async {

    try {
      for(int i=0;i<filelist.length;i++){
        var jsosn = {"message": 'Wow i am awesome', "sha": filelist[i].sha};
        Map<String, String> header = {
          "Authorization": git_token,
          // 'Content-type': 'application/json',
        };
        var urlserver = Uri.parse(filelist[i].url.toString());

        print(filelist[i].url);

        Response response =
            await delete(urlserver, body: json.encode(jsosn), headers: header);
        print(response.body.toString());

      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> UpdateToserver() async {
    var json1 = {
      "title": textcon.text.toString(),
    };

    String jsonarray = jsonEncode(json1);
    String filepath = await _write(jsonarray);



    try {
      final bytes = File(filepath).readAsBytesSync();
      String img64 = base64Encode(bytes);

      var jsosn = {
        "message": 'Wow i am awesome',
        "content": img64,
      };

      print(jsosn);

      var enc = json.encode(jsosn);
      Map<String, String> header = {
        "Authorization": git_token,
      };

      var urlserver = Uri.parse(contenturl  + "/home/"+DateTime.now().millisecondsSinceEpoch.toString()+".json");
      Response response = await put(urlserver, body: enc, headers: header);
      print("zzzz"+response.body.toString());

    } catch (e) {
      print(e.toString());
    }
  }

}
