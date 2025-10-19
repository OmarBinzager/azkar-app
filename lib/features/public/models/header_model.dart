class HeaderModel {
  String label;
  int fromHeader, toHeader;
  List<int>? headers;

  HeaderModel({
    required this.label,
    this.fromHeader = -1,
    this.toHeader = -1,
    this.headers,
  }) {
    if(fromHeader != -1 || toHeader != -1){
      headers = [];
      for (int i = fromHeader; i <= toHeader; i++){
        headers!.add(i);
      }
    }
  }
}
