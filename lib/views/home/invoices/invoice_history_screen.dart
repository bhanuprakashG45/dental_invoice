import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<Map<String, dynamic>> invoices = [
    {
      'invoiceNumber': 'INV-2026-001',
      'customer': 'Rahul Sharma',
      'date': DateTime(2026, 8, 8),
      'amount': 5500.0,
      'items': 3,
      'status': 'Paid',
    },
    {
      'invoiceNumber': 'INV-2026-002',
      'customer': 'Priya Reddy',
      'date': DateTime(2026, 8, 7),
      'amount': 3200.0,
      'items': 2,
      'status': 'Pending',
    },
    {
      'invoiceNumber': 'INV-2026-003',
      'customer': 'Arjun Kumar',
      'date': DateTime(2026, 8, 5),
      'amount': 7800.0,
      'items': 4,
      'status': 'Paid',
    },
    {
      'invoiceNumber': 'INV-2026-004',
      'customer': 'Sneha Reddy',
      'date': DateTime(2026, 8, 3),
      'amount': 2400.0,
      'items': 2,
      'status': 'Pending',
    },
    {
      'invoiceNumber': 'INV-2026-005',
      'customer': 'Vikram Singh',
      'date': DateTime(2026, 8, 1),
      'amount': 4500.0,
      'items': 3,
      'status': 'Paid',
    },
  ];

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _fromDate = picked.start;
      _toDate = picked.end;
    });
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  List<Map<String, dynamic>> get filteredInvoices {
    if (_fromDate == null || _toDate == null) {
      return invoices;
    }

    return invoices.where((invoice) {
      final date = invoice['date'] as DateTime;

      final start = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);

      final end = DateTime(
        _toDate!.year,
        _toDate!.month,
        _toDate!.day,
        23,
        59,
        59,
      );

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final invoiceList = filteredInvoices;

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),

      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.wp(4),
              context.hp(2),
              context.wp(4),
              context.hp(1),
            ),
            child: Column(
              children: [
                // Filter Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _fromDate == null
                          ? 'Filter by Date'
                          : 'Change Date Range',
                    ),
                  ),
                ),

                // Selected Filter
                if (_fromDate != null && _toDate != null) ...[
                  SizedBox(height: context.hp(1.2)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.wp(3.5),
                      vertical: context.hp(1.2),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: context.wp(2)),
                        Expanded(
                          child: Text(
                            '${_formatDate(_fromDate!)} - '
                            '${_formatDate(_toDate!)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _clearFilter,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.grey500,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: context.hp(1)),

          // Result Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
            child: Row(
              children: [
                Text(
                  '${invoiceList.length} Invoices',
                  style: AppTextStyles.titleMedium,
                ),
                const Spacer(),
                if (_fromDate != null)
                  Text(
                    'Filtered',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: context.hp(1)),

          // Invoice List
          Expanded(
            child: invoiceList.isEmpty
                ? const _EmptyInvoiceState()
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.wp(4),
                      0,
                      context.wp(4),
                      context.hp(3),
                    ),
                    itemCount: invoiceList.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: context.hp(1.2)),
                    itemBuilder: (context, index) {
                      final invoice = invoiceList[index];

                      return _InvoiceHistoryCard(
                        invoiceNumber: invoice['invoiceNumber'],
                        customer: invoice['customer'],
                        date: invoice['date'],
                        amount: invoice['amount'],
                        items: invoice['items'],
                        status: invoice['status'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// INVOICE HISTORY CARD
// ========================================================

class _InvoiceHistoryCard extends StatelessWidget {
  final String invoiceNumber;
  final String customer;
  final DateTime date;
  final double amount;
  final int items;
  final String status;

  const _InvoiceHistoryCard({
    required this.invoiceNumber,
    required this.customer,
    required this.date,
    required this.amount,
    required this.items,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'Paid';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(context.wp(4)),
          child: Column(
            children: [
              Row(
                children: [
                  // Invoice Icon
                  Container(
                    width: context.wp(12),
                    height: context.wp(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(width: context.wp(3)),

                  // Invoice Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(invoiceNumber, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          customer,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isPaid ? AppColors.success : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(1.5)),

              const Divider(height: 1, color: AppColors.border),

              SizedBox(height: context.hp(1.5)),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Date',
                      value: _formatDate(date),
                    ),
                  ),
                  Expanded(
                    child: _InvoiceInfo(title: 'Items', value: '$items Items'),
                  ),
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Amount',
                      value: '₹${amount.toStringAsFixed(0)}',
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ========================================================
// INVOICE INFO
// ========================================================

class _InvoiceInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InvoiceInfo({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}

// ========================================================
// EMPTY STATE
// ========================================================

class _EmptyInvoiceState extends StatelessWidget {
  const _EmptyInvoiceState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.wp(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.wp(20),
              height: context.wp(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: context.wp(10),
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: context.hp(2)),

            Text('No Invoices Found', style: AppTextStyles.titleLarge),

            SizedBox(height: context.hp(1)),

            Text(
              'There are no invoices available for the selected date range.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
