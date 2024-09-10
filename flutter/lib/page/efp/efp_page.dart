import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/page/efp/efp_page_mobile.dart';
import 'package:flutter_smart_genome/page/efp/efp_page_tablet.dart';
import 'package:flutter_smart_genome/widget/basic/custom_multi_size_layout.dart';
import 'package:responsive_builder/responsive_builder.dart';

class EfpPage extends StatefulWidget {
  @override
  _EfpPageState createState() => _EfpPageState();
}

class _EfpPageState extends State<EfpPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      breakpoints: defaultBreakPoints,
      mobile: EfpPageMobile(),
      tablet: EfpPageTablet(),
//      desktop: EfpPageTablet(),
    );
  }
}
