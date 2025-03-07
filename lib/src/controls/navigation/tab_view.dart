import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const double _kMinTileWidth = 80.0;
const double _kMaxTileWidth = 240.0;
const double _kTileHeight = 34.0;
const double _kButtonWidth = 32.0;

enum CloseButtonVisibilityMode {
  /// The close button will never be visible
  never,

  /// The close button will always be visible
  always,

  /// The close button will only be shown on hover
  onHover,
}

/// Determines how the tab sizes itself
enum TabWidthBehavior {
  /// The tab will fit its content
  sizeToContent,

  /// If not scrollable, the tabs will have the same size
  equal,

  /// If not selected, the [Tab]'s text is hidden. The tab will fit its content
  compact,
}

/// The TabView control is a way to display a set of tabs and their respective
/// content. TabViews are useful for displaying several pages (or documents) of
/// content while giving a user the capability to rearrange, open, or close new
/// tabs.
///
/// ![TabView Preview](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/tabview/tab-introduction.png)
///
/// There must be enough space to render the tabview.
///
/// See also:
///
///   * [NavigationView], control provides top-level navigation for your app.
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/tab-view>
class TabView extends StatefulWidget {
  /// Creates a tab view.
  ///
  /// [tabs] must have the same length as [bodies]
  ///
  /// [maxTabWidth] must be non-negative
  const TabView({
    super.key,
    required this.currentIndex,
    this.onChanged,
    required this.tabs,
    this.onNewPressed,
    this.addIconData,
    this.newTabIcon = const Icon(FluentIcons.add),
    this.addIconBuilder,
    this.shortcutsEnabled = true,
    this.onReorder,
    this.showScrollButtons = true,
    this.scrollController,
    this.minTabWidth = _kMinTileWidth,
    this.maxTabWidth = _kMaxTileWidth,
    this.closeButtonVisibility = CloseButtonVisibilityMode.always,
    this.tabWidthBehavior = TabWidthBehavior.equal,
    this.header,
    this.footer,
    this.reservedStripWidth,
    this.stripBuilder,
    this.closeDelayDuration = const Duration(seconds: 1),
  });

  /// The index of the tab to be displayed
  final int currentIndex;

  /// Whether another tab was requested to be displayed
  final ValueChanged<int>? onChanged;

  /// The tabs to be displayed.
  final List<Tab> tabs;

  /// Called when the new button is pressed or when the
  /// shortcut `Ctrl + T` is executed.
  ///
  /// If null, the new button won't be displayed
  final VoidCallback? onNewPressed;

  /// The icon of the new button
  @Deprecated(
    'Use newTabIcon instead. This was deprecated on 4.9.0 and will be removed in the next releases.',
  )
  final IconData? addIconData;

  /// The icon of the "Add new tab" button.
  ///
  /// Defaults to an [Icon] with [FluentIcons.add].
  final Icon newTabIcon;

  /// The builder for the add icon.
  ///
  /// This does not build the add button, only its icon.
  ///
  /// When null, the add icon is rendered.
  @Deprecated(
    'Use newTabIcon instead. This was deprecated on 4.9.0 and will be removed in the next releases.',
  )
  final Widget Function(Widget addIcon)? addIconBuilder;

  /// Whether the following shortcuts are enabled:
  ///
  ///   * `Ctrl + T` to create a new tab
  ///   * `Ctrl + F4` or `Ctrl + W` to close the current tab
  ///   * `Ctrl + 1` to ` Ctrl + 8` to navigate through tabs
  ///   * `Ctrl + 9` to navigate to the last tab
  ///
  /// Defaults to `true`.
  final bool shortcutsEnabled;

  /// Called when the tabs are reordered.
  ///
  /// If null, reordering is disabled. It's disabled by default.
  final ReorderCallback? onReorder;

  /// The min width a tab can have. Must not be negative.
  ///
  /// Defaults to 80 logical pixels.
  final double minTabWidth;

