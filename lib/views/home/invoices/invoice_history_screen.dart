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

  bool _isOnline = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOnlineInvoices();
    });
  }

  // ===========================================================================
  // ONLINE
  // ===========================================================================

  Future<void> _loadOnlineInvoices() async {
    final provider = context.read<InvoiceProvider>();

    await provider.getInvoiceHistory(page: 1, limit: 10);
  }

  Future<void> _refreshOnline() async {
    await _loadOnlineInvoices();
  }

  // ===========================================================================
  // OFFLINE
  // ===========================================================================

  Future<void> _loadOfflineInvoices() async {
    final provider = context.read<InvoiceProvider>();

    await provider.loadInvoices();
  }

  Future<void> _refreshOffline() async {
    await _loadOfflineInvoices();
  }

  // ===========================================================================
  // TAB CHANGE
  // ===========================================================================

  Future<void> _changeTab(bool online) async {
    if (_isOnline == online) {
      return;
    }

    setState(() {
      _isOnline = online;
    });

    if (online) {
      await _loadOnlineInvoices();
    } else {
      await _loadOfflineInvoices();
    }
  }

  // ===========================================================================
  // DATE FILTER
  // ===========================================================================

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

    if (picked == null) {
      return;
    }

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

  // ===========================================================================
  // FILTER API
  // ===========================================================================

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

      if (date == null) {
        return false;
      }

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  // ===========================================================================
  // FILTER LOCAL
  // ===========================================================================

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

      if (date == null) {
        return false;
      }

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  // ===========================================================================
  // SYNC ALL
  // ===========================================================================

  Future<void> _syncAllInvoices() async {
    final provider = context.read<InvoiceProvider>();

    final result = await provider.syncPendingInvoices();

    if (!mounted) return;

    await provider.loadInvoices();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF101D43);
    const pageBackground = Color(0xFFF5F8FD);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Invoice History',
          style: AppTextStyles.titleLarge.copyWith(
            color: navy,
            fontWeight: FontWeight.w800,
            fontSize: context.sp(20),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: context.wp(4)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: navy),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4FF), pageBackground, Color(0xFFF8FAFE)],
            stops: [0, 0.25, 1],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Consumer<InvoiceProvider>(
            builder: (context, provider, child) {
              final apiInvoices = _filterApiInvoices(provider.invoiceHistory);
              final localInvoices = _filterLocalInvoices(provider.invoices);
              final isLoading = _isOnline
                  ? provider.isHistoryLoading
                  : provider.isLoading;
              final invoicesCount = _isOnline
                  ? apiInvoices.length
                  : localInvoices.length;
              final totalAmount = _isOnline
                  ? apiInvoices.fold<double>(
                      0,
                      (sum, invoice) => sum + invoice.totalAmount,
                    )
                  : localInvoices.fold<double>(
                      0,
                      (sum, invoice) => sum + invoice.totalAmount,
                    );

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.wp(4),
                      context.hp(1),
                      context.wp(4),
                      0,
                    ),
                    child: _HistoryTabs(
                      isOnline: _isOnline,
                      onChanged: _changeTab,
                    ),
                  ),
                  SizedBox(height: context.hp(1.5)),
                  if (_isOnline)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                      child: _OnlineHeader(
                        fromDate: _fromDate,
                        toDate: _toDate,
                        onFilterTap: _selectDateRange,
                        onClear: _clearFilter,
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Offline Invoices',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: navy,
                                    fontWeight: FontWeight.w800,
                                    fontSize: context.sp(16),
                                  ),
                                ),
                              ),
                              Text(
                                '$invoicesCount invoices',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFFB77908),
                                  fontWeight: FontWeight.w700,
                                  fontSize: context.sp(10),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.hp(1)),
                          SizedBox(
                            width: double.infinity,
                            height: context.hp(5.5),
                            child: ElevatedButton.icon(
                              onPressed:
                                  provider.isSyncing || localInvoices.isEmpty
                                  ? null
                                  : _syncAllInvoices,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: const Color(
                                  0xFFE2E8F0,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: provider.isSyncing
                                  ? SizedBox(
                                      width: context.wp(4),
                                      height: context.wp(4),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload_rounded),
                              label: Text(
                                provider.isSyncing
                                    ? 'Syncing invoices…'
                                    : 'Sync all pending invoices',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: context.sp(11),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: context.hp(1.6)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HistorySummaryCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'Total Invoices',
                            value: '$invoicesCount',
                          ),
                        ),
                        SizedBox(width: context.wp(2.5)),
                        Expanded(
                          child: _HistorySummaryCard(
                            icon: Icons.bar_chart_rounded,
                            label: 'Total Amount',
                            value: _formatHistoryAmount(totalAmount),
                            amount: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.hp(2)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$invoicesCount Invoices',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: context.sp(18),
                            ),
                          ),
                        ),
                        if (_fromDate != null && _toDate != null)
                          TextButton.icon(
                            onPressed: _clearFilter,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Clear filter'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.hp(0.8)),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _isOnline ? _refreshOnline : _refreshOffline,
                      child:
                          isLoading &&
                              (_isOnline
                                  ? provider.invoiceHistory.isEmpty
                                  : provider.invoices.isEmpty)
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: context.hp(30),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            )
                          : _isOnline
                          ? apiInvoices.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.wp(4),
                                    ),
                                    children: [
                                      SizedBox(
                                        height: context.hp(28),
                                        child: const _EmptyInvoiceState(
                                          message: 'No online invoices found.',
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(
                                      context.wp(4),
                                      0,
                                      context.wp(4),
                                      context.hp(3),
                                    ),
                                    itemCount: apiInvoices.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: context.hp(1.2)),
                                    itemBuilder: (context, index) =>
                                        _InvoiceHistoryCard(
                                          invoice: apiInvoices[index],
                                        ),
                                  )
                          : localInvoices.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.wp(4),
                              ),
                              children: [
                                SizedBox(
                                  height: context.hp(28),
                                  child: const _EmptyInvoiceState(
                                    message: 'No offline invoices found.',
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                context.wp(4),
                                0,
                                context.wp(4),
                                context.hp(3),
                              ),
                              itemCount: localInvoices.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: context.hp(1.2)),
                              itemBuilder: (context, index) =>
                                  _LocalInvoiceHistoryCard(
                                    invoice: localInvoices[index],
                                  ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatHistoryAmount(double amount) {
    final rounded = amount.toStringAsFixed(0);
    final digits = rounded.split('');
    final reversed = digits.reversed.toList();
    final formatted = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i == 3 || (i > 3 && (i - 1) % 2 == 0)) {
        formatted.write(',');
      }
      formatted.write(reversed[i]);
    }
    return '₹${formatted.toString().split('').reversed.join()}';
  }
}

