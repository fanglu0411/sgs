/// Maps the index value.
typedef ChartIndexedValueMapper<R> = R Function(int index);

/// Maps the data from data source.
typedef ChartValueMapper<T, R> = R Function(T datum, int index);

typedef ChartGroupedValueMapper<T, R, G> = R Function(T datum, int index, G group);