  /// The max width a tab can have. Must not be negative.
  ///
  /// Defaults to 240 logical pixels.
  final double maxTabWidth;

  /// Whether the buttons that scroll forward or backward
  /// should be displayed, if necessary.
  ///
  /// Defaults to `true`.
  final bool showScrollButtons;

  /// The [ScrollPosController] used to move tabview to right and left when the
  /// tabs don't fit the available horizontal space.
  ///
  /// If null, a [ScrollPosController] is created internally.
  final ScrollPosController? scrollController;

  /// Indicates the close button visibility mode.
  ///
  /// Defaults to [CloseButtonVisibilityMode.always].
  final CloseButtonVisibilityMode closeButtonVisibility;

  /// Indicates how a tab will size itself.
  ///
  /// Defaults to [TabWidthBehavior.equal].
  final TabWidthBehavior tabWidthBehavior;

  /// Displayed before all the tabs and buttons.
  ///
  /// Usually a [Text].
  final Widget? header;

  /// Displayed after all the tabs and buttons.
  ///
  /// Usually a [Text] widget.
  final Widget? footer;

  /// The minimum width reserved at the end of the tab strip.
  ///
  /// This reserved space ensures a consistent drag area for window manipulation 
  /// (e.g., dragging, resizing) even when many tabs are present. This is particularly 
  /// crucial when `TabView` is used in a title bar.
  ///
  /// When using TabView in a title bar, this space ensures minimum drag area even
  /// when many tabs are present. This is critical for window manipulation (dragging, etc)
  /// as it guarantees a consistent drag target regardless of tab count.
  ///
  /// If `null`, no reserved width is enforced.
  final double? reservedStripWidth;

  /// The builder for the strip that contains the tabs.
  final Widget Function(BuildContext context, Widget strip)? stripBuilder;

  /// The delay duration to animate the tab after it's closed. Only applied when
  /// [tabWidthBehavior] is [TabWidthBehavior.equal].
  ///
  /// Defaults to 400 milliseconds.
  final Duration closeDelayDuration;

  /// Whenever the new button should be displayed.
  bool get showNewButton => onNewPressed != null;

  /// Whether reordering is enabled or not.
  ///
  /// To enable it, ensure [onReorder] is not null.
  bool get isReorderEnabled => onReorder != null;

  @override
  State<StatefulWidget> createState() => _TabViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('currentIndex', currentIndex))
      ..add(FlagProperty(
        'showNewButton',
        value: showNewButton,
        ifFalse: 'no new button',
      ))
      // ignore: deprecated_member_use_from_same_package
      ..add(IconDataProperty('addIconData', addIconData))
      ..add(DiagnosticsProperty<Widget>(
        'newTabIcon',
        newTabIcon,
        defaultValue: const Icon(FluentIcons.add),
      ))
      ..add(ObjectFlagProperty(
        'onChanged',
        onChanged,
        ifNull: 'disabled',
      ))
      ..add(ObjectFlagProperty(
        'onNewPressed',
        onNewPressed,
        ifNull: 'no new button',
      ))
      ..add(IntProperty('tabs', tabs.length))
      ..add(FlagProperty(
        'reorderEnabled',
        value: isReorderEnabled,
        ifFalse: 'reorder disabled',
      ))
      ..add(FlagProperty(
        'showScrollButtons',
        value: showScrollButtons,
        ifFalse: 'hide scroll buttons',
      ))
      ..add(EnumProperty(
        'closeButtonVisibility',
        closeButtonVisibility,
        defaultValue: CloseButtonVisibilityMode.always,
      ))
      ..add(EnumProperty(
        'tabWidthBehavior',
        tabWidthBehavior,
        defaultValue: TabWidthBehavior.equal,
      ))
      ..add(DiagnosticsProperty<Duration>(
        'closeDelayDuration',
        closeDelayDuration,
        defaultValue: const Duration(seconds: 1),
      ))
      ..add(DoubleProperty('minTabWidth', minTabWidth, defaultValue: 80.0))
      ..add(DoubleProperty('maxTabWidth', maxTabWidth, defaultValue: 240.0))
      ..add(DoubleProperty('minFooterWidth', reservedStripWidth));
  }
}

