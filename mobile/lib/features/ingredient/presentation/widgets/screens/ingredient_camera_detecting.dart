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

/// Live camera screen that detects ingredients from a captured photo.
///
/// Discovers the device cameras, shows a live [CameraPreview], and lets
/// the user capture a photo for AI ingredient recognition. When no camera
/// is available it offers a manual-add fallback that routes to the
/// ingredient-adding screen.
class IngredientCameraDetecting extends StatefulWidget {
  const IngredientCameraDetecting({super.key});

  @override
  State<IngredientCameraDetecting> createState() => _IngredientCameraDetectingState();
}

class _IngredientCameraDetectingState extends State<IngredientCameraDetecting> {
  // Active camera controller; null until initializeCamera() succeeds.
  CameraController? controller;
  // Cameras discovered on the device via availableCameras().
  List<CameraDescription> _cameras = [];
  // Broadcast readiness stream: true = camera ready, false = unavailable.
  // KNOWN ISSUE: streamController is not closed in dispose() (only the
  // camera controller is disposed), so the broadcast stream leaks.
  final StreamController<bool> streamController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    // Kick off async camera discovery and initialization on startup.
    initializeCamera();
  }

  @override
  void dispose() {
    // Dispose the camera controller before tearing down the widget.
    controller?.dispose();
    super.dispose();
    // KNOWN ISSUE: streamController is not closed here, so it leaks.
  }

  Future<void> initializeCamera() async {
    try {
      // Discover the available cameras on the device.
      _cameras = await availableCameras();
      // Use the first camera at the highest resolution preset.
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      // Initialize the controller, then signal readiness via the stream.
      await controller?.initialize();
      streamController.add(true);
    } catch (err) {
      // Signal that the camera is unavailable so the UI shows fallback.
      streamController.add(false);
    }
  }

  /// Builds a [PlatformScaffold] whose body is a [StreamBuilder] driven
  /// by [streamController].
  ///
  /// While camera initialization is pending the builder shows a loading
  /// spinner; when the camera is unavailable it shows a manual-add
  /// fallback; otherwise it shows the live [CameraPreview] with capture
  /// controls, wrapped in a [BlocProvider] of [CameraBloc] and a
  /// [MultiBlocListener]. Uses [context] for theme, localization, and
  /// navigation.
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: getAppBarWidget(context, title: AppLocalizations.of(context)!.ingredientDetecting),
      body: SafeArea(
        child: StreamBuilder(
          stream: streamController.stream.asBroadcastStream(),
          builder: (_, snapshot) {
            // While camera init is pending, show a loading spinner.
            if (snapshot.data == null) {
              return Center(
                child: PlatformCircularProgressIndicator(
                  cupertino: (_, __) =>
                      CupertinoProgressIndicatorData(color: context.theme.appColors.green, radius: 16),
                ),
              );
            }
            // When the camera is unavailable, offer manual ingredient add.
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
            // Compute a scale that fits the preview to the screen aspect.
            final mediaSize = MediaQuery.of(context).size;
            final scale = controller?.value.isInitialized == true
                ? 1 / (controller!.value.aspectRatio * mediaSize.aspectRatio)
                : 1.0;
            // Provide a CameraBloc and react to its processing states.
            return BlocProvider(
              create: (context) => CameraBloc(),
              child: MultiBlocListener(
                listeners: [
                  // On ImageProcessingError: hide the loader and route to
                  // the manual ingredient-add screen.
                  BlocListener<CameraBloc, CameraState>(
                    listenWhen: (_, curr) => curr is ImageProcessingError,
                    listener: (context, state) {
                      context.loaderOverlay.hide();
                      Navigator.of(context).pushReplacementNamed(Navigation.ingredientAdding);
                    },
                  ),
                  // On ImagedProcessed (sic): hide the loader and route to
                  // manual add, carrying the detected ingredient as args.
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
                                  // Pause the live preview before capture.
                                  await controller?.pausePreview();
                                  // Show a blocking loader during upload.
                                  context.loaderOverlay.show();
                                  // Capture a still frame from the camera.
                                  final image = await controller!.takePicture();
                                  // Dispatch PictureTaken to the CameraBloc.
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

/// A [CustomClipper] that clips the scaled camera preview to the visible
/// media bounds described by [mediaSize].
class MediaSizeClipper extends CustomClipper<Rect> {
  /// The screen media size used as the clip rectangle bounds.
  final Size mediaSize;
  const MediaSizeClipper(this.mediaSize);
  /// Returns a [Rect] spanning the full [mediaSize] width and height,
  /// ignoring the provided layout [size].
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  /// Always returns `true` so the clip is recomputed on every reclip
  /// check, regardless of [oldClipper].
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
