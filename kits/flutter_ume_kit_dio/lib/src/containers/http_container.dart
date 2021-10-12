///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/13/21 2:49 PM
///
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart' show RequestOptions, Response;

/// Implements a [ChangeNotifier] to notify listeners when new responses
/// were recorded. Use [page] to support paging.
class HttpContainer extends ChangeNotifier {
  /// Store all responses.
  List<Response<dynamic>> get requests => _requests;
  final List<Response<dynamic>> _requests = <Response<dynamic>>[];
  final List<String> breakPointList = <String>[
    // 'https://wanandroid.com/wxarticle/chapters/json'
    // 'https://wanandroid.com/wxarticle/list/405/1/json?k=Java'
    // 'https://www.wanandroid.com/tree/json'
  ];
  late GlobalKey<NavigatorState> navigatorKey;

  setNavigatorState1(GlobalKey<NavigatorState> navigatorKey) {
    this.navigatorKey = navigatorKey;
  }

  /// Paging fields.
  int get page => _page;
  int _page = 1;
  final int _perPage = 10;

  Future<RequestOptions> requestBreak(RequestOptions requestOptions) async {
    for (int i = 0; i < breakPointList.length; i++) {
      print('进入断点' + breakPointList[i] + '   ' + requestOptions.path);
      if (breakPointList[i] == requestOptions.path) {
        print('进入弹框' + breakPointList[i] + '   ' + requestOptions.path);
        return await _alertDialog(requestOptions);
      }
    }
    return requestOptions;
  }

  Future<Response<dynamic>> responsetBreak(
    Response<dynamic> response,
  ) async {
    for (int i = 0; i < breakPointList.length; i++) {
      if (breakPointList[i].contains(response.requestOptions.path)) {
        return await _alertResponseDialog(response);
      }
    }
    return response;
  }

  /// Return requests according to the paging.
  List<Response<dynamic>> get pagedRequests {
    return _requests.sublist(0, math.min(page * _perPage, _requests.length));
  }

  bool get _hasNextPage => _page * _perPage < _requests.length;

  void addRequest(Response<dynamic> response) {
    _requests.insert(0, response);
    notifyListeners();
  }

  void loadNextPage() {
    if (!_hasNextPage) {
      return;
    }
    _page++;
    notifyListeners();
  }

  void resetPaging() {
    _page = 1;
    notifyListeners();
  }

  void clearRequests() {
    _requests.clear();
    _page = 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _requests.clear();
    super.dispose();
  }

  Future<RequestOptions> _alertDialog(RequestOptions requestOptions) async {
    var result = await showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) {
          return AlertDialog(
            title: Text("响应信息"),
            content: Container(
              height: 300,
              child: ListView(
                // children: requestOptions.data.,
                children: _getChildrenWidget(requestOptions.data),
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                child: Text("取消"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  print("取消");
                  Navigator.pop(context, requestOptions);
                },
              ),
              RaisedButton(
                child: Text("确定"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  requestOptions.path =
                      'https://api.github.com/?_t=1633794707179&00';
                  Navigator.pop(context, requestOptions);
                },
              ),
            ],
          );
        });
    print("result   -- >  " + result.toString());
    return result;
  }

  Future<Response<dynamic>> _alertResponseDialog(
      Response<dynamic> response) async {
    var result = await showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) {
          return AlertDialog(
            title: Text("响应信息"),
            content: Container(
              height: 500,
              width: 300,
              child: ListView(
                // children: requestOptions.data.,
                children: _getChildrenWidget(response.data),
              ),
            ),
            actions: <Widget>[
              // RaisedButton(
              //   child: Text("取消"),
              //   color: Colors.blue,
              //   textColor: Colors.white,
              //   onPressed: () {
              //     print("取消");
              //     Navigator.pop(context, response);
              //   },
              // ),
              RaisedButton(
                child: Text("确定"),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context, response);
                },
              ),
            ],
          );
        });
    print("result   -- >  " + result.toString());
    return result;
  }

  List<Widget> _getChildrenWidget(Map map) {
    return map.keys.map((key) {
      var mapDataValue = map[key]; //map值
      if (!(mapDataValue is List)) {
        if (!(mapDataValue is Map)) {
          //map值不是list对象且不是map对象则直接显示item
          return getCommonItemWidget(map, key, mapDataValue.toString());
        } else {
          //map值不是list对象但是map对象 则需要间隔
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$key:  ',
                style: TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
              ...mapWidget(mapDataValue) //显示map对象内的字段
            ],
          );
        }
      } else {
        // return Text('是集合');
        List<Widget> widgets = [];
        mapDataValue.forEach((element) {
          widgets.add(SizedBox(
            height: 10,
          ));
          widgets.addAll(mapWidget(element));

        });
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '$key:  ',
            style: TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
          ...widgets
        ]);
      }
    }).toList();
  }

  List<Widget> mapWidget(Map<dynamic, dynamic> mapDataValue) {
    return mapDataValue.keys.map(
      (childMapKey) {
        if (!(mapDataValue[childMapKey] is List) &&
            !(mapDataValue[childMapKey] is Map)) {
          //值不是List 也不是 map
          return Container(
            padding: EdgeInsets.only(left: 10),
            child: getCommonItemWidget(
              mapDataValue,
              childMapKey,
              mapDataValue[childMapKey].toString(),
            ),
          );
        } else if (mapDataValue[childMapKey] is Map) {
          //是map
          return Column(
            children: mapWidget(mapDataValue[childMapKey]),
          ); //值任然是map的化 递归调用
        } else {
          //是集合
          List<Widget> widgets = [];
          mapDataValue[childMapKey].forEach((element) {
            widgets.add(SizedBox(
              height: 10,
            ));
            if (element is String) {
              var container = getOnlyListWidget(element);
              widgets.add(container);
            } else {
              widgets.addAll(mapWidget(element));
            }
            // widgets.add(SizedBox(
            //   height: 10,
            // ));
            // widgets.add(Container(height: 300,));
          });
          return Container(
            padding: EdgeInsets.only(left: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '$childMapKey:  ',
                style: TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
              ...widgets
            ]),
          );
        }
      },
    ).toList();
  }

  Container getOnlyListWidget(String element) {
    late TextEditingController _controller =
    new TextEditingController(text: element);
    return Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '$element:  ',
                style: TextStyle(fontSize: 14),
              ),
            );
  }

  Container getCommonItemWidget(Map map, String key, String value) {
    late TextEditingController _controller =
        new TextEditingController(text: value);
    return Container(
      height: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$key:  ',
            style: TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                if (map[key] is int) {
                  map[key] = int.parse(value);
                } else if (value is double) {
                  map[key] = double.parse(value);
                } else {
                  map[key] = value;
                }
              },
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              style: TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
