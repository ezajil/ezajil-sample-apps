class PageResult<T> {
  final List<T> results;
  final String pagingState;
  final int totalResults;

  PageResult(
      {required this.results,
      required this.pagingState,
      required this.totalResults});
}
