class DataState<T> {
  final T? data;
  final String? error;

  const DataState._({this.data, this.error});

  factory DataState.success(T data) => DataState._(data: data);
  factory DataState.error(String error) => DataState._(error: error);

  bool get isSuccess => error == null;
  bool get isError => error != null;
}
