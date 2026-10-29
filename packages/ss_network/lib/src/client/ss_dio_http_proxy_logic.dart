/// Value for [HttpClient.findProxy] when [hostPort] is configured, else DIRECT.
String ssHttpProxyFindProxyValue(String hostPort) {
  final trimmed = hostPort.trim();
  if (trimmed.isEmpty) {
    return 'DIRECT';
  }
  return 'PROXY $trimmed';
}
