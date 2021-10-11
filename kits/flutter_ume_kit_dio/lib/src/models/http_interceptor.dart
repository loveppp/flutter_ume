///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/13/21 1:58 PM
///
import 'package:dio/dio.dart' ;


import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../instances.dart';


int get _timestamp => DateTime.now().millisecondsSinceEpoch;

/// Implement a [Interceptor] to handle dio methods.
///
/// Main idea about this interceptor:
///  - Use [RequestOptions.extra] to store our timestamps.
///  - Add [DIO_EXTRA_START_TIME] when a request was requested.
///  - Add [DIO_EXTRA_END_TIME] when a response is respond or thrown an error.
///  - Deliver the [Response] to the container.
class UMEDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    options.extra[DIO_EXTRA_START_TIME] = _timestamp;
    // InspectorInstance.httpContainer.breakPointList.forEach((element) {
    //   if (options.path == element) {
    //     options.path = 'https://api.github.com/?_t=1633794707179&0';
    //   }
    // });
    // var requestOptions = await InspectorInstance.httpContainer.requestBreak(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async{
    response.requestOptions.extra[DIO_EXTRA_END_TIME] = _timestamp;
    var requestOptions = await InspectorInstance.httpContainer.responsetBreak(response);
    InspectorInstance.httpContainer.addRequest(requestOptions);
    handler.next(requestOptions);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Create an empty response with the [RequestOptions] for delivery.
    err.response ??= Response<dynamic>(requestOptions: err.requestOptions);
    err.response!.requestOptions.extra[DIO_EXTRA_END_TIME] = _timestamp;
    InspectorInstance.httpContainer.addRequest(err.response!);
    handler.next(err);
  }
}



