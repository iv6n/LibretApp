library;

import 'fiscal_models.dart';

abstract interface class FiscalProvider {
  Future<FiscalInvoice> issue(FiscalInvoice invoice);
  Future<FiscalInvoice> cancel(FiscalInvoice invoice, {required String reason});
  Future<FiscalInvoice> refresh(FiscalInvoice invoice);
  Future<List<FiscalInvoice>> importExpenseXml(String xml);
}

/// Contract-tested provider. It deliberately never sends production fiscal
/// credentials from the client; replace it with a server proxy when enabled.
class FacturapiSandboxProvider implements FiscalProvider {
  const FacturapiSandboxProvider();

  @override
  Future<FiscalInvoice> issue(FiscalInvoice invoice) async {
    if (invoice.issuer.rfc.isEmpty || invoice.receiver.rfc.isEmpty || invoice.concepts.isEmpty) return _failed(invoice, 'Faltan emisor, receptor o conceptos.');
    return FiscalInvoice(uuid: invoice.uuid, farmId: invoice.farmId, issuer: invoice.issuer, receiver: invoice.receiver, concepts: invoice.concepts, createdAt: invoice.createdAt, status: FiscalDocumentStatus.issued, providerId: 'sandbox-${invoice.uuid}', idempotencyKey: invoice.idempotencyKey ?? invoice.uuid, xml: '<cfdi UUID="sandbox-${invoice.uuid}"/>', pdf: 'sandbox-pdf:${invoice.uuid}');
  }

  @override
  Future<FiscalInvoice> cancel(FiscalInvoice invoice, {required String reason}) async => FiscalInvoice(uuid: invoice.uuid, farmId: invoice.farmId, issuer: invoice.issuer, receiver: invoice.receiver, concepts: invoice.concepts, createdAt: invoice.createdAt, status: FiscalDocumentStatus.cancelled, providerId: invoice.providerId, xml: invoice.xml, pdf: invoice.pdf, idempotencyKey: invoice.idempotencyKey, error: reason);

  @override
  Future<FiscalInvoice> refresh(FiscalInvoice invoice) async => invoice;

  @override
  Future<List<FiscalInvoice>> importExpenseXml(String xml) async {
    if (!xml.contains('<') || !xml.toLowerCase().contains('cfdi')) return const [];
    return [FiscalInvoice(uuid: 'import-${xml.hashCode}', farmId: 'unknown', issuer: const FiscalParty(rfc: 'UNKNOWN', name: 'Proveedor XML', postalCode: '00000'), receiver: const FiscalParty(rfc: 'UNKNOWN', name: 'Finca', postalCode: '00000'), concepts: const [], createdAt: DateTime.now().toUtc(), status: FiscalDocumentStatus.issued, xml: xml)];
  }

  FiscalInvoice _failed(FiscalInvoice invoice, String error) => FiscalInvoice(uuid: invoice.uuid, farmId: invoice.farmId, issuer: invoice.issuer, receiver: invoice.receiver, concepts: invoice.concepts, createdAt: invoice.createdAt, status: FiscalDocumentStatus.rejected, idempotencyKey: invoice.idempotencyKey, error: error);
}

abstract interface class PaymentProvider {
  Future<PaymentIntent> createIntent(PaymentIntent intent);
  Future<PaymentIntent> refresh(PaymentIntent intent);
}

class StripeSandboxProvider implements PaymentProvider {
  const StripeSandboxProvider();
  @override
  Future<PaymentIntent> createIntent(PaymentIntent intent) async => PaymentIntent(uuid: intent.uuid, farmId: intent.farmId, amountCents: intent.amountCents, currency: intent.currency, description: intent.description, status: PaymentStatus.pending, providerId: 'pi_sandbox_${intent.uuid}', checkoutUrl: 'https://checkout.stripe.test/${intent.uuid}');
  @override
  Future<PaymentIntent> refresh(PaymentIntent intent) async => intent;
}
