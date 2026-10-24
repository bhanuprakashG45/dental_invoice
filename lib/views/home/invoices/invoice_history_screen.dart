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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleSpacing: context.wp(4),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: AppColors.card),
        ),
        title: Text(
          'Invoice History',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.card,
            fontWeight: FontWeight.w600,
            fontSize: context.sp(20),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4F8CFF),
              Color(0xFF8FB7FF),
              Color(0xFFEAF2FF),
              Color(0xFFF7F8FC),
            ],
            stops: [0.0, 0.18, 0.42, 0.75],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Consumer<InvoiceProvider>(
            builder: (context, provider, child) {
              final apiInvoices = _filterApiInvoices(provider.invoiceHistory);

              final localInvoices = _filterLocalInvoices(provider.invoices);

              final bool isLoading = _isOnline
                  ? provider.isHistoryLoading
                  : provider.isLoading;

              final invoicesCount = _isOnline
                  ? apiInvoices.length
                  : localInvoices.length;

              return Column(
                children: [
                  SizedBox(height: context.hp(1)),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                    child: _HistoryTabs(
                      isOnline: _isOnline,
                      onChanged: _changeTab,
                    ),
                  ),

                  SizedBox(height: context.hp(1.8)),

                  // ==========================================================
                  // CONTENT
                  // ==========================================================
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          // ==================================================
                          // ONLINE CONTENT
                          // ==================================================
                          if (_isOnline)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                context.wp(4),
                                context.hp(2),
                                context.wp(4),
                                context.hp(1),
                              ),
                              child: _OnlineHeader(
                                fromDate: _fromDate,
                                toDate: _toDate,
                                onFilterTap: _selectDateRange,
                                onClear: _clearFilter,
                              ),
                            ),

                          // ==================================================
                          // OFFLINE CONTENT
                          // ==================================================
                          if (!_isOnline)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                context.wp(4),
                                context.hp(2),
                                context.wp(4),
                                context.hp(1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Offline Invoices',
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                fontSize: context.sp(16),
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '$invoicesCount Invoices',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w700,
                                          fontSize: context.sp(10),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: context.hp(1.2)),

                                  SizedBox(
                                    width: double.infinity,
                                    height: context.hp(6),
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          provider.isSyncing ||
                                              localInvoices.isEmpty
                                          ? null
                                          : _syncAllInvoices,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        disabledBackgroundColor:
                                            AppColors.grey300,
                                        foregroundColor: Colors.white,
                                        disabledForegroundColor:
                                            Colors.grey.shade600,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon: provider.isSyncing
                                          ? SizedBox(
                                              width: context.wp(4.5),
                                              height: context.wp(4.5),
                                              child:
                                                  const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.cloud_upload_rounded,
                                            ),
                                      label: Text(
                                        provider.isSyncing
                                            ? 'Syncing Invoices...'
                                            : 'Sync All',
                                        style: AppTextStyles.labelLarge
                                            .copyWith(
                                              color:
                                                  provider.isSyncing ||
                                                      localInvoices.isEmpty
                                                  ? Colors.grey.shade600
                                                  : Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: context.sp(11),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ==================================================
                          // COUNT
                          // ==================================================
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.wp(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$invoicesCount Invoices',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: context.sp(14),
                                  ),
                                ),
                                const Spacer(),
                                if (_fromDate != null && _toDate != null)
                                  Text(
                                    'Filtered',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: context.sp(10),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: context.hp(1)),

                          // ==================================================
                          // LIST
                          // ==================================================
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _isOnline
                                  ? _refreshOnline
                                  : _refreshOffline,
                              child:
                                  isLoading &&
                                      (_isOnline
                                          ? provider.invoiceHistory.isEmpty
                                          : provider.invoices.isEmpty)
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: context.hp(35),
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
                                            children: [
                                              SizedBox(
                                                height: context.hp(35),
                                                child: const _EmptyInvoiceState(
                                                  message:
                                                      'No online invoices found.',
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
                                            separatorBuilder: (_, _) =>
                                                SizedBox(
                                                  height: context.hp(1.2),
                                                ),
                                            itemBuilder: (context, index) {
                                              return _InvoiceHistoryCard(
                                                invoice: apiInvoices[index],
                                              );
                                            },
                                          )
                                  : localInvoices.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: context.hp(35),
                                          child: const _EmptyInvoiceState(
                                            message:
                                                'No offline invoices found.',
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
                                      itemCount: localInvoices.length,
                                      separatorBuilder: (_, _) =>
                                          SizedBox(height: context.hp(1.2)),
                                      itemBuilder: (context, index) {
                                        return _LocalInvoiceHistoryCard(
                                          invoice: localInvoices[index],
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
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
}

// ============================================================================
// ONLINE / OFFLINE TABS
// ============================================================================

// ============================================================================
// ONLINE / OFFLINE TABS
// ============================================================================

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
            color: selected ? Colors.black : Colors.transparent,
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
                    : Colors.white.withValues(alpha: 0.88),
              ),
              SizedBox(width: context.wp(2)),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.92),
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
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
