class FormeSearchablePageResult<T extends Object> {
  final List<T> datas;
  final int totalPage;

  FormeSearchablePageResult(this.datas, this.totalPage);

  factory FormeSearchablePageResult.fromList(List<T> list) {
    return FormeSearchablePageResult(list, 1);
  }
}
