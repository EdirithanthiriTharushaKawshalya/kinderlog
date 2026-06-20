import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/payment_provider.dart';
import '../../providers/notification_provider.dart';

import '../../data/models/payment_model.dart';

/// Fee structure management and invoice tracking (management view).
class FeeDashboardScreen extends StatefulWidget {
  final bool hideAppBar;
  const FeeDashboardScreen({super.key, this.hideAppBar = false});

  @override
  State<FeeDashboardScreen> createState() => _FeeDashboardScreenState();
}

class _FeeDashboardScreenState extends State<FeeDashboardScreen> {
  String _tab = 'fees'; // 'fees' or 'invoices'

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PaymentProvider>(
      builder: (context, auth, pay, _) {
        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(
                  title: const Text('Fees & Payments'),
                  actions: [
              if (_tab == 'invoices')
                TextButton.icon(
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Generate', style: TextStyle(fontSize: 12)),
                  onPressed: pay.isLoading ? null : () => pay.generateMonthlyInvoices(),
                ),
            ],
          ),
          body: Column(
            children: [
              // Tab selector
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    _tabBtn('Fee Structures', 'fees'),
                    _tabBtn('Invoices', 'invoices'),
                  ],
                ),
              ),
              Expanded(child: _tab == 'fees' ? _feesTab(auth, pay) : _invoicesTab(auth, pay)),
            ],
          ),
          floatingActionButton: _tab == 'fees' && auth.isManagement
              ? FloatingActionButton(
                  backgroundColor: AppTheme.primaryTeal,
                  onPressed: () => _showAddFeeDialog(context, auth, pay),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _tabBtn(String label, String value) {
    final selected = _tab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: selected ? AppTheme.primaryTeal : Colors.transparent, width: 2.5)),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppTheme.primaryTeal : Colors.grey[600],
            fontSize: 13,
          )),
        ),
      ),
    );
  }

  // ---- Fee Structures Tab ----
  Widget _feesTab(AuthProvider auth, PaymentProvider pay) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pay.feeStructures.length,
      itemBuilder: (context, index) {
        final fee = pay.feeStructures[index];
        final currencySymbol = fee.currency == 'LKR' ? 'Rs. ' : '\$';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primaryTeal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fee.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(fee.branchName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Text('$currencySymbol${fee.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryTeal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _tag(fee.type.name),
                    const SizedBox(width: 8),
                    _tag('Due day ${fee.dueDayOfMonth}'),
                    const Spacer(),
                    Icon(fee.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                        color: fee.isActive ? const Color(0xFF16A34A) : Colors.grey, size: 24),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppTheme.bgGrey, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    );
  }

  // ---- Invoices Tab ----
  Widget _invoicesTab(AuthProvider auth, PaymentProvider pay) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pay.invoices.length,
      itemBuilder: (context, index) {
        final inv = pay.invoices[index];
        final statusColor = inv.status == PaymentStatus.paid ? const Color(0xFF16A34A)
            : inv.status == PaymentStatus.overdue ? AppTheme.secondaryCoral : AppTheme.alertAmber;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inv.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('${inv.branchName} · Due ${DateFormat('MMM d').format(inv.dueDate)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currencyFormat.format(inv.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryTeal)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(inv.status.name.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(inv.items.map((i) => i.description).join(' + '),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                if (inv.status != PaymentStatus.paid && auth.isManagement) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: inv.status == PaymentStatus.overdue ? AppTheme.secondaryCoral : const Color(0xFF16A34A),
                              minimumSize: const Size(0, 36)),
                          icon: const Icon(Icons.payment_rounded, size: 16),
                          label: const Text('Record Payment', style: TextStyle(fontSize: 12, color: Colors.white)),
                          onPressed: () => _recordPaymentDialog(context, pay, inv),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            foregroundColor: AppTheme.alertAmber,
                            side: const BorderSide(color: AppTheme.alertAmber),
                          ),
                          icon: const Icon(Icons.notification_important_rounded, size: 16),
                          label: const Text('Notify Parent', style: TextStyle(fontSize: 12)),
                          onPressed: () => _showPaymentReminderDialog(context, auth, inv),
                        ),
                      ),
                    ],
                  ),
                ],
                if (inv.paidAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Paid: ${DateFormat('MMM d, yyyy').format(inv.paidAt!)} · Receipt: ${inv.receiptId ?? "-"}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddFeeDialog(BuildContext context, AuthProvider auth, PaymentProvider pay) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    FeeType type = FeeType.monthlyTuition;
    String? branchId = auth.branches.isNotEmpty ? auth.branches.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Fee Structure', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: branchId,
                  decoration: const InputDecoration(labelText: 'Branch *'),
                  items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: (v) => setDialogState(() => branchId = v),
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description *')),
                const SizedBox(height: 10),
                DropdownButtonFormField<FeeType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Fee Type'),
                  items: FeeType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => type = v ?? FeeType.monthlyTuition),
                ),
                const SizedBox(height: 10),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount (LKR) *'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (descCtrl.text.trim().isEmpty || amountCtrl.text.trim().isEmpty || branchId == null) return;
                final branchName = auth.branches.where((b) => b.id == branchId).firstOrNull?.name ?? '';
                pay.addFeeStructure(branchId: branchId!, branchName: branchName, description: descCtrl.text.trim(), type: type, amount: double.tryParse(amountCtrl.text.trim()) ?? 0);
                Navigator.pop(ctx);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _recordPaymentDialog(BuildContext context, PaymentProvider pay, Invoice inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${inv.studentName}'),
            Text('Amount: Rs. ${inv.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text('Confirm payment receipt?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            onPressed: () {
              pay.recordPayment(invoiceId: inv.id, studentId: inv.studentId, amount: inv.totalAmount);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment recorded! ✓'), backgroundColor: AppTheme.primaryTeal),
              );
            },
            child: const Text('Confirm Payment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentReminderDialog(BuildContext context, AuthProvider auth, Invoice inv) {
    final notif = context.read<NotificationProvider>();
    final msgCtrl = TextEditingController();
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final dueDateStr = DateFormat('MMM d, yyyy').format(inv.dueDate);
    final invoiceDesc = inv.items.map((i) => i.description).join(', ');

    final defaultMessage = 'Dear ${inv.parentName},\n\n'
        'This is a reminder that the payment for ${inv.studentName} is ${inv.status == PaymentStatus.overdue ? 'overdue' : 'pending'}.\n\n'
        'Invoice: $invoiceDesc\n'
        'Amount Due: ${currencyFormat.format(inv.totalAmount)}\n'
        'Due Date: $dueDateStr\n\n'
        'Please settle this payment at your earliest convenience. '
        'If you have already made the payment, please disregard this notice.\n\n'
        'Thank you,\nDailyKids Preschool Management';

    msgCtrl.text = defaultMessage;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.alertAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notification_important_rounded, color: AppTheme.alertAmber, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Payment Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 16, color: AppTheme.primaryTeal),
                          const SizedBox(width: 6),
                          Text(inv.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Parent: ${inv.parentName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('Email: ${inv.parentEmail ?? "N/A"}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(currencyFormat.format(inv.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryCoral)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: inv.status == PaymentStatus.overdue
                                  ? AppTheme.secondaryCoral.withOpacity(0.1)
                                  : AppTheme.alertAmber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              inv.status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: inv.status == PaymentStatus.overdue ? AppTheme.secondaryCoral : AppTheme.alertAmber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('Message to parent:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 6),
                TextField(
                  controller: msgCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertAmber),
            onPressed: () {
              notif.notifyParentAboutPayment(
                parentName: inv.parentName,
                parentEmail: inv.parentEmail ?? 'parent@unknown.com',
                studentName: inv.studentName,
                invoiceDescription: invoiceDesc,
                amountDue: inv.totalAmount,
                dueDate: dueDateStr,
                senderName: auth.currentUser?.name ?? 'Management',
                senderId: auth.currentUser?.id ?? '',
                customMessage: msgCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment reminder sent to ${inv.parentName}! 📨'),
                  backgroundColor: AppTheme.primaryTeal,
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            label: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
