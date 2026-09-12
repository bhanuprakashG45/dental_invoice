import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';
import 'package:invoice/data/models/home/invoice/create_invoice_model.dart';
import 'package:invoice/data/models/home/invoice/invoice_history_response_model.dart';
import 'package:invoice/provider/home/invoice/invoice_provider.dart';
import 'package:provider/provider.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoiceHistory();
    });
  }

  Future<void> _loadInvoiceHistory() async {
    final provider = context.read<InvoiceProvider>();

    final success = await provider.getInvoiceHistory(page: 1, limit: 10);

    if (!mounted) return;

    if (!success) {
      await provider.loadInvoices();
    }
  }

  Future<void> _refresh() async {
    final provider = context.read<InvoiceProvider>();

    final success = await provider.getInvoiceHistory(page: 1, limit: 10);

    if (!mounted) return;

    if (!success) {
      await provider.loadInvoices();
    }
  }

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

  List<InvoiceHistoryModel> _filterApiInvoices(
    List<InvoiceHistoryModel> invoices,
  ) {
    if (_fromDate == null || _toDate == null) {
      return invoices;
    }

    final start = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);

    final end = DateTime(
      _toDate!.year,
      _toDate!.month,
      _toDate!.day,
      23,
      59,
      59,
      999,
    );

    return invoices.where((invoice) {
      final date = invoice.invoiceDate;

      if (date == null) return false;

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  List<InvoiceModel> _filterLocalInvoices(List<InvoiceModel> invoices) {
    if (_fromDate == null || _toDate == null) {
      return invoices;
    }

    final start = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);

    final end = DateTime(
      _toDate!.year,
      _toDate!.month,
      _toDate!.day,
      23,
      59,
      59,
      999,
    );

    return invoices.where((invoice) {
      final date = DateTime.tryParse(invoice.invoiceDate);

      if (date == null) return false;

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          if (provider.isHistoryLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final isHistoryLoading = provider.isHistoryLoading;

          final apiInvoices = _filterApiInvoices(provider.invoiceHistory);

          final localInvoices = _filterLocalInvoices(provider.invoices);

          final bool usingLocalData =
              provider.historyErrorMessage != null &&
              provider.invoiceHistory.isEmpty;

          final int invoiceCount = usingLocalData
              ? localInvoices.length
              : apiInvoices.length;

          return Column(
            children: [
              // -------------------------------------------------
              // DATE FILTER
              // -------------------------------------------------
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.wp(4),
                  context.hp(2),
                  context.wp(4),
                  context.hp(1),
                ),
                child: Column(
                  children: [
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
                                '${_formatDate(_fromDate)} - '
                                '${_formatDate(_toDate)}',
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

              // -------------------------------------------------
              // RESULT COUNT
              // -------------------------------------------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                child: Row(
                  children: [
                    Text(
                      '$invoiceCount Invoices',
                      style: AppTextStyles.titleMedium,
                    ),
                    const Spacer(),
                    if (usingLocalData)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Offline',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (_fromDate != null)
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

              // -------------------------------------------------
              // API ERROR
              // -------------------------------------------------
              if (provider.historyErrorMessage != null && usingLocalData)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.wp(3)),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: context.wp(2)),
                        Expanded(
                          child: Text(
                            'Unable to connect to server. '
                            'Showing locally saved invoices.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: context.hp(1)),

              // -------------------------------------------------
              // LIST
              // -------------------------------------------------
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child:
                      isHistoryLoading &&
                          provider.invoiceHistory.isEmpty &&
                          provider.invoices.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : usingLocalData
                      ? localInvoices.isEmpty
                            ? const _EmptyInvoiceState()
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  context.wp(4),
                                  0,
                                  context.wp(4),
                                  context.hp(3),
                                ),
                                itemCount: localInvoices.length,
                                separatorBuilder: (_, _) =>
                                    SizedBox(height: context.hp(1.2)),
                                itemBuilder: (context, index) {
                                  final invoice = localInvoices[index];

                                  return _LocalInvoiceHistoryCard(
                                    invoice: invoice,
                                  );
                                },
                              )
                      : apiInvoices.isEmpty
                      ? const _EmptyInvoiceState()
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            context.wp(4),
                            0,
                            context.wp(4),
                            context.hp(3),
                          ),
                          itemCount: apiInvoices.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: context.hp(1.2)),
                          itemBuilder: (context, index) {
                            final invoice = apiInvoices[index];

                            return _InvoiceHistoryCard(invoice: invoice);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// API INVOICE CARD
// ============================================================

class _InvoiceHistoryCard extends StatelessWidget {
  final InvoiceHistoryModel invoice;

  const _InvoiceHistoryCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final status = invoice.paymentStatus.isEmpty
        ? 'Pending'
        : invoice.paymentStatus;

    final isPaid = status.toLowerCase() == 'paid';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Open invoice details / preview
        },
        child: Padding(
          padding: EdgeInsets.all(context.wp(4)),
          child: Column(
            children: [
              Row(
                children: [
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

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNo,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),

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

              Row(
                children: [
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Date',
                      value: _formatDate(invoice.invoiceDate),
                    ),
                  ),
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Items',
                      value: '${invoice.items.length} Items',
                    ),
                  ),
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Amount',
                      value: _formatAmount(invoice.totalAmount),
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

  String _formatDate(DateTime? date) {
    if (date == null) return '--';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

// ============================================================
// LOCAL INVOICE CARD
// ============================================================

class _LocalInvoiceHistoryCard extends StatelessWidget {
  final InvoiceModel invoice;

  const _LocalInvoiceHistoryCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final status = invoice.paymentStatus.isEmpty
        ? 'Pending'
        : invoice.paymentStatus;

    final isPaid = status.toLowerCase() == 'paid';

    final date = DateTime.tryParse(invoice.invoiceDate);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Open invoice details / preview
        },
        child: Padding(
          padding: EdgeInsets.all(context.wp(4)),
          child: Column(
            children: [
              Row(
                children: [
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

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                invoice.invoiceNo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium,
                              ),
                            ),
                            SizedBox(width: context.wp(1.5)),
                            if (!invoice.isSynced)
                              const Icon(
                                Icons.cloud_off_rounded,
                                size: 16,
                                color: Colors.orange,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),

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

              Row(
                children: [
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Date',
                      value: _formatDate(date),
                    ),
                  ),
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Items',
                      value: '${invoice.items.length} Items',
                    ),
                  ),
                  Expanded(
                    child: _InvoiceInfo(
                      title: 'Amount',
                      value: _formatAmount(invoice.totalAmount),
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

  String _formatDate(DateTime? date) {
    if (date == null) return '--';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

// ============================================================
// INVOICE INFO
// ============================================================

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

// ============================================================
// EMPTY STATE
// ============================================================

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
