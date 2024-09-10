import 'package:flutter/material.dart';

import 'create_server_page_stub.dart'
    //
    if (dart.library.html) 'create_server_page_web.dart'
    if (dart.library.io) 'create_server_page_io.dart';

Widget CreateServerPageImpl() => createServerPage();
