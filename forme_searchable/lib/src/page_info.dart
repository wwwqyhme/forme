class PageInfo {
  final int currentPage;
  final int totalPage;

  bool get hasNextPage => currentPage < totalPage;
  bool get hasPrevPage => currentPage > 1;
  PageInfo(this.currentPage, this.totalPage);
}
