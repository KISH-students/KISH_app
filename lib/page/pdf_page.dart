import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_indicators/progress_indicators.dart';

class PdfPage extends StatefulWidget {
  String url;
  String title;

  PdfPage(this.url, {this.title: "", Key key}) : super(key: key);

  @override
  _PdfPageState createState() {
    return _PdfPageState();
  }
}

class _PdfPageState extends State<PdfPage> {
  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
        msg: "페이지를 넘기려면 화면을 아래로 미세요", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title.replaceAll("\n", " "))),
          backgroundColor: Colors.black,
        ),
        body: PDF(
          swipeHorizontal: false,
          fitPolicy: FitPolicy.HEIGHT
        ).cachedFromUrl(
          widget.url,
          placeholder: (progress) => Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Text('$progress %')),
                    JumpingDotsProgressIndicator(
                      fontSize: 40.0,
                    ),
                  ])),
          errorWidget: (error) => Center(child: Text("불러올 수 없습니다.")),
        ));
  }
}