class _TabViewState extends State<TabView> {
  Timer? closeTimer;
  double? lockedTabWidth;
  double preferredTabWidth = 0.0;

  late ScrollPosController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ??
        ScrollPosController(
          itemCount: widget.tabs.length,
          animationDuration: const Duration(milliseconds: 100),
        );
    scrollController
      ..itemCount = widget.tabs.length
      ..addListener(_handleScrollUpdate);
  }

  void _handleScrollUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != scrollController.itemCount) {
      scrollController.itemCount = widget.tabs.length;
    }
    if (widget.currentIndex != oldWidget.currentIndex &&
        scrollController.hasClients) {
      scrollController.scrollToItem(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      // only dispose the local controller
      scrollController.dispose();
    }
    closeTimer?.cancel();
    super.dispose();
  }

  void close(int index) {
    final tab = widget.tabs[index];
    final closable = tab.onClosed != null;

    void createTimer() {
      closeTimer = Timer(widget.closeDelayDuration, () {
        closeTimer!.cancel();
        closeTimer = null;
        lockedTabWidth = null;

        if (mounted) setState(() {});
      });
    }

    if (closable) {
      widget.tabs[index].onClosed!();

      closeTimer?.cancel();

      var tabWidth = preferredTabWidth;

      final tabBox =
          tab._tabKey.currentContext?.findRenderObject() as RenderBox?;
      if (tabBox != null && tabBox.hasSize) {
        tabWidth = tabBox.size.width;

        // consider the divider thickness when calculating the tab width
        final thickness = DividerTheme.of(context).thickness ?? 0;
        tabWidth += (thickness * (widget.tabs.length - 1)) - thickness * 2;
      }

      setState(() => lockedTabWidth = tabWidth);
      createTimer();
    }
  }

  Widget _tabBuilder(
    BuildContext context,
    int index,
    double preferredTabWidth,
  ) {
    final tab = widget.tabs[index];
    final tabWidget = TabData(
      key: ValueKey<int>(index),
      reorderIndex: widget.isReorderEnabled ? index : null,
      selected: index == widget.currentIndex,
      onPressed:
          widget.onChanged == null ? null : () => widget.onChanged!(index),
      onClose: widget.tabs[index].onClosed == null ? null : () => close(index),
      animationDuration: FluentTheme.of(context).fastAnimationDuration,
      animationCurve: FluentTheme.of(context).animationCurve,
      visibilityMode: widget.closeButtonVisibility,
      tabWidthBehavior: widget.tabWidthBehavior,
      child: tab,
    );
    final Widget child = GestureDetector(
      onTertiaryTapUp: (_) => close(index),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          fit: widget.tabWidthBehavior == TabWidthBehavior.equal
              ? FlexFit.tight
              : FlexFit.loose,
          child: tabWidget,
        ),
        divider(index),
      ]),
    );
    final minWidth = () {
      switch (widget.tabWidthBehavior) {
        case TabWidthBehavior.sizeToContent:
        case TabWidthBehavior.compact:
          return null;
        default:
          return lockedTabWidth ?? preferredTabWidth;
      }
    }();
    if (minWidth == null) {
      return KeyedSubtree(
        key: ValueKey<Tab>(tab),
        child: child,
      );
    }
    return AnimatedContainer(
      key: ValueKey<Tab>(tab),
      constraints: BoxConstraints(maxWidth: minWidth, minWidth: minWidth),
      duration: FluentTheme.of(context).fastAnimationDuration,
      curve: FluentTheme.of(context).animationCurve,
      child: child,
    );
  }

  Widget _buttonTabBuilder(
    BuildContext context,
    Widget icon,
    VoidCallback? onPressed,
    String tooltip,
  ) {
    final item = SizedBox(
      width: _kButtonWidth,
      height: 28.0,
      child: IconButton(
        icon: Center(child: icon),
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isDisabled) {
              return FluentTheme.of(context)
                  .resources
                  .accentTextFillColorDisabled;
            } else {
              return FluentTheme.of(context).inactiveColor;
            }
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isDisabled || states.isNone) return Colors.transparent;
            return ButtonThemeData.uncheckedInputColor(
              FluentTheme.of(context),
              states,
            );
          }),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
    );
    if (onPressed == null) return item;
    return Tooltip(message: tooltip, child: item);
  }

  Widget divider(int index) {
    return SizedBox(
      height: _kTileHeight,
      child: Divider(
        direction: Axis.vertical,
        style: DividerThemeData(
          verticalMargin: const EdgeInsets.symmetric(vertical: 8),
          decoration:
              ![widget.currentIndex - 1, widget.currentIndex].contains(index)
                  ? null
                  : const BoxDecoration(color: Colors.transparent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final direction = Directionality.of(context);
    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);

    final headerFooterTextStyle =
        theme.typography.bodyLarge ?? const TextStyle();

    Widget tabBar = Column(children: [
      ScrollConfiguration(
        behavior: const _TabViewScrollBehavior(),
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: 4.5),
          padding: const EdgeInsetsDirectional.only(start: 8),
          height: _kTileHeight,
          width: double.infinity,
          child: Row(children: [
            if (widget.header != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: DefaultTextStyle.merge(
                  style: headerFooterTextStyle,
                  child: widget.header!,
                ),
              ),
            Expanded(
              child: LayoutBuilder(builder: (context, consts) {
                final width = consts.biggest.width;
                assert(
                  width.isFinite,
                  'You can only create a TabView in a box with defined width',
                );

                preferredTabWidth = ((width -
                            (widget.showNewButton ? _kButtonWidth : 0) -
                            (widget.reservedStripWidth ?? 0)) /
                        widget.tabs.length)
                    .clamp(widget.minTabWidth, widget.maxTabWidth);

                final Widget listView = Listener(
                  onPointerSignal: (PointerSignalEvent e) {
                    if (e is PointerScrollEvent &&
                        scrollController.hasClients) {
                      GestureBinding.instance.pointerSignalResolver.register(e,
                          (PointerSignalEvent event) {
                        if (e.scrollDelta.dy > 0) {
                          scrollController.forward(
                            align: false,
                            animate: false,
                          );
                        } else {
                          scrollController.backward(
                            align: false,
                            animate: false,
                          );
                        }
                      });
                    }
                  },
                  child: Localizations.override(
                    context: context,
                    delegates: const [
                      GlobalMaterialLocalizations.delegate,
                    ],
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      scrollController: scrollController,
                      onReorder: (i, ii) {
                        widget.onReorder?.call(i, ii);
                      },
                      itemCount: widget.tabs.length,
                      proxyDecorator: (child, index, animation) {
                        return child;
                      },
                      itemBuilder: (context, index) {
                        return _tabBuilder(context, index, preferredTabWidth);
                      },
                      dragStartBehavior: DragStartBehavior.down,
                    ),
                  ),
                );

                /// Whether the tab bar is scrollable
                var scrollable = preferredTabWidth * widget.tabs.length >
                    width - (widget.showNewButton ? _kButtonWidth : 0);

                final showScrollButtons = widget.showScrollButtons &&
                    scrollable &&
                    scrollController.hasClients;

                Widget backwardButton() {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                      end: 3.0,
                      bottom: 3.0,
                    ),
                    child: _buttonTabBuilder(
                      context,
                      const Icon(FluentIcons.caret_left_solid8, size: 8),
                      scrollController.canBackward
                          ? () {
                              if (direction == TextDirection.ltr) {
                                scrollController.backward(align: false);
                              } else {
                                scrollController.forward(align: false);
                              }
                            }
                          : null,
                      localizations.scrollTabBackwardLabel,
                    ),
                  );
                }

                Widget forwardButton() {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 3.0,
                      end: 8.0,
                      bottom: 3.0,
                    ),
                    child: _buttonTabBuilder(
                      context,
                      const Icon(FluentIcons.caret_right_solid8, size: 8),
                      scrollController.canForward
                          ? () {
                              if (direction == TextDirection.ltr) {
                                scrollController.forward(align: false);
                              } else {
                                scrollController.backward(align: false);
                              }
                            }
                          : null,
                      localizations.scrollTabForwardLabel,
                    ),
                  );
                }

                final strip = Row(children: [
                  // scroll buttons if needed
                  if (showScrollButtons)
                    direction == TextDirection.ltr
                        ? backwardButton()
                        : forwardButton(),
                  // tabs area (flexible/expanded)
                  if (scrollable)
                    Expanded(child: listView)
                  else
                    Flexible(child: listView),
                  // scroll buttons if needed
                  if (showScrollButtons)
                    direction == TextDirection.ltr
                        ? forwardButton()
                        : backwardButton(),
                  // new tab button
                  if (widget.showNewButton)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 3.0,
                        bottom: 3.0,
                      ),
                      child: _buttonTabBuilder(
                        context,
                        () {
                          Widget icon;
                          // ignore: deprecated_member_use_from_same_package
                          if (widget.addIconData != null) {
                            // ignore: deprecated_member_use_from_same_package
                            icon = Icon(widget.addIconData, size: 12.0);
                          } else {
                            icon = widget.newTabIcon;
                          }
                          icon = IconTheme.merge(
                            data: const IconThemeData(size: 12.0),
                            child: icon,
                          );

                          // ignore: deprecated_member_use_from_same_package
                          return widget.addIconBuilder?.call(icon) ?? icon;
                        }(),
                        widget.onNewPressed!,
                        localizations.newTabLabel,
                      ),
                    ),
                  // reserved strip width
                  if (widget.reservedStripWidth != null)
                    SizedBox(width: widget.reservedStripWidth),
                ]);

                if (widget.stripBuilder != null) {
                  return widget.stripBuilder!(context, strip);
                }

                return strip;
              }),
            ),
            if (widget.footer != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: DefaultTextStyle.merge(
                  style: headerFooterTextStyle,
                  child: widget.footer!,
                ),
              ),
          ]),
        ),
      ),
      if (widget.tabs.isNotEmpty)
        Expanded(
          child: Focus(
            autofocus: true,
            child: _TabBody(
              index: widget.currentIndex,
              tabs: widget.tabs,
            ),
          ),
        ),
    ]);
    if (widget.shortcutsEnabled) {
      void onClosePressed() {
        close(widget.currentIndex);
      }

      // For more info, refer to [SingleActivator] docs
      var ctrl = true;
      var meta = false;
      if (!kIsWeb &&
          [TargetPlatform.iOS, TargetPlatform.macOS]
              .contains(defaultTargetPlatform)) {
        ctrl = false;
        meta = true;
      }

      return FocusScope(
        autofocus: true,
        child: CallbackShortcuts(
          bindings: {
            SingleActivator(
              LogicalKeyboardKey.f4,
              control: ctrl,
              meta: meta,
            ): onClosePressed,
            SingleActivator(
              LogicalKeyboardKey.keyW,
              control: ctrl,
              meta: meta,
            ): onClosePressed,
            SingleActivator(
              LogicalKeyboardKey.keyT,
              control: ctrl,
              meta: meta,
            ): () => widget.onNewPressed?.call(),
            ...Map.fromIterable(
              List<int>.generate(9, (index) => index),
              key: (i) {
                final digits = [
                  LogicalKeyboardKey.digit1,
                  LogicalKeyboardKey.digit2,
                  LogicalKeyboardKey.digit3,
                  LogicalKeyboardKey.digit4,
                  LogicalKeyboardKey.digit5,
                  LogicalKeyboardKey.digit6,
                  LogicalKeyboardKey.digit7,
                  LogicalKeyboardKey.digit8,
                  LogicalKeyboardKey.digit9,
                ];
                return SingleActivator(digits[i], control: ctrl, meta: meta);
              },
              value: (index) {
                return () {
                  // If it's the last, move to the last tab
                  if (index == 8) {
                    widget.onChanged?.call(widget.tabs.length - 1);
                  } else {
                    if (widget.tabs.length - 1 >= index) {
                      widget.onChanged?.call(index);
                    }
                  }
                };
              },
            ),
          },
          child: tabBar,
        ),
      );
    }
    return tabBar;
  }
}

