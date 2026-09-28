import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';
import '../config/ui_values.dart';
import '../services/download_api.dart';

class HomeScreen extends StatefulWidget {
  final AppConfig config;
  final String mode;

  const HomeScreen({super.key, required this.config, required this.mode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _urlController;
  late final DownloadApi _api;
  bool _loading = false;
  String? _platform;
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _api = DownloadApi(widget.config);
    _urlController.addListener(_detectPlatform);
  }

  @override
  void dispose() {
    _urlController
      ..removeListener(_detectPlatform)
      ..dispose();
    super.dispose();
  }

  void _detectPlatform() {
    final url = _urlController.text.trim().toLowerCase();
    String? detected;
    final rules = widget.config.object('platform_detection');
    for (final entry in rules.entries) {
      final domains = List<dynamic>.from(entry.value as List);
      if (domains.any((domain) => url.contains(domain.toString()))) {
        detected = entry.key;
        break;
      }
    }
    if (_platform != detected) {
      setState(() => _platform = detected);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      _urlController.text = text;
    }
  }

  Future<void> _download() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || _platform == null) {
      return;
    }

    setState(() => _loading = true);
    try {
      await _api.download(platform: _platform!, url: url);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.config.string('home.download_success_text')),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.config.string('home.download_error_text')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final mode = widget.mode;
    final size = MediaQuery.sizeOf(context);
    final textPrimary = _color(c.color('theme.modes.$mode.text_primary'));
    final textSecondary = _color(c.color('theme.modes.$mode.text_secondary'));
    final border = _color(c.color('theme.modes.$mode.border'));
    final surface = _color(c.color('theme.modes.$mode.surface'));
    final secondary = _color(c.color('theme.modes.$mode.secondary'));
    final primary = _color(c.color('theme.modes.$mode.primary'));
    final background = _color(c.color('theme.modes.$mode.background'));
    final headerPadding =
        size.width * UiValues.value('home.header.horizontal_padding_factor');

