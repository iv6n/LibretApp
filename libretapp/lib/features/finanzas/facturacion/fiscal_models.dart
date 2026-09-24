/// Fiscal and payment provider-neutral models.
library;

enum FiscalDocumentStatus { draft, issued, cancelled, rejected, timeout }

class FiscalParty {
  const FiscalParty({required this.rfc, required this.name, required this.postalCode, this.taxRegime = '601', this.cfdiUse = 'G03'});
  final String rfc;
  final String name;
  final String postalCode;
  final String taxRegime;
  final String cfdiUse;
  Map<String, dynamic> toJson() => {'rfc': rfc, 'name': name, 'postalCode': postalCode, 'taxRegime': taxRegime, 'cfdiUse': cfdiUse};
  factory FiscalParty.fromJson(Map<String, dynamic> json) => FiscalParty(rfc: json['rfc'] as String, name: json['name'] as String, postalCode: json['postalCode'] as String, taxRegime: json['taxRegime'] as String? ?? '601', cfdiUse: json['cfdiUse'] as String? ?? 'G03');
}

class FiscalConcept {
  const FiscalConcept({required this.productCode, required this.description, required this.quantity, required this.unit, required this.unitPriceCents, this.taxRate = 0.16});
  final String productCode;
  final String description;
  final double quantity;
  final String unit;
  final int unitPriceCents;
  final double taxRate;
  int get subtotalCents => (quantity * unitPriceCents).round();
  int get taxCents => (subtotalCents * taxRate).round();
  Map<String, dynamic> toJson() => {'productCode': productCode, 'description': description, 'quantity': quantity, 'unit': unit, 'unitPriceCents': unitPriceCents, 'taxRate': taxRate};
  factory FiscalConcept.fromJson(Map<String, dynamic> json) => FiscalConcept(productCode: json['productCode'] as String, description: json['description'] as String, quantity: (json['quantity'] as num).toDouble(), unit: json['unit'] as String, unitPriceCents: (json['unitPriceCents'] as num).toInt(), taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.16);
}

class FiscalInvoice {
  const FiscalInvoice({required this.uuid, required this.farmId, required this.issuer, required this.receiver, required this.concepts, required this.createdAt, this.status = FiscalDocumentStatus.draft, this.providerId, this.xml, this.pdf, this.idempotencyKey, this.error});
  final String uuid;
  final String farmId;
  final FiscalParty issuer;
  final FiscalParty receiver;
  final List<FiscalConcept> concepts;
  final DateTime createdAt;
  final FiscalDocumentStatus status;
  final String? providerId;
  final String? xml;
  final String? pdf;
  final String? idempotencyKey;
  final String? error;
  int get subtotalCents => concepts.fold(0, (sum, item) => sum + item.subtotalCents);
  int get taxCents => concepts.fold(0, (sum, item) => sum + item.taxCents);
  int get totalCents => subtotalCents + taxCents;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'issuer': issuer.toJson(), 'receiver': receiver.toJson(), 'concepts': concepts.map((c) => c.toJson()).toList(), 'createdAt': createdAt.toUtc().toIso8601String(), 'status': status.name, 'providerId': providerId, 'xml': xml, 'pdf': pdf, 'idempotencyKey': idempotencyKey, 'error': error};
  factory FiscalInvoice.fromJson(Map<String, dynamic> json) => FiscalInvoice(uuid: json['uuid'] as String, farmId: json['farmId'] as String, issuer: FiscalParty.fromJson(Map<String, dynamic>.from(json['issuer'] as Map)), receiver: FiscalParty.fromJson(Map<String, dynamic>.from(json['receiver'] as Map)), concepts: ((json['concepts'] as List?) ?? const []).map((c) => FiscalConcept.fromJson(Map<String, dynamic>.from(c as Map))).toList(), createdAt: DateTime.parse(json['createdAt'] as String).toUtc(), status: FiscalDocumentStatus.values.byName(json['status'] as String? ?? 'draft'), providerId: json['providerId'] as String?, xml: json['xml'] as String?, pdf: json['pdf'] as String?, idempotencyKey: json['idempotencyKey'] as String?, error: json['error'] as String?);
}

class PaymentIntent {
  const PaymentIntent({required this.uuid, required this.farmId, required this.amountCents, required this.currency, required this.description, this.status = PaymentStatus.pending, this.providerId, this.checkoutUrl, this.error});
  final String uuid;
  final String farmId;
  final int amountCents;
  final String currency;
  final String description;
  final PaymentStatus status;
  final String? providerId;
  final String? checkoutUrl;
  final String? error;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'amountCents': amountCents, 'currency': currency, 'description': description, 'status': status.name, 'providerId': providerId, 'checkoutUrl': checkoutUrl, 'error': error};
  factory PaymentIntent.fromJson(Map<String, dynamic> json) => PaymentIntent(uuid: json['uuid'] as String, farmId: json['farmId'] as String, amountCents: (json['amountCents'] as num).toInt(), currency: json['currency'] as String, description: json['description'] as String, status: PaymentStatus.values.byName(json['status'] as String? ?? 'pending'), providerId: json['providerId'] as String?, checkoutUrl: json['checkoutUrl'] as String?, error: json['error'] as String?);
}

enum PaymentStatus { pending, succeeded, failed, cancelled }
