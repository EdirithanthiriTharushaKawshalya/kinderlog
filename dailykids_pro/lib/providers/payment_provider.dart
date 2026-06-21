import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/payment_model.dart';

/// Manages fee structures, invoices, payments, and tracking.
class PaymentProvider extends ChangeNotifier {
  List<FeeStructure> _feeStructures = [];
  List<Invoice> _invoices = [];
  List<PaymentReceipt> _receipts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FeeStructure> get feeStructures => _feeStructures;
  List<Invoice> get invoices => _invoices;
  List<PaymentReceipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PaymentProvider() {
    _initMockData();
  }

  void _initMockData() {
    _feeStructures = [
      FeeStructure(
        id: 'fee_01', branchId: 'branch_01', branchName: 'Ambalangoda',
        description: 'Monthly Tuition — FS1/FS2',
        type: FeeType.monthlyTuition, amount: 8500.0, dueDayOfMonth: 5,
      ),
      FeeStructure(
        id: 'fee_02', branchId: 'branch_01', branchName: 'Ambalangoda',
        description: 'Monthly Tuition — Yellow/Green',
        type: FeeType.monthlyTuition, amount: 7500.0, dueDayOfMonth: 5,
      ),
      FeeStructure(
        id: 'fee_03', branchId: 'branch_01', branchName: 'Ambalangoda',
        description: 'Daycare (Full Day)',
        type: FeeType.daycare, amount: 3500.0, dueDayOfMonth: 5,
      ),
      FeeStructure(
        id: 'fee_04', branchId: 'branch_02', branchName: 'Hikkaduwa',
        description: 'Monthly Tuition — FS1/FS2',
        type: FeeType.monthlyTuition, amount: 8000.0, dueDayOfMonth: 5,
      ),
      FeeStructure(
        id: 'fee_05', branchId: 'branch_01', branchName: 'Ambalangoda',
        description: 'Annual Sports Day Fee',
        type: FeeType.eventFee, amount: 1500.0, dueDayOfMonth: 15,
      ),
    ];

    _invoices = [
      Invoice(
        id: 'inv_01', studentId: 'std_1', studentName: 'Liam Smith',
        parentName: 'John Smith', parentPhone: '+1 (555) 019-2834',
        parentEmail: 'john.smith@email.com',
        branchId: 'branch_01', branchName: 'Ambalangoda',
        items: [
          InvoiceLineItem(description: 'Monthly Tuition — FS1', type: FeeType.monthlyTuition, amount: 8500.0),
          InvoiceLineItem(description: 'Daycare (Full Day)', type: FeeType.daycare, amount: 3500.0),
        ],
        totalAmount: 12000.0, status: PaymentStatus.paid,
        dueDate: DateTime(2026, 6, 5),
        paidAt: DateTime(2026, 6, 3),
        receiptId: 'rec_01',
      ),
      Invoice(
        id: 'inv_02', studentId: 'std_3', studentName: 'Noah Garcia',
        parentName: 'Maria Garcia', parentPhone: '+1 (555) 012-4321',
        parentEmail: 'maria.g@email.com',
        branchId: 'branch_01', branchName: 'Ambalangoda',
        items: [
          InvoiceLineItem(description: 'Monthly Tuition — FS2', type: FeeType.monthlyTuition, amount: 8500.0),
        ],
        totalAmount: 8500.0, status: PaymentStatus.overdue,
        dueDate: DateTime(2026, 6, 5),
      ),
      Invoice(
        id: 'inv_03', studentId: 'std_9', studentName: 'Aanya Patel',
        parentName: 'Raj Patel', parentPhone: '+1 (555) 022-3344',
        parentEmail: 'raj.p@email.com',
        branchId: 'branch_02', branchName: 'Hikkaduwa',
        items: [
          InvoiceLineItem(description: 'Monthly Tuition — FS1', type: FeeType.monthlyTuition, amount: 8000.0),
          InvoiceLineItem(description: 'Sports Day Fee', type: FeeType.eventFee, amount: 1500.0),
        ],
        totalAmount: 9500.0, status: PaymentStatus.pending,
        dueDate: DateTime(2026, 6, 5),
      ),
    ];

    _receipts = [
      PaymentReceipt(
        id: 'rec_01', invoiceId: 'inv_01', studentId: 'std_1',
        amount: 12000.0, paymentMethod: 'online',
        paidAt: DateTime(2026, 6, 3), transactionRef: 'TXN-001',
      ),
    ];
  }

  /// Get fee structures for a branch.
  List<FeeStructure> feesForBranch(String branchId) =>
      _feeStructures.where((f) => f.branchId == branchId).toList();

  /// Get invoices for a student (parent view).
  List<Invoice> invoicesForStudent(String studentId) =>
      _invoices.where((i) => i.studentId == studentId).toList();

  /// Get all invoices for a branch (management view).
  List<Invoice> invoicesForBranch(String branchId) =>
      _invoices.where((i) => i.branchId == branchId).toList();

  /// Add a fee structure (management).
  Future<void> addFeeStructure({
    required String branchId,
    required String branchName,
    required String description,
    required FeeType type,
    required double amount,
    int dueDay = 5,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final fee = FeeStructure(
        id: 'fee_${const Uuid().v4().substring(0, 6)}',
        branchId: branchId, branchName: branchName,
        description: description, type: type,
        amount: amount, dueDayOfMonth: dueDay,
      );
      _feeStructures.add(fee);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate monthly invoices for all students (management).
  Future<void> generateMonthlyInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would iterate over active students and create invoices
      // For mock, we add one sample
      _invoices.add(Invoice(
        id: 'inv_${const Uuid().v4().substring(0, 6)}',
        studentId: 'std_2', studentName: 'Emma Johnson',
        parentName: 'Sarah Johnson', parentPhone: '+1 (555) 014-9843',
        parentEmail: 'sarah.j@email.com',
        branchId: 'branch_01', branchName: 'Ambalangoda',
        items: [InvoiceLineItem(description: 'Monthly Tuition — FS1', type: FeeType.monthlyTuition, amount: 8500.0)],
        totalAmount: 8500.0, status: PaymentStatus.pending,
        dueDate: DateTime(2026, 7, 5),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record a payment (management).
  Future<void> recordPayment({
    required String invoiceId,
    required String studentId,
    required double amount,
    String method = 'online',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final receipt = PaymentReceipt(
        id: 'rec_${const Uuid().v4().substring(0, 6)}',
        invoiceId: invoiceId, studentId: studentId,
        amount: amount, paymentMethod: method,
        transactionRef: 'TXN-${const Uuid().v4().substring(0, 4).toUpperCase()}',
      );
      _receipts.add(receipt);

      // Update invoice status
      final invIdx = _invoices.indexWhere((i) => i.id == invoiceId);
      if (invIdx != -1) {
        final inv = _invoices[invIdx];
        _invoices[invIdx] = Invoice(
          id: inv.id, studentId: inv.studentId, studentName: inv.studentName,
          parentName: inv.parentName, parentPhone: inv.parentPhone,
          parentEmail: inv.parentEmail, branchId: inv.branchId,
          branchName: inv.branchName, items: inv.items,
          totalAmount: inv.totalAmount, status: PaymentStatus.paid,
          dueDate: inv.dueDate, generatedAt: inv.generatedAt,
          paidAt: DateTime.now(), receiptId: receipt.id,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
