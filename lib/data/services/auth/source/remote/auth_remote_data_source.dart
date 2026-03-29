import 'package:dio/dio.dart';
import 'package:flutter_template/data/request_objects/login_request/login_request.dart';
import 'package:flutter_template/data/request_objects/register_request/register_request.dart';
import 'package:flutter_template/data/response_objects/auth_response/auth_response.dart';
import 'package:flutter_template/injection/network_module.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AuthRemoteDataSource {
  @factoryMethod
  factory AuthRemoteDataSource(@Named(dioClient) Dio dio) =
      _AuthRemoteDataSource;

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);
}
