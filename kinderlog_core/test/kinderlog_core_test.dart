import 'package:flutter_test/flutter_test.dart';
import 'package:kinderlog_core/kinderlog_core.dart';

void main() {
  group('Student Model Tests', () {
    test('should create a Student instance and serialize to/from JSON', () {
      final student = Student(
        id: '1',
        name: 'John Doe',
        parentName: 'Jane Doe',
        parentPhone: '1234567890',
        parentEmail: 'jane.doe@example.com',
        classroom: 'Toddlers',
        branchId: 'branch_abc',
        photoUrl: 'https://example.com/photo.jpg',
        allergies: 'Peanuts',
        notes: 'Needs extra nap time',
      );

      // Verify properties
      expect(student.id, '1');
      expect(student.name, 'John Doe');
      expect(student.parentName, 'Jane Doe');
      expect(student.parentPhone, '1234567890');
      expect(student.parentEmail, 'jane.doe@example.com');
      expect(student.classroom, 'Toddlers');
      expect(student.branchId, 'branch_abc');
      expect(student.photoUrl, 'https://example.com/photo.jpg');
      expect(student.allergies, 'Peanuts');
      expect(student.notes, 'Needs extra nap time');

      // Test toJson()
      final json = student.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'John Doe');
      expect(json['parentName'], 'Jane Doe');
      expect(json['parentPhone'], '1234567890');
      expect(json['parentEmail'], 'jane.doe@example.com');
      expect(json['classroom'], 'Toddlers');
      expect(json['branchId'], 'branch_abc');
      expect(json['photoUrl'], 'https://example.com/photo.jpg');
      expect(json['allergies'], 'Peanuts');
      expect(json['notes'], 'Needs extra nap time');

      // Test fromJson()
      final fromJsonStudent = Student.fromJson(json, '1');
      expect(fromJsonStudent.id, '1');
      expect(fromJsonStudent.name, 'John Doe');
      expect(fromJsonStudent.parentName, 'Jane Doe');
      expect(fromJsonStudent.parentPhone, '1234567890');
      expect(fromJsonStudent.parentEmail, 'jane.doe@example.com');
      expect(fromJsonStudent.classroom, 'Toddlers');
      expect(fromJsonStudent.branchId, 'branch_abc');
      expect(fromJsonStudent.photoUrl, 'https://example.com/photo.jpg');
      expect(fromJsonStudent.allergies, 'Peanuts');
      expect(fromJsonStudent.notes, 'Needs extra nap time');
    });

    test('should copyWith correctly', () {
      final student = Student(
        id: '1',
        name: 'John Doe',
        parentName: 'Jane Doe',
        parentPhone: '1234567890',
        classroom: 'Toddlers',
      );

      final updatedStudent = student.copyWith(
        name: 'John Smith',
        classroom: 'Pre-K',
      );

      expect(updatedStudent.id, '1');
      expect(updatedStudent.name, 'John Smith');
      expect(updatedStudent.parentName, 'Jane Doe');
      expect(updatedStudent.parentPhone, '1234567890');
      expect(updatedStudent.classroom, 'Pre-K');
    });
  });

  group('Preschool Model Tests', () {
    test('should create a Preschool instance and serialize to/from JSON', () {
      final now = DateTime.now();
      final preschool = Preschool(
        id: 'preschool_123',
        name: 'Little Stars',
        ownerEmail: 'owner@littlestars.com',
        logoUrl: 'https://example.com/logo.png',
        createdAt: now,
      );

      expect(preschool.id, 'preschool_123');
      expect(preschool.name, 'Little Stars');
      expect(preschool.ownerEmail, 'owner@littlestars.com');
      expect(preschool.logoUrl, 'https://example.com/logo.png');
      expect(preschool.createdAt, now);

      final json = preschool.toJson();
      expect(json['id'], 'preschool_123');
      expect(json['name'], 'Little Stars');
      expect(json['ownerEmail'], 'owner@littlestars.com');
      expect(json['logoUrl'], 'https://example.com/logo.png');
      expect(json['createdAt'], now.toIso8601String());

      final fromJsonPreschool = Preschool.fromJson(json, 'preschool_123');
      expect(fromJsonPreschool.id, 'preschool_123');
      expect(fromJsonPreschool.name, 'Little Stars');
      expect(fromJsonPreschool.ownerEmail, 'owner@littlestars.com');
      expect(fromJsonPreschool.logoUrl, 'https://example.com/logo.png');
      // Precision loss can occur when comparing DateTime due to parsing, but ISO8601 string parsing is exact
      expect(fromJsonPreschool.createdAt.toUtc(), now.toUtc());
    });
  });
}

