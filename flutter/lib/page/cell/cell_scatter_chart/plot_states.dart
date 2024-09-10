class PlotDrawState<T> {
  bool loading = false;
  String? msg = null;
  T? data;
  bool visible = false;

  update({bool visible = false, bool? loading, String? msg, T? data}) {
    this.visible = visible;
    this.loading = loading ?? this.loading;
    this.msg = msg ?? this.msg;
    this.data = data ?? this.data;
  }
}