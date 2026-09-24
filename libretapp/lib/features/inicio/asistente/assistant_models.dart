library;

class AssistantMessage {
  const AssistantMessage({required this.role, required this.content});
  final String role;
  final String content;
}

class AssistantQuery {
  const AssistantQuery({required this.farmId, required this.question, this.readOnly = true});
  final String farmId;
  final String question;
  final bool readOnly;
}

abstract interface class AssistantGateway {
  Future<String> answer(AssistantQuery query, {List<AssistantTool> tools = const []});
}

class AssistantTool {
  const AssistantTool({required this.name, required this.description, required this.execute});
  final String name;
  final String description;
  final Future<Object?> Function(Map<String, dynamic> arguments) execute;
}

/// Local fallback used until the server-side OpenAI Responses proxy is
/// configured. It never invents data and explicitly reports missing context.
class ReadOnlyAssistantGateway implements AssistantGateway {
  const ReadOnlyAssistantGateway();
  @override
  Future<String> answer(AssistantQuery query, {List<AssistantTool> tools = const []}) async =>
      'Asistente en modo lectura: conecta el proveedor para consultar registros de la finca ${query.farmId}. No se ejecutó ninguna escritura.';
}
