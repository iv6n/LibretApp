import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('locationAssetForType', () {
    test('resolves every approved specific asset from tandas 1 through 5', () {
      final expected = <LocationType, String>{
        LocationType.ranch: 'assets/images/location_ranch.webp',
        LocationType.farm: 'assets/images/location_farm.webp',
        LocationType.finca: 'assets/images/location_finca.webp',
        LocationType.hacienda: 'assets/images/location_hacienda.webp',
        LocationType.plantation: 'assets/images/location_plantation.webp',
        LocationType.ejido: 'assets/images/location_ejido.webp',
        LocationType.corral: 'assets/images/location_corral.webp',
        LocationType.property: 'assets/images/location_property.webp',
        LocationType.homestead: 'assets/images/location_homestead.webp',
        LocationType.feedlot: 'assets/images/location_feedlot.webp',
        LocationType.stable: 'assets/images/location_stable.webp',
        LocationType.pen: 'assets/images/location_pen.webp',
        LocationType.chute: 'assets/images/location_chute.webp',
        LocationType.quarantineArea:
            'assets/images/location_quarantine_area.webp',
        LocationType.loadingArea: 'assets/images/location_loading_area.webp',
        LocationType.weighingArea: 'assets/images/location_weighing_area.webp',
        LocationType.plot: 'assets/images/location_plot.webp',
        LocationType.milpa: 'assets/images/location_milpa.webp',
        LocationType.orchard: 'assets/images/location_orchard.webp',
        LocationType.greenhouse: 'assets/images/location_greenhouse.webp',
        LocationType.nursery: 'assets/images/location_nursery.webp',
        LocationType.garden: 'assets/images/location_garden.webp',
        LocationType.forest: 'assets/images/location_forest.webp',
        LocationType.lagoon: 'assets/images/location_lagoon.webp',
        LocationType.river: 'assets/images/location_river.webp',
        LocationType.wetland: 'assets/images/location_wetland.webp',
        LocationType.protectedArea:
            'assets/images/location_protected_area.webp',
        LocationType.workshop: 'assets/images/location_workshop.webp',
        LocationType.office: 'assets/images/location_office.webp',
        LocationType.dam: 'assets/images/location_dam.webp',
        LocationType.aguada: 'assets/images/location_aguada.webp',
        LocationType.trough: 'assets/images/location_trough.webp',
        LocationType.canal: 'assets/images/location_canal.webp',
        LocationType.reservoir: 'assets/images/location_reservoir.webp',
      };

      for (final entry in expected.entries) {
        expect(locationAssetForType(entry.key), entry.value);
      }
    });

    test('bundles every approved asset from tandas 1 through 5', () async {
      const assets = [
        'assets/images/location_ranch.webp',
        'assets/images/location_farm.webp',
        'assets/images/location_finca.webp',
        'assets/images/location_hacienda.webp',
        'assets/images/location_plantation.webp',
        'assets/images/location_ejido.webp',
        'assets/images/location_corral.webp',
        'assets/images/location_property.webp',
        'assets/images/location_homestead.webp',
        'assets/images/location_feedlot.webp',
        'assets/images/location_stable.webp',
        'assets/images/location_pen.webp',
        'assets/images/location_chute.webp',
        'assets/images/location_quarantine_area.webp',
        'assets/images/location_loading_area.webp',
        'assets/images/location_weighing_area.webp',
        'assets/images/location_plot.webp',
        'assets/images/location_milpa.webp',
        'assets/images/location_orchard.webp',
        'assets/images/location_greenhouse.webp',
        'assets/images/location_nursery.webp',
        'assets/images/location_garden.webp',
        'assets/images/location_forest.webp',
        'assets/images/location_lagoon.webp',
        'assets/images/location_river.webp',
        'assets/images/location_wetland.webp',
        'assets/images/location_protected_area.webp',
        'assets/images/location_aguada.webp',
        'assets/images/location_workshop.webp',
        'assets/images/location_office.webp',
        'assets/images/location_dam.webp',
        'assets/images/location_trough.webp',
        'assets/images/location_canal.webp',
        'assets/images/location_reservoir.webp',
      ];

      for (final asset in assets) {
        final data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(0), reason: asset);
      }
    });
  });
}
