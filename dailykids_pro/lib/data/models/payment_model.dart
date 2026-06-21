enum FeeType { monthlyTuition, daycare, eventFee, registration, other }
enum PaymentStatus { pending, paid, overdue, cancelled }

/// Fee structure set by management per branch.
class FeeStructure {
  final String id;
  final String branchId;
  final String branchName;
  final String description;
  final FeeType type;
  final double amount;
  final String currency;
  final int dueDayOfMonth; // Day of month payment is due
  final bool isActive;
  final DateTime createdAt;

  FeeStructure({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.description,
    required this.type,
    required this.amount,
    this.currency = 'LKR',
    this.dueDayOfMonth = 5,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        'branchName': branchName,
        'description': description,
        'type': type.name,
        'amount': amount,
        'currency': currency,
        'dueDayOfMonth': dueDayOfMonth,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FeeStructure.fromJson(Map<String, dynamic> json, String docId) {
    return FeeStructure(
      id: docId,
      branchId: json['branchId'] ?? '',
      branchName: json['branchName'] ?? '',
      description: json['description'] ?? '',
      type: _parseFeeType(json['type']),
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'LKR',
      dueDayOfMonth: json['dueDayOfMonth'] ?? 5,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  static FeeType _parseFeeType(String? s) {
    try {
      return FeeType.values.byName(s ?? 'monthlyTuition');
    } catch (_) {
      return FeeType.monthlyTuition;
    }
  }
}

/// Monthly invoice generated per student based on fee structures.
class Invoice {
  final String id;
  final String studentId;
  final String studentName;
  final String parentName;
  final String parentPhone;
  final String? parentEmail;
  final String branchId;
  final String branchName;
  final List<InvoiceLineItem> items;
  final double totalAmount;
  final PaymentStatus status;
  final DateTime dueDate;
  final DateTime generatedAt;
  final DateTime? paidAt;
  final String? receiptId;

  Invoice({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.parentName,
    required this.parentPhone,
    this.parentEmail,
    required this.branchId,
    required this.branchName,
    this.items = const [],
    this.totalAmount = 0.0,
    this.status = PaymentStatus.pending,
    required this.dueDate,
    DateTime? generatedAt,
    this.paidAt,
    this.receiptId,
  }) : generatedAt = generatedAt ?? DateTime.now();
}

class InvoiceLineItem {
  final String description;
  final FeeType type;
  final double amount;

  InvoiceLineItem({
    required this.description,
    required this.type,
    required this.amount,
  });
}

/// Payment receipt record.
class PaymentReceipt {
  final String id;
  final String invoiceId;
  final String studentId;
  final double amount;
  final String paymentMethod; // 'cash', 'bank_transfer', 'online'
  final DateTime paidAt;
  final String? transactionRef;

  PaymentReceipt({
    required this.id,
    required this.invoiceId,
    required this.studentId,
    required this.amount,
    this.paymentMethod = 'online',
    DateTime? paidAt,
    this.transactionRef,
  }) : paidAt = paidAt ?? DateTime.now();
}
