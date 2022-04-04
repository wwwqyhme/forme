import 'package:flutter/material.dart';

class FormeBottomSheetConfiguration {
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? barrierColor;
  final bool isScrollControlled;
  final bool isDismissible;
  final AnimationController? transitionAnimationController;
  final bool useRootNavigator;
  final double? maximumHeight;
  final bool performSearchAfterOpen;
  final Curve animationCurve;
  final Duration animationDuration;
  final bool animationEnable;

  const FormeBottomSheetConfiguration({
    this.animationCurve = Curves.linear,
    this.animationEnable = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.backgroundColor,
    this.elevation,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
    ),
    this.clipBehavior,
    this.constraints,
    this.barrierColor,
    this.transitionAnimationController,
    this.isDismissible = true,
    this.isScrollControlled = true,
    this.useRootNavigator = false,
    this.maximumHeight = 300,
    this.performSearchAfterOpen = false,
  });
}

class FormeDialogConfiguration {
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useSafeArea;
  final bool useRootNavigator;
  final Size Function(BuildContext context, MediaQueryData query)? sizeProvider;
  final FormeMaterialConfiguration materialConfiguration;

  final bool performSearchAfterOpen;

  final double? closeButtonSize;
  final double? closeButtonRadius;
  final IconData? closeButtonIcon;
  final Color? closeButtonBackgroundColor;

  const FormeDialogConfiguration({
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    this.barrierLabel,
    this.useSafeArea = true,
    this.useRootNavigator = true,
    this.sizeProvider,
    this.materialConfiguration = const FormeMaterialConfiguration(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0), bottom: Radius.circular(5.0)),
      ),
    ),
    this.closeButtonSize,
    this.closeButtonRadius,
    this.closeButtonIcon,
    this.closeButtonBackgroundColor,
    this.performSearchAfterOpen = true,
  });
}

class FormeBaseConfiguration {
  final double? maximumHeight;
  final FormeMaterialConfiguration materialConfiguration;
  final Curve animationCurve;
  final Duration animationDuration;
  final bool animationEnable;

  const FormeBaseConfiguration({
    this.animationCurve = Curves.linear,
    this.animationEnable = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.maximumHeight = 300,
    this.materialConfiguration = const FormeMaterialConfiguration(),
  });
}

class FormeOverlayConfiguration {
  final double? maximumHeight;
  final FormeMaterialConfiguration materialConfiguration;
  final Curve animationCurve;
  final Duration animationDuration;
  final bool animationEnable;

  const FormeOverlayConfiguration({
    this.animationCurve = Curves.linear,
    this.animationEnable = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.maximumHeight = 300,
    this.materialConfiguration = const FormeMaterialConfiguration(),
  });
}

class FormeMaterialConfiguration {
  final MaterialType type;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip clipBehavior;
  final Duration animationDuration;

  const FormeMaterialConfiguration({
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.shape,
    this.borderRadius,
    this.textStyle,
    this.shadowColor,
    this.color,
    this.type = MaterialType.canvas,
    this.elevation = 4,
    this.animationDuration = kThemeChangeDuration,
  });
}
