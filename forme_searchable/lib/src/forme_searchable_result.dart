class FormeSearchablePageResult<T extends Object> {
  final List<T> datas;
  final int totalPage;

  FormeSearchablePageResult(this.datas, this.totalPage);
}
