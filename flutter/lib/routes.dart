import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/bloc/sgs_context/sgs_browse_logic.dart';
import 'package:flutter_smart_genome/components/developing_widget.dart';
import 'package:flutter_smart_genome/components/range_info_widget.dart';
import 'package:flutter_smart_genome/page/admin/project/project_home_view.dart';
import 'package:flutter_smart_genome/page/admin/sc/edit_single_cell_page.dart';
import 'package:flutter_smart_genome/page/admin/track/edit_track_page.dart';
import 'package:flutter_smart_genome/page/admin/species/species_edit_page.dart';
import 'package:flutter_smart_genome/page/admin/track/track_list_page.dart';
import 'package:flutter_smart_genome/page/blast/blast_form_page.dart';
import 'package:flutter_smart_genome/page/blast/blast_page.dart';
import 'package:flutter_smart_genome/page/cell/cell_page/cell_page_view.dart';
import 'package:flutter_smart_genome/page/chromosome_list/chromosome_list_page.dart';
import 'package:flutter_smart_genome/page/compare/compare_common.dart';
import 'package:flutter_smart_genome/page/data_table/track_data_page.dart';
import 'package:flutter_smart_genome/page/efp/efp_page.dart';
import 'package:flutter_smart_genome/page/home/home_page.dart';
import 'package:flutter_smart_genome/page/admin/user_center.dart';
import 'package:flutter_smart_genome/page/initialize/initialize_page.dart';
import 'package:flutter_smart_genome/page/login/login_page.dart';
import 'package:flutter_smart_genome/page/search/search_page.dart';
import 'package:flutter_smart_genome/page/session/session_widget.dart';
import 'package:flutter_smart_genome/page/setting/setting_page.dart';
import 'package:flutter_smart_genome/page/site/create_server_page.dart';
import 'package:flutter_smart_genome/page/site/site_list_page.dart';
import 'package:flutter_smart_genome/page/track/chr_range_search_widget.dart';
import 'package:flutter_smart_genome/page/track/sgs_browse_page.dart';
import 'package:flutter_smart_genome/page/track/theme/track_theme_selector_widget.dart';
import 'package:flutter_smart_genome/page/track/track_selector_page.dart';
import 'package:flutter_smart_genome/util/device_info.dart';
import 'package:flutter_smart_genome/util/logger.dart';
import 'package:flutter_smart_genome/extensions/string_extensions.dart';
import 'package:flutter_smart_genome/widget/track/base/track_data.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/chromosome/chromosome_data.dart';
import 'package:flutter_smart_genome/widget/track/common.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class RoutePath {
  static const String initialize = '/initialize';
  static const String chromosome_list = '/chromosome.list';
  static const String blast_form = '/blast.form';
  static const String blast_result = '/blast.result';
  static const String search = '/search';
  static const String track = '/gbrowser';

  static const String feature_info = '/feature.info';

  static const String efp = '/efp';
  static const String compare_browser = '/comp.browser';
  static const String track_selector = '/track.selector';
  static const String chr_range_search = '/chr.range.search';
  static const String gene_detail = '/gene.detail';
  static const String site_list = '/site.list';
  static const String home = '/home';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String user_center = '/user.center';
  static const String session = '/session';
  static const String manage_user = '/user.list';
  static const String manage_file = '/file.list';
  static const String project_home_page = '/project/home';
  static const String manage_genome_list = '/species';
  static const String manage_genome_edit = '/species.edit';
  static const String manage_genome_tracks = '/admin.track.list';
  static const String manage_genome_track_add = '/admin.track.add';
  static const String manage_sc_list = '/admin.cell.list';
  static const String manage_sc_add = '/admin.cell.add';
  static const String server_create = '/server.create';
  static const String species_info = '/species.info';
  static const String tools_hi_c = '/hi_c';
  static const String tools_pan_genome = '/pangenome';
  static const String tools_synteny = '/synteny';
  static const String tools_ortholog = '/ortholog';
  static const String tools_help = '/help';
  static const String model_cell = '/cell';
  static const String model_track_theme = '/track.theme';
  static const String model_data_table = '/track.data';
}

Map<String, WidgetBuilder> buildRoutes() {
  return <String, WidgetBuilder>{
    RoutePath.search: (context) => SearchPage(),
    RoutePath.site_list: (context) => SiteListPage(),
//    RoutePath.home: (context) => HomePage(),
    RoutePath.initialize: (context) => InitializePage(),
  };
}

