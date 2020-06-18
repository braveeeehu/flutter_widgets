import 'package:flutter/material.dart';
import 'package:flutterwidgets/input_field_view.dart';
import 'package:flutterwidgets/load_more_listview.dart';
import 'package:flutterwidgets/widget_banner.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widgets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider.value(value: ListProvider(),
      child: MyHomePage(),),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController _codeController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<String> _bannerUrls = ['https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=111726356,4048824664&fm=26&gp=0.jpg',
    'https://hbimg.huabanimg.com/60f198516cee4ab511cb190a85599d3e1d88302a4d1ba-iBehXn_fw658/format/webp',
  'https://hbimg.huabanimg.com/bb648839703471ebd822b359ff9c1c3aa63731ce17583-NZVF9g_fw658/format/webp',
  'https://hbimg.huabanimg.com/e290c6a5acdaba00ae73333b473074a41c9a4b431ebd0-00KuFb_fw658/format/webp',
  'https://hbimg.huabanimg.com/cc1c34b87d6bddbd39fddd5a320fc040cd1434f812d3d-xHgVYK_fw658/format/webp'];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Consumer<ListProvider>(builder: (context,p,child){
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Demo'),
                  background: CustomBanner(_bannerUrls),
                ),
              ),
              SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    InputField(placeHolder: '请输入手机号码',),
                    InputField(type: InputFieldType.idCard, placeHolder: '请输入证件号码'),
                    InputField(type: InputFieldType.password, placeHolder: '请输入密码'),
                    InputField(type: InputFieldType.code, placeHolder: '请输入验证码',onGetCode: (){
                      return Future.delayed(Duration(seconds: 2),(){
                        //模拟验证码网络请求
                        return true;
                      });
                    },),
                  ],),),),
              LoadMoreSliverList(
                itemBuilder: (context,index) => Container(height: 50,child: Center(child: Text(p.list[index])),),
                itemCount: p.list.length,
                hasMore: p.hasMore,
                onLoadMore: p.loadMore,
              ),
            ],
          );
        }),
      ),
    );
  }
}



class ListProvider extends ChangeNotifier {

  List<String> list = [];
  bool hasMore = true;

  int page = 2;

  Future loadMore(){
  return Future.delayed(Duration(seconds: 1),(){
      for(int i = 0; i< 10; i++) {
        list.add('content ${list.length}');
      }
      page --;
      hasMore = page <= 0 ? false : true;
      notifyListeners();
    });
  }
}