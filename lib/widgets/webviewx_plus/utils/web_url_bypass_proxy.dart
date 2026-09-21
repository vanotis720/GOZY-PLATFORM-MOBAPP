import 'package:http/http.dart' as http;

/// Proxy which will be used to fetch page sources in the [SourceType.urlBypass] mode.
abstract class BypassProxy {
  const BypassProxy();

  /// Builds the proxied url
  String buildProxyUrl(String pageUrl);

  /// Returns the page source from the response body
  String extractPageSource(String responseBody);

  /// A default list of public proxies
  static const publicProxies = <BypassProxy>[
    BridgedBypassProxy(),
    CodeTabsBypassProxy(),
    WeCorsAnyWhereProxy(),
  ];

  Future<String> fetchPageSource({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final proxiedUri = Uri.parse(buildProxyUrl(Uri.encodeFull(url)));

    Future<http.Response> request;

    if (method == 'get') {
      request = http.get(proxiedUri, headers: headers);
    } else {
      request = http.post(proxiedUri, headers: headers, body: body);
    }

    final response = await request;
    return extractPageSource(response.body);
  }
}

/// cors.bridged.cc proxy
class BridgedBypassProxy extends BypassProxy {
  const BridgedBypassProxy();

  @override
  String buildProxyUrl(String pageUrl) {
    return 'https://cors.bridged.cc/$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    return responseBody;
  }
}

/// api.codetabs.com proxy
class CodeTabsBypassProxy extends BypassProxy {
  const CodeTabsBypassProxy();

  @override
  String buildProxyUrl(String pageUrl) {
    return 'https://api.codetabs.com/v1/proxy/?quest=$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    return responseBody;
  }
}

/// we-cors-anywhere.herokuapp.com proxy
class WeCorsAnyWhereProxy extends BypassProxy {
  const WeCorsAnyWhereProxy();

  @override
  String buildProxyUrl(String pageUrl) {
    return 'https://we-cors-anywhere.herokuapp.com/$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    return responseBody;
  }
}