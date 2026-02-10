import 'package:flutter/material.dart';
import 'package:investy/widgets/app_screen.dart';
import 'package:investy/widgets/body/add_asset_screen_body.dart';
import 'package:investy/datamodel/asset_model.dart';
import 'package:investy/widgets/shared/topbar/app_tobar_with_back.dart';
import 'package:investy/widgets/body/select_asset_screen_body.dart'
    show AssetType;

class AddAssetScreen extends StatelessWidget {
  final AssetModel asset;
  final AssetType assetType;

  const AddAssetScreen({
    super.key,
    required this.asset,
    required this.assetType,
  });

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      screenName: 'Select value',
      showTopbar: false,
      showBottomNavigation: false,
      appBar: const AppBackTopbar(title: 'Select value'),
      body: AddAssetScreenBody(asset: asset, assetType: assetType),
    );
  }
}
