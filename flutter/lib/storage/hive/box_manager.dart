import 'package:flutter_smart_genome/bean/account_bean.dart';
import 'package:flutter_smart_genome/bean/highlight_range.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';
import 'package:flutter_smart_genome/storage/hive/account_list_box.dart';
import 'package:flutter_smart_genome/storage/hive/grouped_track_style_box.dart';
import 'package:flutter_smart_genome/storage/hive/session_list_box.dart';
import 'package:flutter_smart_genome/storage/hive/highlight_box.dart';
import 'package:flutter_smart_genome/storage/hive/site_list_box.dart';
import 'package:flutter_smart_genome/storage/hive/compare_history_box.dart';
import 'package:flutter_smart_genome/storage/hive/track_theme_list_box.dart';
import 'package:flutter_smart_genome/widget/track/base/track_session.dart';
import 'package:flutter_smart_genome/widget/track/base/track_style.dart';
import 'package:flutter_smart_genome/widget/track/base/track_theme.dart';
import 'package:hive/hive.dart';

Future<(bool, String?)> initHiveBox() async {
  Hive.registerAdapter(SiteAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TrackThemeAdapter());
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(TrackStyleAdapter());
  Hive.registerAdapter(HighlightAdapter());
  await Hive.openBox<SiteItem>('sites');
  await Hive.openBox<AccountBean>('accounts');
  await Hive.openBox<TrackTheme>('track-themes');
  await Hive.openBox<TrackSession>('sessions'); // for session list page
  await Hive.openBox<TrackSession>('species-sessions'); //for each species viewed, save the session
  await Hive.openBox('sgs-settings');
  await Hive.openBox('custom-track-styles');
  await Hive.openBox<TrackStyle>('grouped-track-styles');
  await Hive.openBox('grouped-track-list');
  await Hive.openBox<HighlightRange>('highlights');
  await Hive.openBox<List<String>>('compare-history');
  await Hive.openBox<Map>('url-shorten');
  // await BaseStoreProvider.get().checkAndInitTrackTheme();
  // await BaseStoreProvider.get().checkInitServer(SiteBloc.defaultSite);
  return (true, null);
}