    final navigationHeight =
        size.height * UiValues.value('home.bottom_navigation.height_factor');
    final navigationMargin =
        size.width * UiValues.value('home.bottom_navigation.margin_factor');
    final navigationSpace = navigationHeight + (navigationMargin * 2);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: c.boolean('home.background_image_enabled')
                ? Image.asset(
                    c.homeAsset(mode),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: _color(
                        c.color('theme.background_when_image_missing.$mode'),
                      ),
                    ),
                  )
                : ColoredBox(color: background),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom:
                    navigationSpace +
                    (size.height *
                        UiValues.value('home.scroll_bottom_padding_factor')),
              ),
              child: Column(
                children: [
                  _header(c, size, textPrimary, border, headerPadding),
                  _hero(c, size, textPrimary, textSecondary),
                  _inputCard(
                    c,
                    size,
                    textPrimary,
                    textSecondary,
                    border,
                    surface,
                  ),
                  SizedBox(
                    height:
                        size.height *
                        UiValues.value('home.download_button.gap_factor'),
                  ),
                  _downloadButton(c, size, textPrimary),
                  _platforms(c, size, textPrimary, textSecondary, border),
                  _recentDownloads(
                    c,
                    size,
                    textPrimary,
                    textSecondary,
                    border,
                    surface,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _bottomNavigation(
                c,
                size,
                textPrimary,
                textSecondary,
                border,
                primary,
                secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(
    AppConfig c,
    Size size,
    Color text,
    Color border,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        size.height * UiValues.value('home.header.top_padding_factor'),
        horizontalPadding,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconButton(c, c.string('home.header.menu_icon'), text, border),
          _iconButton(c, c.string('home.header.settings_icon'), text, border),
        ],
      ),
    );
  }

  Widget _hero(AppConfig c, Size size, Color primaryText, Color secondaryText) {
    final titleStart = _color(c.color('home.hero.title_gradient_start'));
    final titleEnd = _color(c.color('home.hero.title_gradient_end'));
    return Column(
      children: [
        Image.asset(
          c.string('assets.app_logo'),
          width: size.width * UiValues.value('home.hero.logo_size_factor'),
          height: size.width * UiValues.value('home.hero.logo_size_factor'),
        ),
        SizedBox(
          height: size.height * UiValues.value('home.hero.logo_gap_factor'),
        ),
        ShaderMask(
          shaderCallback: (bounds) =>
              LinearGradient(colors: [titleStart, titleEnd])
                  .createShader(bounds),
          child: Text(
            c.string('home.hero.title'),
            style: TextStyle(
              color: primaryText,
              fontSize:
                  size.width * UiValues.value('home.hero.title_size_factor'),
              fontWeight:
                  FontWeight.values[(UiValues.integer(
                            'home.hero.title_weight',
                          ) ~/
                          100) -
                      1],
            ),
          ),
        ),
        SizedBox(
          height: size.height * UiValues.value('home.hero.title_gap_factor'),
        ),
        Text(
          c.string('home.hero.subtitle'),
          style: TextStyle(
            color: primaryText,
            fontSize:
                size.width * UiValues.value('home.hero.subtitle_size_factor'),
          ),
        ),
        SizedBox(
          height: size.height * UiValues.value('home.hero.tagline_gap_factor'),
        ),
        Text(
          c.string('home.hero.tagline'),
          style: TextStyle(
            color: secondaryText,
            fontSize:
                size.width * UiValues.value('home.hero.tagline_size_factor'),
          ),
        ),
      ],
    );
  }

  Widget _inputCard(
    AppConfig c,
    Size size,
    Color textPrimary,
    Color textSecondary,
    Color border,
    Color surface,
  ) {
    final alpha = widget.mode == 'dark'
        ? UiValues.value('home.input.background_alpha_dark').toDouble()
        : UiValues.value('home.input.background_alpha_light').toDouble();
    return Container(
      height: size.height * UiValues.value('home.input.height_factor'),
      margin: EdgeInsets.symmetric(
        horizontal:
            size.width * UiValues.value('home.input.horizontal_margin_factor'),
      ),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(
          UiValues.value('home.input.radius'),
        ),
        border: Border.all(
          color: border,
          width: UiValues.value('home.input.border_width'),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  size.width *
                  UiValues.value('home.input.content_padding_factor'),
            ),
            child: Icon(
              _icon(c.string('home.input.link_icon')),
              color: textPrimary,
              size: UiValues.value('home.input.icon_size').toDouble(),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: TextStyle(
                color: textPrimary,
                fontSize:
                    size.width * UiValues.value('home.input.text_size_factor'),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: c.string('home.input.hint'),
                hintStyle: TextStyle(
                  color: textSecondary,
                  fontSize:
                      size.width *
                      UiValues.value('home.input.text_size_factor'),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _paste,
            icon: Icon(
              _icon(c.string('home.input.paste_icon')),
              color: textPrimary,
              size: UiValues.value('home.input.icon_size').toDouble(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadButton(AppConfig c, Size size, Color text) {
    return GestureDetector(
      onTap: _loading ? null : _download,
      child: Container(
        height:
            size.height * UiValues.value('home.download_button.height_factor'),
        margin: EdgeInsets.symmetric(
          horizontal:
              size.width *
              UiValues.value('home.download_button.horizontal_margin_factor'),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _color(c.color('home.download_button.gradient_start')),
              _color(c.color('home.download_button.gradient_middle')),
              _color(c.color('home.download_button.gradient_end')),
            ],
          ),
          borderRadius: BorderRadius.circular(
            UiValues.value('home.download_button.radius'),
          ),
        ),
        child: Center(
          child: _loading
              ? CircularProgressIndicator(color: text)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon(c.string('home.download_button.icon')),
                      color: text,
                      size: UiValues.value('home.download_button.icon_size')
                          .toDouble(),
                    ),
                    SizedBox(
                      width:
                          size.width *
                          UiValues.value('home.content_spacing_factor'),
                    ),
                    Text(
                      c.string('home.download_button.text'),
                      style: TextStyle(
                        color: text,
                        fontSize:
                            size.width *
                            UiValues.value(
                              'home.download_button.text_size_factor',
                            ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _platforms(
    AppConfig c,
    Size size,
    Color textPrimary,
    Color textSecondary,
    Color border,
  ) {
    final items = c.list('home.platforms.items');
    return Padding(
      padding: EdgeInsets.only(
        top: size.height * UiValues.value('home.platforms.top_gap_factor'),
      ),
      child: Row(
        children: items.map((raw) {
          final item = Map<String, dynamic>.from(raw as Map);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    size.width *
                    UiValues.value('home.platforms.horizontal_gap_factor'),
              ),
              child: Column(
                children: [
                  Container(
                    height:
                        size.height *
                        UiValues.value('home.platforms.card_height_factor'),
                    margin: EdgeInsets.symmetric(
                      horizontal:
                          size.width *
                          UiValues.value(
                            'home.platforms.horizontal_margin_factor',
                          ),
                    ),
                    decoration: BoxDecoration(
                      color:
                          _color(c.color('theme.modes.${widget.mode}.surface'))
                              .withValues(
                                alpha: UiValues.value(
                                  'home.platforms.surface_alpha',
                                ),
                              ),
                      borderRadius: BorderRadius.circular(
                        UiValues.value('home.platforms.radius'),
                      ),
                      border: Border.all(
                        color: border,
                        width: UiValues.value('home.platforms.border_width'),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        size.width *
                            UiValues.value('home.platforms.logo_size_factor') *
                            0.12,
                      ),
                      child: Image.asset(item['logo'] as String),
                    ),
                  ),
                  SizedBox(
                    height:
                        size.height *
                        UiValues.value('home.platforms.label_gap_factor'),
                  ),
                  Text(
                    item['name'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize:
                          size.width *
                          UiValues.value('home.platforms.label_size_factor'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _recentDownloads(
    AppConfig c,
    Size size,
    Color textPrimary,
    Color textSecondary,
    Color border,
    Color surface,
  ) {
    if (!c.boolean('home.recent_downloads.enabled')) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            size.width *
            UiValues.value('home.recent_downloads.content_margin_factor'),
      ),
      child: Column(
        children: [
          SizedBox(
            height:
                size.height *
                UiValues.value('home.recent_downloads.top_gap_factor'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.string('home.recent_downloads.title'),
                style: TextStyle(
                  color: textPrimary,
                  fontSize:
                      size.width *
                      UiValues.value('home.recent_downloads.title_size_factor'),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                c.string('home.recent_downloads.see_all'),
                style: TextStyle(
                  color: _color(
                    c.color('theme.modes.${widget.mode}.secondary'),
                  ),
                  fontSize:
                      size.width *
                      UiValues.value(
                        'home.recent_downloads.see_all_size_factor',
                      ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height:
                size.height *
                UiValues.value('home.recent_downloads.item_gap_factor'),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical:
                  size.height *
                  UiValues.value('home.recent_downloads.item_gap_factor'),
            ),
            child: Text(
              c.string('home.recent_downloads.empty_text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize:
                    size.width *
                    UiValues.value('home.recent_downloads.see_all_size_factor'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation(
    AppConfig c,
    Size size,
    Color textPrimary,
    Color textSecondary,
    Color border,
    Color primary,
    Color secondary,
  ) {
    final items = c.list('home.bottom_navigation.items');
    return Container(
      height:
          size.height * UiValues.value('home.bottom_navigation.height_factor'),
      margin: EdgeInsets.all(
        size.width * UiValues.value('home.bottom_navigation.margin_factor'),
      ),
      decoration: BoxDecoration(
        color: _color(c.color('theme.modes.${widget.mode}.surface')).withValues(
          alpha: UiValues.value('home.bottom_navigation.surface_alpha'),
        ),
        borderRadius: BorderRadius.circular(
          UiValues.value('home.bottom_navigation.radius'),
        ),
        border: Border.all(
          color: border,
          width: UiValues.value('home.bottom_navigation.border_width'),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = Map<String, dynamic>.from(items[index] as Map);
          final active = index == _selectedNav;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedNav = index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icon(
                      active
                          ? item['active_icon'] as String
                          : item['icon'] as String,
                    ),
                    color: active ? secondary : textPrimary,
                    size: UiValues.value('home.bottom_navigation.icon_size')
                        .toDouble(),
                  ),
                  SizedBox(
                    height: UiValues.value(
                      'home.bottom_navigation.active_indicator_gap',
                    ).toDouble(),
                  ),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      color: active ? secondary : textPrimary,
                      fontSize:
                          size.width *
                          UiValues.value(
                            'home.bottom_navigation.label_size_factor',
                          ),
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: UiValues.value(
                      'home.bottom_navigation.active_indicator_gap',
                    ).toDouble(),
                  ),
                  Container(
                    width: active
                        ? size.width *
                              UiValues.value(
                                'home.bottom_navigation.active_indicator_width_factor',
                              )
                        : 0,
                    height: UiValues.value(
                      'home.bottom_navigation.active_indicator_height',
                    ).toDouble(),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(
                        UiValues.value(
                          'home.bottom_navigation.active_indicator_radius',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _iconButton(AppConfig c, String iconName, Color color, Color border) {
    return Container(
      width: UiValues.value('home.header.button_size').toDouble(),
      height: UiValues.value('home.header.button_size').toDouble(),
      decoration: BoxDecoration(
        color: _color(c.color('theme.modes.${widget.mode}.surface'))
            .withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(
          color: border,
          width: UiValues.value('home.header.button_border_width'),
        ),
      ),
      child: Icon(
        _icon(iconName),
        color: color,
        size: UiValues.value('home.header.icon_size').toDouble(),
      ),
    );
  }

  IconData _icon(String name) {
    const icons = <String, IconData>{
      'menu': Icons.menu,
      'settings_outlined': Icons.settings_outlined,
      'settings': Icons.settings,
      'link': Icons.link,
      'content_paste_outlined': Icons.content_paste_outlined,
      'download': Icons.download,
      'download_outlined': Icons.download_outlined,
      'home': Icons.home,
      'home_outlined': Icons.home_outlined,
      'history': Icons.history,
      'camera_alt': Icons.camera_alt,
      'facebook': Icons.facebook,
      'push_pin': Icons.push_pin,
      'close': Icons.close,
    };
    if (!icons.containsKey(name)) {
      throw FormatException('Unknown Material icon configured in JSON: $name');
    }
    return icons[name]!;
  }

  Color _color(String hex) => Color(int.parse(hex, radix: 16));
}