// ============================================================================
// ONLINE / OFFLINE TABS
// ============================================================================

// ============================================================================
// ONLINE / OFFLINE TABS
// ============================================================================

class _HistorySummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool amount;

  const _HistorySummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.amount = false,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF101D43);
    return Container(
      constraints: BoxConstraints(minHeight: context.hp(12)),
      padding: EdgeInsets.all(context.wp(3)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F4FA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B2550),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: context.wp(11),
            height: context.wp(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary, size: context.sp(21)),
          ),
          SizedBox(width: context.wp(2.5)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF6F7B91),
                    fontSize: context.sp(9.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.hp(0.4)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: amount ? AppColors.primary : navy,
                      fontSize: context.sp(amount ? 15 : 19),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTabs extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onChanged;

  const _HistoryTabs({required this.isOnline, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.wp(1)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: _TabItem(
              title: 'Online',
              icon: Icons.cloud_done_rounded,
              selected: isOnline,
              onTap: () => onChanged(true),
            ),
          ),
          SizedBox(width: context.wp(1)),
          Expanded(
            child: _TabItem(
              title: 'Offline',
              icon: Icons.cloud_off_rounded,
              selected: !isOnline,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4),
            vertical: context.hp(1.15),
          ),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: context.sp(16),
                color: selected
                    ? Colors.white
                    : Colors.black.withValues(alpha: 0.88),
              ),
              SizedBox(width: context.wp(2)),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? Colors.white
                      : Colors.black.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w800,
                  fontSize: context.sp(11.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ============================================================================
// ONLINE HEADER
// ============================================================================

class _OnlineHeader extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFilterTap;
  final VoidCallback onClear;

  const _OnlineHeader({
    required this.fromDate,
    required this.toDate,
    required this.onFilterTap,
    required this.onClear,
  });

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '--';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = fromDate != null && toDate != null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: context.hp(6),
          child: OutlinedButton.icon(
            onPressed: onFilterTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.78),
              // side: const BorderSide(color: Color(0xFFD7E6F8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              hasFilter ? 'Change Date Range' : 'Filter by Date',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: context.sp(10.5),
              ),
            ),
          ),
        ),

        if (hasFilter) ...[
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
                    '${_formatDate(fromDate)} - ${_formatDate(toDate)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: context.sp(10.5),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClear,
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
    );
  }
}

// ============================================================================
// API INVOICE CARD
// ============================================================================

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
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x120B2550),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFF0F4FA)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(context.wp(3.5)),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.hp(0.4)),
                        Text(
                          invoice.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                            fontSize: context.sp(10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.wp(2.5),
                      vertical: context.hp(0.6),
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
                        fontSize: context.sp(9),
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
    if (date == null) {
      return '--';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

// ============================================================================
// LOCAL INVOICE CARD
// ============================================================================

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
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x120B2550),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFF0F4FA)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(context.wp(3.5)),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: context.wp(12),
                    height: context.wp(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.orange,
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
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontSize: context.sp(13),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: context.wp(1.5)),
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 15,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        SizedBox(height: context.hp(0.4)),
                        Text(
                          invoice.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                            fontSize: context.sp(10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.wp(2.5),
                      vertical: context.hp(0.6),
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
                        fontSize: context.sp(9),
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
                    Icons.cloud_off_rounded,
                    size: 17,
                    color: Colors.orange,
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
    if (date == null) {
      return '--';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

// ============================================================================
// INVOICE INFO
// ============================================================================

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
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey500,
            fontSize: context.sp(9),
          ),
        ),
        SizedBox(height: context.hp(0.4)),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.black,
            fontSize: context.sp(10),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyInvoiceState extends StatelessWidget {
  final String message;

  const _EmptyInvoiceState({required this.message});

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
            Text(
              'No Invoices Found',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: context.sp(16),
              ),
            ),
            SizedBox(height: context.hp(1)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
                fontSize: context.sp(10.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
