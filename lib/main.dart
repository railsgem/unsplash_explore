import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        primarySwatch: Colors.red
      ),
      home: MyHomePage(title: 'UnSplash Viwer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List items;
  List data;
  String lastItemId = 'uZH_r4I7law';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _buildPaginatedListView(),
    );
  }
  Widget _buildPaginatedListView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading && scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  this.getJSONData();
                  // start loading data
                  setState(() {
                    isLoading = true;
                  });
                }
              },
          child: _buildListView(),
          )
        ),
        Container(
          height: isLoading ? 50.0 : 0,
          color: Colors.white70,
          child: Center(
            child: new CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: data == null ? 0 : data.length,
      itemBuilder: (context, index) {
        return _buildImageColumn(data[index]);
        // ListTile(title: Text("data"), subtitle: Text("likes: 1"),);
      },
    );
  }

  Widget _imagePlaceHolder() {
    return Container(
      height: 200,
      child: SizedBox(height: 600,),
    );
  }
  Widget _buildImageColumn(item) => Container(
    decoration: BoxDecoration(
      color: Colors.white
    ),
    margin: const EdgeInsets.only(bottom: 8.0),
    child: Column(
      children: <Widget>[
        new CachedNetworkImage(
            imageUrl: item['urls']['regular'],
            placeholder: (context, url) => _imagePlaceHolder(),
            // new CircularProgressIndicator(),
            errorWidget: (context, url, error) => new Icon(Icons.error),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(item['user']['profile_image']['large']),
          ),
          title: Text(item['user']['name'], style: TextStyle(fontWeight: FontWeight.bold),), 
          subtitle: Text('@' + item['user']['username']),
          trailing: Icon(Icons.favorite_border),
          ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    // call get json data function 
    this.getJSONData();
  }

  Future<String> getJSONData()  async {
    try {
      var url = "https://unsplash.com/napi/photos/"+ lastItemId + "/related";

      // Await the http get response, then decode the json-formatted responce.
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        setState(() {
          List newItems = jsonResponse['results'];
          if (data == null) {
            data = newItems;
          } else {
            data.addAll( newItems);
          }
          lastItemId = data.last['id'];
          isLoading = false;
        });
        print(data.toString());
        print(lastItemId);
        return "sucessful";
      } else {
        print("Request failed with status: ${response.statusCode}.");
      }
    } on Exception catch (error) {
      debugPrint(error.toString());
    }
  }
}
