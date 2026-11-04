import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Interactive brutalist card with solid border and hard offset drop shadow.
class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final Color borderColor;
  final Color shadowColor;
  final Offset shadowOffset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double borderWidth;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.bgColor = AppTheme.surface,
    this.borderColor = AppTheme.black,
    this.shadowColor = AppTheme.black,
    this.shadowOffset = const Offset(3.5, 3.5),
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = AppTheme.borderRadius,
    this.borderWidth = AppTheme.borderWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadowOffset == Offset.zero
            ? null
            : [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

/// Tactile Brutalist Button that physically translates down & right on press.
class BrutalistButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final bool fullWidth;
  final bool isSecondary;

  const BrutalistButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.bgColor = AppTheme.black,
    this.textColor = AppTheme.yellow,
    this.borderColor = AppTheme.black,
    this.shadowColor = AppTheme.black,
    this.height = 48,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.fontSize = 14,
    this.fullWidth = false,
    this.isSecondary = false,
  });

  /// Preset: Cobalt Blue
  factory BrutalistButton.blue({
    Key? key,
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 48,
    bool fullWidth = false,
  }) {
    return BrutalistButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      bgColor: AppTheme.blue,
      textColor: AppTheme.surface,
      borderColor: AppTheme.black,
      height: height,
      fullWidth: fullWidth,
    );
  }

  /// Preset: Electric Yellow
  factory BrutalistButton.yellow({
    Key? key,
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 48,
    bool fullWidth = false,
  }) {
    return BrutalistButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      bgColor: AppTheme.yellow,
      textColor: AppTheme.black,
      borderColor: AppTheme.black,
      height: height,
      fullWidth: fullWidth,
    );
  }

  /// Preset: Signal Red Destructive
  factory BrutalistButton.red({
    Key? key,
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 48,
    bool fullWidth = false,
  }) {
    return BrutalistButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      bgColor: AppTheme.red,
      textColor: AppTheme.surface,
      borderColor: AppTheme.black,
      height: height,
      fullWidth: fullWidth,
    );
  }

  /// Preset: White Outline
  factory BrutalistButton.white({
    Key? key,
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 48,
    bool fullWidth = false,
  }) {
    return BrutalistButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      bgColor: AppTheme.surface,
      textColor: AppTheme.black,
      borderColor: AppTheme.black,
      height: height,
      fullWidth: fullWidth,
    );
  }

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double offsetAmount = _isPressed ? 0.0 : 3.5;
    final double topMargin = _isPressed ? 3.5 : 0.0;
    final double leftMargin = _isPressed ? 3.5 : 0.0;
    final double bottomMargin = _isPressed ? 0.0 : 3.5;
    final double rightMargin = _isPressed ? 0.0 : 3.5;

    Widget buttonContent = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: widget.textColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            color: widget.textColor,
            fontWeight: FontWeight.w900,
            fontSize: widget.fontSize,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.fullWidth ? double.infinity : widget.width,
        height: widget.height,
        margin: EdgeInsets.only(
          top: topMargin,
          left: leftMargin,
          right: rightMargin,
          bottom: bottomMargin,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? const Color(0xFFDDDDDD)
              : widget.bgColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: AppTheme.borderWidth,
          ),
          boxShadow: offsetAmount > 0
              ? [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(offsetAmount, offsetAmount),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: buttonContent,
      ),
    );
  }
}

/// Sticker / Badge with bold contrast and thick border
class BrutalistBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BrutalistBadge({
    super.key,
    required this.label,
    this.bgColor = AppTheme.yellow,
    this.textColor = AppTheme.black,
    this.borderColor = AppTheme.black,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  factory BrutalistBadge.black({required String label, IconData? icon}) {
    return BrutalistBadge(
      label: label,
      bgColor: AppTheme.black,
      textColor: AppTheme.yellow,
      icon: icon,
    );
  }

  factory BrutalistBadge.red({required String label, IconData? icon}) {
    return BrutalistBadge(
      label: label,
      bgColor: AppTheme.red,
      textColor: AppTheme.surface,
      icon: icon,
    );
  }

  factory BrutalistBadge.blue({required String label, IconData? icon}) {
    return BrutalistBadge(
      label: label,
      bgColor: AppTheme.blue,
      textColor: AppTheme.surface,
      icon: icon,
    );
  }

  factory BrutalistBadge.green({required String label, IconData? icon}) {
    return BrutalistBadge(
      label: label,
      bgColor: AppTheme.green,
      textColor: AppTheme.black,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Editorial section header with tag and heavy black divider
class BrutalistSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? tag;
  final Widget? trailing;

  const BrutalistSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.tag,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (tag != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 8, bottom: 2),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  border: Border.all(color: AppTheme.black, width: 1.5),
                ),
                child: Text(
                  tag!.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF555555),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Container(
          height: 2.5,
          color: AppTheme.black,
          width: double.infinity,
        ),
      ],
    );
  }
}

/// Marquee / Ticker tape for brutalist announcements
class BrutalistTickerTape extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final double height;

  const BrutalistTickerTape({
    super.key,
    required this.text,
    this.bgColor = AppTheme.yellow,
    this.textColor = AppTheme.black,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.yellow,
        border: Border(
          top: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
          bottom: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
        ),
      ),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "⚡ ${text.toUpperCase()} ⚡",
                style: GoogleFonts.ibmPlexMono(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brutalist Stat / Metric Box
class BrutalistStatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? subtext;
  final Color bgColor;
  final Color valueColor;
  final IconData? icon;

  const BrutalistStatBox({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    this.bgColor = AppTheme.surface,
    this.valueColor = AppTheme.black,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      bgColor: bgColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF666666),
                  letterSpacing: 0.5,
                ),
              ),
              if (icon != null) Icon(icon, size: 16, color: AppTheme.black),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext!,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF777777),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sharp Brutalist Text Field with bold black border and offset shadow.
class BrutalistTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  const BrutalistTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.black,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            maxLines: maxLines,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.black.withValues(alpha: 0.4),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppTheme.black, size: 20)
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

