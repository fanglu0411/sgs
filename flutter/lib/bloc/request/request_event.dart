import 'package:equatable/equatable.dart';
import 'package:flutter_smart_genome/bean/site_item.dart';

abstract class RequestEvent extends Equatable {}

class Fetch extends RequestEvent {
  final Map<String, dynamic> params;
  final SiteItem site;

  Fetch({
    required this.site,
    this.params = const {},
  });

  Fetch copy({SiteItem? site, Map<String, dynamic>? params}) {
    return Fetch(site: site ?? this.site, params: params ?? this.params);
  }

  @override
  String toString() {
    return 'Fetch';
  }

  @override
  List<Object> get props => [site];
}

class CreateEvent extends RequestEvent {
  final Map<String, dynamic> data;

  final SiteItem site;

  CreateEvent(this.data, this.site);

  @override
  List<Object> get props => [data, site];
}

class UpdateEvent extends RequestEvent {
  final Map<String, dynamic> data;
  final String id;
  final SiteItem site;
  UpdateEvent(this.id, this.data, this.site);

  @override
  List<Object> get props => [id, data, site];
}

class DeleteEvent extends RequestEvent {
  final String id;
  final SiteItem site;
  DeleteEvent(this.id, this.site);

  @override
  List<Object> get props => [id, site];
}

class LoadingEvent extends RequestEvent {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}