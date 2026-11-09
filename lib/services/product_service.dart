import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> fetchProducts({
    bool includeDrafts = false,
    bool? isFeatured,
    bool? isNewArrival,
    String? collection,
  }) async {
    final queryParameters = <String, String>{};

    if (collection != null) {
      queryParameters['collection'] = collection;
    }

    if (includeDrafts) {
      queryParameters['include_drafts'] = 'true';
    }

    if (isFeatured != null) {
      queryParameters['is_featured'] = isFeatured.toString();
    }

    if (isNewArrival != null) {
      queryParameters['is_new_arrival'] = isNewArrival.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/products/',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> productsJson = data['products'];

        return productsJson
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  /// Fetches a single product by ID or slug along with all variants and images.
  Future<Product> fetchProduct(String idOrSlug) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/products/$idOrSlug');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(Map<String, dynamic>.from(data['product']));
      } else {
        throw Exception('Failed to fetch product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
}
