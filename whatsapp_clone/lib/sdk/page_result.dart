
class PageResult<T> {
  List<T> results;
  String pagingState;
  int totalResults;

  PageResult(List<T> results, String pagingState, int totalResults) {
    results = results;
    pagingState = pagingState;
    totalResults = totalResults;
  }
}