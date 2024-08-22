import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';
import 'package:visual_ease_flutter/ui/common/app_colors.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onViewModelReady: (model) => model.onModelRdy(),
      builder: (context, model, child) {
        // print(model.node?.lastSeen);
        return Scaffold(
          appBar: AppBar(
            title: Text(
                'Visual Ease ${model.user != null && model.user!.userRole == "bystander" ? "- Bystander" : "- Blind"}'),
            actions: [
              if (model.user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: model.user!.photoUrl != ""
                        ? NetworkImage(model.user!.photoUrl)
                        : null,
                    child: model.user!.photoUrl == ""
                        ? Text(model.user!.fullName[0])
                        : null,
                  ),
                ),
              if (model.user != null)
                IconButton(
                  onPressed: model.logout,
                  icon: const Icon(Icons.logout),
                )
            ],
          ),
          floatingActionButton:
              model.user != null && model.user!.userRole == "blind"
                  ? FloatingActionButton.extended(
                      backgroundColor: kcPrimaryColor,
                      onPressed: model.showBottomSheetUserSearch,
                      label: const Row(
                        children: [
                          Text('Add bystander'),
                          Icon(Icons.add_circle),
                        ],
                      ),
                    )
                  : null,
          body: Column(
            children: [
              Expanded(
                child: !model.isBusy && model.user!.userRole == 'blind'
                    ? GridView.count(
                        crossAxisCount: 2,
                        children: [
                          Option(
                              name: 'In App',
                              onTap: model.openInAppView,
                              file: 'assets/lottie/inapp.json'),
                          Option(
                              name: 'Face Train',
                              onTap: model.openFaceTrainView,
                              file: 'assets/lottie/face.json')
                        ],
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        children: model.blinds
                            .map((b) => OptionBlind(
                                name: b.fullName,
                                onTap: () {
                                  model.openMapView(b);
                                },
                                link: b.photoUrl))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}

class Option extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final String file;
  const Option(
      {Key? key, required this.name, required this.onTap, required this.file})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 1.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Lottie.asset(file),
                      )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kcPrimaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OptionBlind extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final String link;
  const OptionBlind(
      {Key? key, required this.name, required this.onTap, required this.link})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 1.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: link == ""
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: CircleAvatar(
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      name[0],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  )),
                                ),
                              )
                            : Image.network(link),
                      )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kcPrimaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