/// The data that is passed to the [Tab] widget.
///
/// This is used to determine the state of the tab, such as if it's selected,
/// if it's reorderable, and more.
///
/// See also:
///
///   * [Tab], the widget that uses this data.
///   * [TabView], the widget that uses the [Tab] widget.
class TabData extends InheritedWidget {
  const TabData({
    super.key,
    required super.child,
    required this.selected,
    required this.onPressed,
    required this.onClose,
    required this.reorderIndex,
    required this.animationDuration,
    required this.animationCurve,
    required this.visibilityMode,
    required this.tabWidthBehavior,
  });

  /// Whether the tab is selected or not.
  final bool selected;

  /// Called when the tab is pressed.
  ///
  /// If null, the tab is not pressable or disabled.
  final VoidCallback? onPressed;

  /// Called when the tab is closed.
  ///
  /// If null, the tab is not closeable.
  final VoidCallback? onClose;

  /// The index of the tab in the list of tabs.
  final int? reorderIndex;

  /// The duration of the animation when the tab is closed.
  final Duration animationDuration;

  /// The curve of the animation when the tab is closed.
  final Curve animationCurve;

  /// The visibility mode of the close button.
  ///
  /// See also:
  ///
  ///   * [TabView.closeButtonVisibility], the property that determines the
  ///     visibility mode of the close button.
  final CloseButtonVisibilityMode visibilityMode;

