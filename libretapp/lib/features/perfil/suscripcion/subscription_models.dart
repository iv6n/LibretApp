/// Configurable plans and local entitlement checks.
library;

enum SubscriptionStatus { trial, active, pastDue, cancelled, expired }

class SubscriptionPlan {
  const SubscriptionPlan({required this.id, required this.name, required this.maxAnimals, required this.monthlyCents, required this.features});
  final String id;
  final String name;
  final int? maxAnimals;
  final int monthlyCents;
  final Set<String> features;
  bool allows(int animalCount) => maxAnimals == null || animalCount <= maxAnimals!;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'maxAnimals': maxAnimals, 'monthlyCents': monthlyCents, 'features': features.toList()};
}

class FarmSubscription {
  const FarmSubscription({required this.farmId, required this.planId, required this.status, required this.startedAt, this.trialEndsAt, this.providerId});
  final String farmId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime? trialEndsAt;
  final String? providerId;
}

class SubscriptionCatalog {
  static const plans = <SubscriptionPlan>[
    SubscriptionPlan(id: 'free', name: 'Libre', maxAnimals: 50, monthlyCents: 0, features: {'animals', 'agenda', 'reports'}),
    SubscriptionPlan(id: 'basic', name: 'Básico', maxAnimals: 200, monthlyCents: 19900, features: {'animals', 'agenda', 'reports', 'reproduction', 'finance'}),
    SubscriptionPlan(id: 'ranch', name: 'Rancho', maxAnimals: null, monthlyCents: 49900, features: {'animals', 'agenda', 'reports', 'reproduction', 'finance', 'sync', 'portal'}),
  ];
}
