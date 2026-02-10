import 'package:investy/env/env.dart';

class ApiConfig {
  static const int cacheDurationMinutes = 5;

  static const int trendingCacheDurationMinutes = 30;

  static Duration get cacheDuration =>
      Duration(minutes: cacheDurationMinutes);

  static Duration get trendingCacheDuration =>
      Duration(minutes: trendingCacheDurationMinutes);

  static String? get coinGeckoApiKey => Env.coinGeckoApiKey;

  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
}
