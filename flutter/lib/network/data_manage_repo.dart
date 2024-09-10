
import 'package:flutter_smart_genome/bean/datasets.dart';
import 'package:get/get.dart';

class DataManageRepo extends GetConnect{
  @override
  void onInit() {
    // All request will pass to jsonEncode so CasesModel.fromJson()
    // httpClient.defaultDecoder = CasesModel.fromJson;
    // httpClient.baseUrl = 'https://api.covid19api.com';
    // Http and websockets if used with no [httpClient] instance

    // It's will attach 'apikey' property on header from all requests
    // httpClient.addRequestModifier((request) {
    //   request.headers['_from'] = 'admin';
    //   return request;
    // });

    // httpClient.addAuthenticator((request) async {
    //   // final response = await get("http://yourapi/token");
    //   // final token = response.body['token'];
    //   request.headers['Authorization'] = "fake token";
    //   return request;
    // });

    //Autenticator will be called 3 times if HttpStatus is
    //HttpStatus.unauthorized
    httpClient.maxAuthRetries = 3;
  }


  Future<Response<List<Species>>> getProjects(String path) async {
    return await get<List<Species>>(path, decoder: Species.fromList);
  }


}