Route<dynamic> onCreateRoute(RouteSettings settings) {
  var routingData = settings.name!.parseRoutingData;
  var arguments = settings.arguments;

  var path = routingData.route;
  logger.i('on create route ${settings.name} path: $path');
  bool asDialog = false;

  var pageWidget;
  switch (path) {
    case RoutePath.home:
      pageWidget = HomePage();
      break;
    case RoutePath.track:
      TrackSession? session = arguments as TrackSession?;
      pageWidget = SgsBrowsePage(session: session);
      break;
    case RoutePath.chr_range_search:
      asDialog = true;
      Map? map = arguments as Map?;
      Range range = map!['range'];
      ChromosomeData chr = map['chr'];
      var speciesId = map['species'];
      pageWidget = ChrRangeSearchWidget(
        chromosome: chr,
        range: range,
        speciesId: speciesId,
      );
      break;
    case RoutePath.feature_info:
      asDialog = true;
      Map? params = arguments as Map?;
      pageWidget = RangeInfoWidget(
        feature: params!['feature'],
        chr: params['chr'],
        species: params['species'],
        track: params['track'],
      );
      break;
    case RoutePath.blast_form:
      pageWidget = BlastFormPage();
      break;
    case RoutePath.blast_result:
      pageWidget = BlastPage();
      break;
    case RoutePath.efp:
      pageWidget = EfpPage();
      break;
    case RoutePath.compare_browser:
      List<CompareItem> items = arguments as List<CompareItem>;
      // pageWidget = ComparePage(items: items);
      pageWidget = Scaffold();
      break;
    case RoutePath.track_selector:
      // asDialog = true;
      pageWidget = TrackSelectorPage();
      break;
    case RoutePath.session:
      // asDialog = true;
      TrackSession? _session = arguments as TrackSession?;
      pageWidget = SessionWidget(asPage: true, currentSession: _session);
      break;
    // case RoutePath.gene_detail:
    //   List params = arguments as List;
    //   pageWidget = GeneInfoDetailPage(geneInfo: params[0], tab: params[1]);
    //   break;
    case RoutePath.chromosome_list:
      Map params = arguments as Map;
      asDialog = true;
      pageWidget = ChromosomeListPage(species: params['species'], chr: params['chr'], chr2: params['chr2']);
      break;
    case RoutePath.login:
      asDialog = true;
      SiteItem? site = arguments as SiteItem?;
      pageWidget = LoginPage(site: site!);
      break;
    case RoutePath.user_center:
      AccountBean? account = arguments as AccountBean?;
      pageWidget = UserCenterWidget(account: account!);
      break;
    case RoutePath.settings:
      pageWidget = SettingPage();
      break;
    // case RoutePath.manage_user:
    //   pageWidget = UserManagePage();
    //   break;
    case RoutePath.manage_file:
      // pageWidget = FileManagePage();
      break;
    case RoutePath.project_home_page:
      SpeciesEditParams params = arguments as SpeciesEditParams;
      pageWidget = ProjectHomeView(project: params.species!, site: params.site);
      break;
    case RoutePath.manage_genome_edit:
      SpeciesEditParams? params = arguments as SpeciesEditParams?;
      asDialog = params!.asDialog;
      pageWidget = SpeciesEditPage(species: params.species, site: params.site, account: params.account);
      break;
    case RoutePath.manage_genome_tracks:
      SpeciesEditParams? params = arguments as SpeciesEditParams?;
      asDialog = params!.asDialog;
      pageWidget = TrackListPage(species: params.species!, site: params.site, account: params.account);
      break;
    case RoutePath.manage_genome_track_add:
      SpeciesEditParams? params = arguments as SpeciesEditParams?;
      asDialog = params!.asDialog;
      pageWidget = EditTrackPage(species: params.species, site: params.site, account: params.account);
      break;
    // case RoutePath.manage_species_single_cell_list:
    //   SpeciesEditParams params = arguments;
    //   asDialog = params.asDialog;
    //   pageWidget = SCDataListView( site: params.site);
    //   break;
    case RoutePath.manage_sc_add:
      SpeciesEditParams? params = arguments as SpeciesEditParams?;
      asDialog = params!.asDialog;
      pageWidget = EditSingleCellPage(species: params.species!, site: params.site);
      break;
    case RoutePath.server_create:
      pageWidget = CreateServerPageImpl();
      break;
    case RoutePath.search:
      pageWidget = SearchPage();
      break;
    case RoutePath.model_cell:
      Track? track = arguments as Track?;
      pageWidget = CellPage(track: track, asPage: true);
      break;
    case RoutePath.model_track_theme:
      TrackType? trackType = arguments as TrackType?;
      pageWidget = TrackThemeSelectorWidget(
        trackType: trackType,
        onThemeChange: (trackTheme, trackType) {
          SgsBrowseLogic.safe()?.changeTheme(trackTheme, trackType);
        },
      );
      break;
    case RoutePath.model_data_table:
      Track? track = arguments as Track?;
      pageWidget = TrackDataPage(track: track!);
      break;
    case RoutePath.species_info:
    case RoutePath.tools_hi_c:
    case RoutePath.tools_pan_genome:
    case RoutePath.tools_synteny:
    case RoutePath.tools_ortholog:
    case RoutePath.tools_help:
      pageWidget = DevelopingWidget();
      break;
    default:
      pageWidget = Material(
        child: Center(
          child: Text('${path} not found'),
        ),
      );
      break;
  }

  if (kIsWeb) {
    return NoAnimationMaterialPageRoute(
      builder: (context) => pageWidget,
      settings: settings,
    );
  }
  if (asDialog && (DeviceOS.isDesktopOrWeb))
    return RawDialogRoute(pageBuilder: (c, a, b) {
      return Container(
        color: Colors.black45.withAlpha(88),
        child: Center(
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 900, height: 600),
              child: pageWidget,
            ),
          ),
        ),
      );
    });
  return MaterialPageRoute(
    settings: settings,
    fullscreenDialog: asDialog,
    builder: (context) => pageWidget,
  );

//  return MaterialPageRoute(
//    builder: (context) => Scaffold(
//      appBar: AppBar(title: Text('Page Not found')),
//      body: Center(
//        child: LoadingWidget(
//          loadingState: LoadingState.notImplemented,
//          message: 'Page Not Found ${path}',
//        ),
//      ),
//    ),
//  );
}

PageRouteBuilder<T> animateRoute<T>(Widget child) {
  return PageRouteBuilder(
    opaque: false,
    pageBuilder: (BuildContext context, _, __) => child,
    transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child),
      );
    },
  );
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