  /// The behavior of the tab width.
  ///
  /// See also:
  ///
  ///   * [TabView.tabWidthBehavior], the property that determines the behavior
  ///     of the tab width.
  final TabWidthBehavior tabWidthBehavior;

  static TabData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabData>()!;
  }

  @override
  bool updateShouldNotify(TabData oldWidget) {
    return true;
  }
}

class _TabBody extends StatefulWidget {
  final int index;
  final List<Tab> tabs;

  const _TabBody({required this.index, required this.tabs});

  @override
  State<_TabBody> createState() => __TabBodyState();
}

class __TabBodyState extends State<_TabBody> {
  final _pageKey = GlobalKey<State<PageView>>();
  PageController? _pageController;

  PageController get pageController => _pageController!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController ??= PageController(initialPage: widget.index);
  }

  @override
  void didUpdateWidget(_TabBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (pageController.hasClients) {
      if (oldWidget.index != widget.index ||
          pageController.page != widget.index) {
        pageController.jumpToPage(widget.index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: _pageKey,
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      itemCount: widget.tabs.length,
      itemBuilder: (context, index) {
        final isSelected = widget.index == index;
        final item = widget.tabs[index];

        return ExcludeFocus(
          key: ValueKey(index),
          excluding: !isSelected,
          child: FocusTraversalGroup(
            child: item.body,
          ),
        );
      },
    );
  }
}

/// Represents a single tab within a [TabView].
class Tab extends StatefulWidget {
  final _tabKey = GlobalKey<TabState>(debugLabel: 'Tab key');

  /// Creates a tab.
  Tab({
    super.key,
    this.icon = const SizedBox.shrink(),
    required this.text,
    required this.body,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.outlineColor,
    this.closeIcon = const Icon(FluentIcons.chrome_close),
    this.onClosed,
    this.semanticLabel,
    this.disabled = false,
  });

  /// the IconSource to be displayed within the tab.
  ///
  /// Usually an [Icon] widget
  final Widget? icon;

  /// The content that appears inside the tab strip to represent the tab.
  ///
  /// Usually a [Text] widget
  final Widget text;

  /// The close icon of the tab.
  ///
  /// Usually an [Icon] widget.
  final Widget? closeIcon;

  /// Called when clicking x-to-close button or when thec`Ctrl + T` or
  /// `Ctrl + F4` is executed
  ///
  /// If null, the tab is not closeable
  final VoidCallback? onClosed;

  /// {@macro fluent_ui.controls.inputs.HoverButton.semanticLabel}
  final String? semanticLabel;

  /// The body of the view attached to this tab
  final Widget body;

  /// The background color of the tab.
  final Color? backgroundColor;

  /// The background color of the tab if it is selected.
  final Color? selectedBackgroundColor;

  /// The outline color of the tab.
  final Color? outlineColor;

  /// Whether the tab is disabled or not.
  ///
  /// If true, the tab will be greyed out.
  final bool disabled;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty(
        'disabled',
        value: disabled,
        defaultValue: false,
        ifFalse: 'enabled',
      ))
      ..add(ObjectFlagProperty(
        'onClosed',
        onClosed,
        ifNull: 'not closeable',
      ))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('selectedBackgroundColor', selectedBackgroundColor))
      ..add(ColorProperty('outlineColor', outlineColor))
      ..add(DiagnosticsProperty<Widget>('text', text))
      ..add(DiagnosticsProperty<Widget>('body', body))
      ..add(DiagnosticsProperty<Widget>('icon', icon))
      ..add(DiagnosticsProperty<Widget>('closeIcon', closeIcon))
      ..add(StringProperty('semanticLabel', semanticLabel));
  }

  @override
  State<Tab> createState() => TabState();
}

