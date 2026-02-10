import 'package:envied/envied.dart';

part 'env.g.dart';

/// Environment variables loaded from `.env` at **build time** (not bundled in the app).
/// Run: `dart run build_runner build --delete-conflicting-outputs`
/// after creating `.env` from `.env.example`.
@Envied(path: '.env', allowOptionalFields: true)
abstract class Env {
  @EnviedField(varName: 'COINGECKO_API_KEY', obfuscate: true, optional: true)
  static final String? coinGeckoApiKey = _Env.coinGeckoApiKey;
}
