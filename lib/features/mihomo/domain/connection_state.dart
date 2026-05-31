enum VpnConnectionPhase {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class PxxConnectionState {
  const PxxConnectionState({
    required this.phase,
    this.currentNodeName,
    this.currentProtocol,
    this.currentIp,
    this.message,
    this.startedAt,
  });

  const PxxConnectionState.disconnected()
      : phase = VpnConnectionPhase.disconnected,
        currentNodeName = null,
        currentProtocol = null,
        currentIp = null,
        message = null,
        startedAt = null;

  final VpnConnectionPhase phase;
  final String? currentNodeName;
  final String? currentProtocol;
  final String? currentIp;
  final String? message;
  final DateTime? startedAt;

  bool get isConnected => phase == VpnConnectionPhase.connected;
  bool get isBusy =>
      phase == VpnConnectionPhase.connecting ||
      phase == VpnConnectionPhase.disconnecting;

  PxxConnectionState copyWith({
    VpnConnectionPhase? phase,
    String? currentNodeName,
    String? currentProtocol,
    String? currentIp,
    String? message,
    DateTime? startedAt,
  }) {
    return PxxConnectionState(
      phase: phase ?? this.phase,
      currentNodeName: currentNodeName ?? this.currentNodeName,
      currentProtocol: currentProtocol ?? this.currentProtocol,
      currentIp: currentIp ?? this.currentIp,
      message: message ?? this.message,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
