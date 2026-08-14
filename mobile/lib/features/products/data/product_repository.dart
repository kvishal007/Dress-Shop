import 'package:dio/dio.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/core/errors/failure.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<ProductModel>> getProducts({String? search, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;

      final response = await _apiClient.instance.get(
        '/products',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.instance.get('/categories');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<ProductModel> getProductByScanCode(String code) async {
    try {
      final response = await _apiClient.instance.get('/products/scan/${Uri.encodeComponent(code)}');
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.instance.post(
        '/products',
        data: productData,
      );
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await _apiClient.instance.put(
        '/products/$id',
        data: productData,
      );
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.instance.delete('/products/$id');
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