class TabState extends State<Tab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final controller = AnimationController(vsync: this);

  TabData get tab => TabData.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller.duration == null) {
      controller
        ..duration = tab.animationDuration
        ..forward();
    } else {
      controller.duration = tab.animationDuration;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final res = theme.resources;
    final localizations = FluentLocalizations.of(context);

    // The text of the tab, if a [Text] widget is used
    final text = () {
      if (widget.text is Text) {
        return (widget.text as Text).data ??
            (widget.text as Text).textSpan?.toPlainText();
      } else if (widget.text is RichText) {
        return (widget.text as RichText).text.toPlainText();
      }
    }();

    return HoverButton(
      key: widget.key,
      semanticLabel: widget.semanticLabel ?? text,
      onPressed: widget.disabled ? null : tab.onPressed,
      builder: (context, states) {
        // https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/TabView/TabView_themeresources.xaml#L15-L19
        final foregroundColor =
            WidgetStateProperty.resolveWith<Color>((states) {
          if (tab.selected) {
            return res.textFillColorPrimary;
          } else if (states.isPressed) {
            return res.textFillColorSecondary;
          } else if (states.isHovered) {
            return res.textFillColorPrimary;
          } else if (states.isDisabled) {
            return res.textFillColorDisabled;
          } else {
            return res.textFillColorSecondary;
          }
        }).resolve(states);

        /// https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/TabView/TabView_themeresources.xaml#L10-L14
        final backgroundColor =
            WidgetStateProperty.resolveWith<Color>((states) {
          if (tab.selected) {
            return res.solidBackgroundFillColorTertiary;
          } else if (states.isPressed) {
            return res.layerOnMicaBaseAltFillColorDefault;
          } else if (states.isHovered) {
            return res.layerOnMicaBaseAltFillColorSecondary;
          } else if (states.isDisabled) {
            return res.layerOnMicaBaseAltFillColorTransparent;
          } else {
            return res.layerOnMicaBaseAltFillColorTransparent;
          }
        }).resolve(states);

        const borderRadius = BorderRadius.vertical(top: Radius.circular(6));
        Widget child = FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          style: const FocusThemeData(borderRadius: borderRadius),
          child: Container(
            key: widget._tabKey,
            height: _kTileHeight,
            constraints: tab.tabWidthBehavior == TabWidthBehavior.sizeToContent
                ? const BoxConstraints(minHeight: 28.0)
                : const BoxConstraints(
                    maxWidth: _kMaxTileWidth,
                    minHeight: 28.0,
                  ),
            padding: tab.selected
                ? const EdgeInsetsDirectional.only(
                    start: 9,
                    top: 3,
                    end: 5,
                    bottom: 4,
                  )
                : const EdgeInsetsDirectional.only(
                    start: 8,
                    top: 3,
                    end: 4,
                    bottom: 3,
                  ),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              // if selected, the background is painted by _TabPainter
              color: (tab.selected
                      ? widget.selectedBackgroundColor
                      : widget.backgroundColor) ??
                  backgroundColor,
            ),
            child: () {
              final result = ClipRect(
                child: DefaultTextStyle.merge(
                  style: (theme.typography.body ?? const TextStyle()).copyWith(
                    fontSize: 12.0,
                    fontWeight: tab.selected ? FontWeight.w600 : null,
                    color: foregroundColor,
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: foregroundColor,
                      size: 16.0,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.icon != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10.0),
                          child: widget.icon!,
                        ),
                      if (tab.tabWidthBehavior != TabWidthBehavior.compact ||
                          (tab.tabWidthBehavior == TabWidthBehavior.compact &&
                              tab.selected))
                        Flexible(
                          fit: tab.tabWidthBehavior == TabWidthBehavior.equal
                              ? FlexFit.tight
                              : FlexFit.loose,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4.0),
                            child: DefaultTextStyle.merge(
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(fontSize: 12.0),
                              child: widget.text,
                            ),
                          ),
                        ),
                      if (widget.closeIcon != null &&
                          (tab.visibilityMode ==
                                  CloseButtonVisibilityMode.always ||
                              (tab.visibilityMode ==
                                      CloseButtonVisibilityMode.onHover &&
                                  states.isHovered)))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4.0),
                          child: FocusTheme(
                            data: const FocusThemeData(
                              primaryBorder: BorderSide.none,
                              secondaryBorder: BorderSide.none,
                            ),
                            child: Tooltip(
                              message: localizations.closeTabLabel,
                              child: SizedBox(
                                height: 24.0,
                                width: 32.0,
                                child: IconButton(
                                  icon: widget.closeIcon!,
                                  onPressed: tab.onClose,
                                  focusable: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
              );
              if (tab.reorderIndex != null) {
                return ReorderableDragStartListener(
                  index: tab.reorderIndex!,
                  enabled: !widget.disabled,
                  child: result,
                );
              }
              return result;
            }(),
          ),
        );
        if (text != null) {
          child = Tooltip(
            message: text,
            style: const TooltipThemeData(preferBelow: true),
            child: child,
          );
        }
        if (tab.selected) {
          child = CustomPaint(
            painter: _TabPainter(backgroundColor, widget.outlineColor),
            child: child,
          );
        }
        return Semantics(
          selected: tab.selected,
          focusable: true,
          focused: states.isFocused,
          child: SmallIconButton(child: child),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TabPainter extends CustomPainter {
  final Color color;
  final Color? outlineColor;

  const _TabPainter(this.color, this.outlineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const radius = 6.0;
    path
      ..moveTo(-radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width + radius,
        size.height,
      );

    if (outlineColor != null) {
      final outlinePaint = Paint()
        ..color = outlineColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawPath(path, outlinePaint);
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TabPainter oldDelegate) => color != oldDelegate.color;

  @override
  bool shouldRebuildSemantics(_TabPainter oldDelegate) => false;
}

class _TabViewScrollBehavior extends ScrollBehavior {
  const _TabViewScrollBehavior();

  @override
  Widget buildScrollbar(context, child, details) {
    return child;
  }
}
