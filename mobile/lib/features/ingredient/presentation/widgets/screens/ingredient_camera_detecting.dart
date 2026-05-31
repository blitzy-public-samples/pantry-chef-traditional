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

/// Full-screen camera capture screen for AI-assisted ingredient detection. On
/// mount the underlying state object calls `availableCameras()` and constructs
/// `CameraController(_cameras[0], ResolutionPreset.max)`, broadcasting init
/// status through a `StreamController<bool>`. When the user taps the capture
/// button the preview is paused, a loader is shown, `controller.takePicture()`
/// returns an `XFile`, and `PictureTaken(image: image)` is dispatched to the
/// locally-provided [CameraBloc]. A `MultiBlocListener` watches for
/// `ImagedProcessed` (navigates to `Navigation.ingredientAdding` with the
/// detected `foundIngredient` as the route argument) and `ImageProcessingError`
/// (navigates to `Navigation.ingredientAdding` without arguments, falling back
/// to manual entry). A secondary "Add Manually" `ActionButton` bypasses AI
/// capture entirely. The camera preview is clipped to the device media size
/// via [MediaSizeClipper] declared further down in this file.
class IngredientCameraDetecting extends StatefulWidget {
  /// Default const constructor; only the optional widget [key] is accepted.
  const IngredientCameraDetecting({super.key});

  /// Standard Flutter override returning the private state object.
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

/// Custom rectangular clipper used by the camera preview's `ClipRect` to
/// constrain the live preview to the device's media size. Produces a
/// `Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height)` from the supplied
/// [mediaSize] and always returns `true` from [shouldReclip] so the preview
/// reclips on every layout pass — correct for camera previews because the
/// orientation and aspect ratio may change at any time.
class MediaSizeClipper extends CustomClipper<Rect> {
  /// The target device media size to clip the camera preview to. Typically
  /// `MediaQuery.of(context).size` of the hosting route.
  final Size mediaSize;
  /// Creates a clipper bound to the supplied [mediaSize].
  const MediaSizeClipper(this.mediaSize);
  /// Returns `Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height)` — i.e.
  /// the upper-left rectangle of [mediaSize] regardless of the [size] argument.
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  /// Always returns `true`. The camera preview must reclip on every layout pass
  /// because device orientation and aspect ratio may change at any time.
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
