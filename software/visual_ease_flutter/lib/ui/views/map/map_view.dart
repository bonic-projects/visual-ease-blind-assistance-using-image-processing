import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

import '../../../models/appuser.dart';
import 'map_viewmodel.dart';

class MapView extends StackedView<MapViewModel> {
  final AppUser user;
  const MapView({Key? key, required this.user}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MapViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.fullName}\'s location'),
      ),
      body: Center(
        child: viewModel.isBusy
            ? const CircularProgressIndicator()
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      viewModel.user!.latitude, viewModel.user!.longitude),
                  zoom: 15.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: <Marker>{
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: LatLng(
                        viewModel.user!.latitude, viewModel.user!.longitude),
                    infoWindow: InfoWindow(
                      title: 'Current Location: ${viewModel.user!.place}',
                    ),
                  ),
                },
              ),
      ),
    );
  }

  @override
  MapViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MapViewModel();

  @override
  void onViewModelReady(MapViewModel viewModel) {
    viewModel.onModelReady(user);
    super.onViewModelReady(viewModel);
  }
}
