library;

import 'subscription_models.dart';

class SubscriptionService {
  const SubscriptionService();
  SubscriptionPlan plan(String id) => SubscriptionCatalog.plans.firstWhere((p) => p.id == id);
  bool canUse({required FarmSubscription subscription, required String feature, required int animalCount}) {
    final selected = plan(subscription.planId);
    return subscription.status != SubscriptionStatus.expired && selected.allows(animalCount) && selected.features.contains(feature);
  }
}
