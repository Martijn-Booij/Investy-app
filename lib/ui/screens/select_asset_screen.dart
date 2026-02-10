import 'package:flutter/material.dart';
import 'package:investy/widgets/app_screen.dart';
import 'package:investy/widgets/body/select_asset_screen_body.dart'
    show SelectAssetScreenBody, AssetType;
import 'package:investy/widgets/shared/topbar/app_tobar_with_back.dart';

class SelectAssetScreen extends StatelessWidget {
  final AssetType assetType;

  const SelectAssetScreen({
    super.key,
    required this.assetType,
  });

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      screenName: 'Select asset',
      showTopbar: false,
      showBottomNavigation: false,
      appBar: const AppBackTopbar(title: 'Select asset'),
      body: SelectAssetScreenBody(assetType: assetType),
    );
  }
}
