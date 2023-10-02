class GraphQLResultParser {
  static int parseCount(dynamic data) {
    if (data == null) return 0;

    return data['aggregate']['count'] as int;
  }

  static int parseSum(dynamic json) {
    if (json == null) return 0;

    return json['aggregate']['sum']['value'] as int? ?? 0;
  }
}
