import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/constants/navigation.dart';
import 'package:pantry_chef/core/presentation/widgets/action_button.dart';
import 'package:pantry_chef/core/presentation/widgets/app_bar_widget.dart';
import 'package:pantry_chef/core/presentation/widgets/app_icon_button.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/ingredient/presentation/bloc/camera/camera_bloc.dart';

class IngredientCameraDetecting extends StatefulWidget {
  const IngredientCameraDetecting({super.key});

  @override
  State<IngredientCameraDetecting> createState() => _IngredientCameraDetectingState();
}

class _IngredientCameraDetectingState extends State<IngredientCameraDetecting> {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  final StreamController<bool> streamController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      await controller?.initialize();
      streamController.add(true);
    } catch (err) {
      streamController.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: getAppBarWidget(context, title: AppLocalizations.of(context)!.ingredientDetecting),
      body: SafeArea(
        child: StreamBuilder(
          stream: streamController.stream.asBroadcastStream(),
          builder: (_, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: PlatformCircularProgressIndicator(
                  cupertino: (_, __) =>
                      CupertinoProgressIndicatorData(color: context.theme.appColors.green, radius: 16),
                ),
              );
            }
            if (snapshot.data == false) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.cameraNotAvailable,
                      style: context.theme.appTextTheme.semiBold18,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: CommonConstants.pagePadding),
                      child: ActionButton(
                        text: AppLocalizations.of(context)!.addIngredientManually,
                        onPress: () {
                          Navigator.of(context).pushNamed(Navigation.ingredientAdding);
                        },
                      ),
                    )
                  ],
                ),
              );
            }
            final mediaSize = MediaQuery.of(context).size;
            final scale = controller?.value.isInitialized == true
                ? 1 / (controller!.value.aspectRatio * mediaSize.aspectRatio)
                : 1.0;
            return BlocProvider(
              create: (context) => CameraBloc(),
              child: MultiBlocListener(
                listeners: [
                  BlocListener<CameraBloc, CameraState>(
                    listenWhen: (_, curr) => curr is ImageProcessingError,
                    listener: (context, state) {
                      context.loaderOverlay.hide();
                      Navigator.of(context).pushReplacementNamed(Navigation.ingredientAdding);
                    },
                  ),
                  BlocListener<CameraBloc, CameraState>(
                    listenWhen: (_, curr) => curr is ImagedProcessed,
                    listener: (context, state) {
                      context.loaderOverlay.hide();
                      Navigator.of(context).pushReplacementNamed(Navigation.ingredientAdding,
                          arguments: (state as ImagedProcessed).foundIngredient);
                    },
                  ),
                ],
                child: LayoutBuilder(builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Stack(
                      children: [
                        ClipRect(
                          clipper: MediaSizeClipper(mediaSize),
                          child: Transform.scale(
                            scale: scale,
                            alignment: Alignment.topCenter,
                            child: CameraPreview(
                              controller!,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: Column(
                            children: [
                              AppIconButton(
                                icon: Icons.photo,
                                iconColor: context.theme.appColors.white,
                                padding: EdgeInsets.all(20),
                                iconSize: 32,
                                backgroundColor: context.theme.appColors.green,
                                onPress: () async {
                                  await controller?.pausePreview();
                                  context.loaderOverlay.show();
                                  final image = await controller!.takePicture();
                                  context.read<CameraBloc>().add(PictureTaken(image: image));
                                },
                              ),
                              const SizedBox(height: 12),
                              ActionButton(
                                text: AppLocalizations.of(context)!.addIngredientManually,
                                outline: true,
                                onPress: () {
                                  Navigator.of(context).pushNamed(Navigation.ingredientAdding);
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
