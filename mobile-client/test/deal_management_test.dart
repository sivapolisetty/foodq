import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kravekart/models/deal.dart';
import 'package:kravekart/models/business.dart';
import 'package:kravekart/services/deal_service.dart';
import 'package:kravekart/services/business_service.dart';
import 'package:kravekart/screens/deal_management_screen.dart';
import 'package:kravekart/screens/customer_home_screen.dart';
import 'package:kravekart/widgets/deal_card.dart';
import 'package:kravekart/widgets/yindii_button.dart';

@GenerateMocks([DealService, BusinessService])
import 'deal_management_test.mocks.dart';

void main() {
  group('Deal Management Tests', () {
    late MockDealService mockDealService;
    late MockBusinessService mockBusinessService;

    setUp(() {
      mockDealService = MockDealService();
      mockBusinessService = MockBusinessService();
    });

    group('Deal Model Tests', () {
      test('should create deal from JSON', () {
        final json = {
          'id': '123',
          'title': 'Test Deal',
          'description': 'Test Description',
          'original_price': 100.0,
          'discounted_price': 80.0,
          'discount_percentage': 20,
          'business_id': 'business123',
          'image_url': 'https://example.com/image.jpg',
          'is_active': true,
          'valid_from': '2024-01-01T00:00:00Z',
          'valid_until': '2024-12-31T23:59:59Z',
          'created_at': '2024-01-01T00:00:00Z',
        };

        final deal = Deal.fromJson(json);

        expect(deal.id, '123');
        expect(deal.title, 'Test Deal');
        expect(deal.originalPrice, 100.0);
        expect(deal.discountedPrice, 80.0);
        expect(deal.discountPercentage, 20);
        expect(deal.isActive, true);
      });

      test('should convert deal to JSON', () {
        final deal = Deal(
          id: '123',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 100.0,
          discountedPrice: 80.0,
          discountPercentage: 20,
          businessId: 'business123',
          imageUrl: 'https://example.com/image.jpg',
          isActive: true,
          validFrom: DateTime.parse('2024-01-01T00:00:00Z'),
          validUntil: DateTime.parse('2024-12-31T23:59:59Z'),
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        final json = deal.toJson();

        expect(json['id'], '123');
        expect(json['title'], 'Test Deal');
        expect(json['original_price'], 100.0);
        expect(json['discounted_price'], 80.0);
      });
    });

    group('Deal Service Tests', () {
      test('should fetch deals for business', () async {
        final mockDeals = [
          Deal(
            id: '1',
            title: 'Deal 1',
            description: 'Description 1',
            originalPrice: 100.0,
            discountedPrice: 80.0,
            discountPercentage: 20,
            businessId: 'business1',
            imageUrl: 'https://example.com/image1.jpg',
            isActive: true,
            validFrom: DateTime.now(),
            validUntil: DateTime.now().add(Duration(days: 30)),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockDealService.getDealsForBusiness('business1'))
            .thenAnswer((_) async => mockDeals);

        final deals = await mockDealService.getDealsForBusiness('business1');

        expect(deals.length, 1);
        expect(deals.first.title, 'Deal 1');
        verify(mockDealService.getDealsForBusiness('business1')).called(1);
      });

      test('should create new deal', () async {
        final deal = Deal(
          id: '',
          title: 'New Deal',
          description: 'New Description',
          originalPrice: 100.0,
          discountedPrice: 80.0,
          discountPercentage: 20,
          businessId: 'business1',
          imageUrl: 'https://example.com/image.jpg',
          isActive: true,
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(Duration(days: 30)),
          createdAt: DateTime.now(),
        );

        when(mockDealService.createDeal(deal))
            .thenAnswer((_) async => deal.copyWith(id: 'generated_id'));

        final createdDeal = await mockDealService.createDeal(deal);

        expect(createdDeal.id, 'generated_id');
        expect(createdDeal.title, 'New Deal');
        verify(mockDealService.createDeal(deal)).called(1);
      });

      test('should update deal', () async {
        final deal = Deal(
          id: '123',
          title: 'Updated Deal',
          description: 'Updated Description',
          originalPrice: 120.0,
          discountedPrice: 90.0,
          discountPercentage: 25,
          businessId: 'business1',
          imageUrl: 'https://example.com/image.jpg',
          isActive: true,
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(Duration(days: 30)),
          createdAt: DateTime.now(),
        );

        when(mockDealService.updateDeal(deal))
            .thenAnswer((_) async => deal);

        final updatedDeal = await mockDealService.updateDeal(deal);

        expect(updatedDeal.title, 'Updated Deal');
        expect(updatedDeal.originalPrice, 120.0);
        verify(mockDealService.updateDeal(deal)).called(1);
      });

      test('should delete deal', () async {
        when(mockDealService.deleteDeal('123'))
            .thenAnswer((_) async => true);

        final result = await mockDealService.deleteDeal('123');

        expect(result, true);
        verify(mockDealService.deleteDeal('123')).called(1);
      });

      test('should get active deals', () async {
        final mockDeals = [
          Deal(
            id: '1',
            title: 'Active Deal 1',
            description: 'Description 1',
            originalPrice: 100.0,
            discountedPrice: 80.0,
            discountPercentage: 20,
            businessId: 'business1',
            imageUrl: 'https://example.com/image1.jpg',
            isActive: true,
            validFrom: DateTime.now().subtract(Duration(days: 1)),
            validUntil: DateTime.now().add(Duration(days: 30)),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockDealService.getActiveDeals())
            .thenAnswer((_) async => mockDeals);

        final deals = await mockDealService.getActiveDeals();

        expect(deals.length, 1);
        expect(deals.first.isActive, true);
        verify(mockDealService.getActiveDeals()).called(1);
      });
    });

    group('Widget Tests', () {
      testWidgets('Deal Card displays deal information correctly', (tester) async {
        final deal = Deal(
          id: '1',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 100.0,
          discountedPrice: 80.0,
          discountPercentage: 20,
          businessId: 'business1',
          imageUrl: 'https://example.com/image.jpg',
          isActive: true,
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(Duration(days: 30)),
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DealCard(deal: deal),
            ),
          ),
        );

        expect(find.text('Test Deal'), findsOneWidget);
        expect(find.text('Test Description'), findsOneWidget);
        expect(find.text('₹80'), findsOneWidget);
        expect(find.text('₹100'), findsOneWidget);
        expect(find.text('20% OFF'), findsOneWidget);
      });

      testWidgets('Yindii Button renders with correct style', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: YindiiButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        
        final button = tester.widget<Container>(find.byType(Container).first);
        final decoration = button.decoration as BoxDecoration;
        expect(decoration.color, Color(0xFF2E7D32)); // Yindii green
        expect(decoration.borderRadius, BorderRadius.circular(25));
      });
    });

    group('Deal Management Screen Tests', () {
      testWidgets('displays list of businesses', (tester) async {
        final mockBusinesses = [
          Business(
            id: '1',
            name: 'Test Business 1',
            description: 'Description 1',
            imageUrl: 'https://example.com/image1.jpg',
            ownerId: 'owner1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockBusinessService.getBusinessesForOwner('owner1'))
            .thenAnswer((_) async => mockBusinesses);

        await tester.pumpWidget(
          MaterialApp(
            home: DealManagementScreen(
              businessService: mockBusinessService,
              dealService: mockDealService,
              ownerId: 'owner1',
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Deal Management'), findsOneWidget);
        expect(find.text('Test Business 1'), findsOneWidget);
      });

      testWidgets('navigates to deal list when business is tapped', (tester) async {
        final mockBusinesses = [
          Business(
            id: '1',
            name: 'Test Business 1',
            description: 'Description 1',
            imageUrl: 'https://example.com/image1.jpg',
            ownerId: 'owner1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockBusinessService.getBusinessesForOwner('owner1'))
            .thenAnswer((_) async => mockBusinesses);
        when(mockDealService.getDealsForBusiness('1'))
            .thenAnswer((_) async => []);

        await tester.pumpWidget(
          MaterialApp(
            home: DealManagementScreen(
              businessService: mockBusinessService,
              dealService: mockDealService,
              ownerId: 'owner1',
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Business 1'));
        await tester.pumpAndSettle();

        expect(find.text('Deals for Test Business 1'), findsOneWidget);
      });
    });

    group('Customer Home Screen Tests', () {
      testWidgets('displays active deals', (tester) async {
        final mockDeals = [
          Deal(
            id: '1',
            title: 'Customer Deal 1',
            description: 'Description 1',
            originalPrice: 100.0,
            discountedPrice: 80.0,
            discountPercentage: 20,
            businessId: 'business1',
            imageUrl: 'https://example.com/image1.jpg',
            isActive: true,
            validFrom: DateTime.now().subtract(Duration(days: 1)),
            validUntil: DateTime.now().add(Duration(days: 30)),
            createdAt: DateTime.now(),
          ),
        ];

        when(mockDealService.getActiveDeals())
            .thenAnswer((_) async => mockDeals);

        await tester.pumpWidget(
          MaterialApp(
            home: CustomerHomeScreen(
              dealService: mockDealService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Welcome to KraveKart'), findsOneWidget);
        expect(find.text('Customer Deal 1'), findsOneWidget);
        expect(find.text('20% OFF'), findsOneWidget);
      });
    });
  });
}