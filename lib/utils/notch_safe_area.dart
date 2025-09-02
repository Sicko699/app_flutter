import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget helper per gestire correttamente i margini superiori e la notch
class NotchSafeArea extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool addTopPadding;

  const NotchSafeArea({
    super.key,
    required this.child,
    this.padding,
    this.addTopPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.dark 
            : Brightness.light,
      ),
      child: SafeArea(
        top: addTopPadding,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// Estensione per ottenere i margini sicuri per la notch
extension NotchSafeAreaExtension on BuildContext {
  /// Restituisce i margini sicuri per la notch
  EdgeInsets get notchSafePadding {
    final mediaQuery = MediaQuery.of(this);
    final padding = mediaQuery.padding;
    
    // Aggiunge padding extra per dispositivi con notch
    final topPadding = padding.top > 20 ? padding.top + 8 : padding.top;
    
    return EdgeInsets.only(
      top: topPadding,
      left: padding.left,
      right: padding.right,
      bottom: padding.bottom,
    );
  }
  
  /// Restituisce solo il padding superiore sicuro per la notch
  double get notchSafeTopPadding {
    final mediaQuery = MediaQuery.of(this);
    final topPadding = mediaQuery.padding.top;
    
    // Aggiunge padding extra per dispositivi con notch
    return topPadding > 20 ? topPadding + 8 : topPadding;
  }
}
