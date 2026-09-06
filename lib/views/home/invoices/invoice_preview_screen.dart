import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _money(dynamic value) {
    final amount = value is num ? value.toDouble() : 0.0;
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final items =
        (invoice['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final date = invoice['date'] is DateTime
        ? invoice['date'] as DateTime
        : DateTime.now();

    final subtotal = _number(invoice['subtotal']);
    final sgst = _number(invoice['sgst']);
    final cgst = _number(invoice['cgst']);
    final roundOff = _number(invoice['roundOff']);
    final total = _number(invoice['total']);

    final paymentStatus = _safeString(invoice['paymentStatus']).isEmpty
        ? 'Pending'
        : _safeString(invoice['paymentStatus']);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: context.wp(4),
        title: Text(
          'Invoice Preview',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF16181D),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.wp(4),
            context.hp(2),
            context.wp(4),
            context.hp(4),
          ),
          child: Column(
            children: [
              // =================================================================
              // INVOICE PAPER
              // =================================================================
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      // =========================================================
                      // TOP ACCENT
                      // =========================================================
                      Container(
                        height: 5,
                        width: double.infinity,
                        color: AppColors.primary,
                      ),

                      // =========================================================
                      // BUSINESS HEADER
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.all(context.wp(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBusinessLogo(context),

                            SizedBox(width: context.wp(3.5)),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _safeString(invoice['sellerName']).isEmpty
                                        ? 'Business Name'
                                        : _safeString(invoice['sellerName']),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),

                                  if (_safeString(
                                    invoice['sellerAddress'],
                                  ).isNotEmpty) ...[
                                    SizedBox(height: context.hp(0.7)),
                                    Text(
                                      _safeString(invoice['sellerAddress']),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF667085),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],

                                  if (_safeString(
                                    invoice['sellerPhone'],
                                  ).isNotEmpty) ...[
                                    SizedBox(height: context.hp(0.5)),
                                    _contactRow(
                                      Icons.phone_outlined,
                                      _safeString(invoice['sellerPhone']),
                                    ),
                                  ],

                                  if (_safeString(
                                    invoice['sellerEmail'],
                                  ).isNotEmpty) ...[
                                    SizedBox(height: context.hp(0.4)),
                                    _contactRow(
                                      Icons.email_outlined,
                                      _safeString(invoice['sellerEmail']),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      _sectionDivider(),

                      // =========================================================
                      // INVOICE TITLE
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.all(context.wp(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TAX INVOICE',
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF16181D),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: context.hp(0.5)),
                                  Text(
                                    'Original for recipient',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: const Color(0xFF98A2B3),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: context.wp(3)),

                            _buildInvoiceMeta(
                              context,
                              invoiceNumber: _safeString(
                                invoice['invoiceNumber'],
                              ),
                              date: _formatDate(date),
                              financialYear: _safeString(
                                invoice['financialYear'],
                              ),
                            ),
                          ],
                        ),
                      ),

                      _sectionDivider(),

                      // =========================================================
                      // SELLER / GST DETAILS
                      // =========================================================
                      if (_hasBusinessDetails()) ...[
                        Padding(
                          padding: EdgeInsets.all(context.wp(5)),
                          child: _buildDetailsCard(
                            context,
                            title: 'Invoice Details',
                            icon: Icons.receipt_long_outlined,
                            children: [
                              if (_safeString(
                                invoice['sellerGstin'],
                              ).isNotEmpty)
                                _detailItem(
                                  'GSTIN',
                                  _safeString(invoice['sellerGstin']),
                                ),
                              if (_safeString(
                                invoice['sellerLicense'],
                              ).isNotEmpty)
                                _detailItem(
                                  'DL No.',
                                  _safeString(invoice['sellerLicense']),
                                ),
                              if (_safeString(
                                invoice['dispatchedThrough'],
                              ).isNotEmpty)
                                _detailItem(
                                  'Dispatched Through',
                                  _safeString(invoice['dispatchedThrough']),
                                ),
                              if (_safeString(invoice['reference']).isNotEmpty)
                                _detailItem(
                                  'Reference',
                                  _safeString(invoice['reference']),
                                ),
                              if (_safeString(
                                invoice['salesPerson'],
                              ).isNotEmpty)
                                _detailItem(
                                  'Salesperson',
                                  _safeString(invoice['salesPerson']),
                                ),
                            ],
                          ),
                        ),

                        _sectionDivider(),
                      ],

                      // =========================================================
                      // BILL TO
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.all(context.wp(5)),
                        child: _buildCustomerCard(context),
                      ),

                      _sectionDivider(),

                      // =========================================================
                      // ITEMS
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.all(context.wp(5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              context,
                              icon: Icons.shopping_bag_outlined,
                              title: 'Items & Services',
                              subtitle:
                                  '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                            ),

                            SizedBox(height: context.hp(1.8)),

                            _buildItemsTable(context, items),
                          ],
                        ),
                      ),

                      _sectionDivider(),

                      // =========================================================
                      // TOTALS + BANK
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.all(context.wp(5)),
                        child: Column(
                          children: [
                            _buildTotalsSection(
                              context,
                              subtotal: subtotal,
                              sgst: sgst,
                              cgst: cgst,
                              roundOff: roundOff,
                              total: total,
                            ),

                            if (_hasBankDetails()) ...[
                              SizedBox(height: context.hp(2.5)),
                              _buildBankDetails(context),
                            ],
                          ],
                        ),
                      ),

                      _sectionDivider(),

                      // =========================================================
                      // PAYMENT STATUS
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.all(context.wp(5)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Status',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: const Color(0xFF98A2B3),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: context.hp(0.5)),
                                  Text(
                                    paymentStatus,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF16181D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildPaymentBadge(context, paymentStatus),
                          ],
                        ),
                      ),

                      _sectionDivider(),

                      // =========================================================
                      // SIGNATURE
                      // =========================================================
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.wp(5),
                          context.hp(3),
                          context.wp(5),
                          context.hp(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  width: context.wp(32),
                                  height: context.hp(5),
                                ),
                                Container(
                                  width: context.wp(36),
                                  height: 1,
                                  color: const Color(0xFF344054),
                                ),
                                SizedBox(height: context.hp(0.7)),
                                Text(
                                  'Authorized Signature',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFF667085),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =================================================================
              // ACTION BUTTONS
              // =================================================================
              SizedBox(height: context.hp(2.5)),

              _buildPrintButton(
                context,
                icon: Icons.print_outlined,
                title: 'Print Invoice',
                onPressed: () {
                  // TODO: Generate PDF and print
                },
              ),

              SizedBox(height: context.hp(1.2)),

              _buildBluetoothButton(
                context,
                onPressed: () {
                  // TODO: Bluetooth printing
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUSINESS LOGO
  // ---------------------------------------------------------------------------

  Widget _buildBusinessLogo(BuildContext context) {
    return Container(
      width: context.wp(18),
      height: context.wp(18),
      padding: EdgeInsets.all(context.wp(2.5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Image.asset(
        'assets/images/app_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.storefront_outlined,
            color: AppColors.primary,
            size: context.wp(8),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INVOICE META
  // ---------------------------------------------------------------------------

  Widget _buildInvoiceMeta(
    BuildContext context, {
    required String invoiceNumber,
    required String date,
    required String financialYear,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: context.wp(34)),
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(3),
        vertical: context.hp(1.3),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Invoice No.',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF98A2B3),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.hp(0.3)),
          Text(
            invoiceNumber.isEmpty ? '-' : invoiceNumber,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF16181D),
            ),
          ),
          SizedBox(height: context.hp(0.8)),
          _metaRow('Date', date),
          if (financialYear.isNotEmpty) _metaRow('FY', financialYear),
        ],
      ),
    );
  }

  Widget _metaRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF98A2B3),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475467),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CUSTOMER
  // ---------------------------------------------------------------------------

  Widget _buildCustomerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, icon: Icons.person_outline, title: 'Bill To'),

          SizedBox(height: context.hp(1.5)),

          Text(
            _safeString(invoice['customerName']).isEmpty
                ? 'Customer'
                : _safeString(invoice['customerName']),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF16181D),
            ),
          ),

          if (_safeString(invoice['customerAddress']).isNotEmpty) ...[
            SizedBox(height: context.hp(0.6)),
            Text(
              _safeString(invoice['customerAddress']),
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
                height: 1.4,
              ),
            ),
          ],

          SizedBox(height: context.hp(1)),

          Wrap(
            spacing: context.wp(4),
            runSpacing: context.hp(0.7),
            children: [
              if (_safeString(invoice['customerPhone']).isNotEmpty)
                _contactRow(
                  Icons.phone_outlined,
                  _safeString(invoice['customerPhone']),
                ),
              if (_safeString(invoice['customerEmail']).isNotEmpty)
                _contactRow(
                  Icons.email_outlined,
                  _safeString(invoice['customerEmail']),
                ),
              if (_safeString(invoice['customerGstin']).isNotEmpty)
                _contactRow(
                  Icons.receipt_long_outlined,
                  'GSTIN: ${invoice['customerGstin']}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DETAILS CARD
  // ---------------------------------------------------------------------------

  Widget _buildDetailsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, icon: icon, title: title),
          SizedBox(height: context.hp(1.2)),
          ...children,
        ],
      ),
    );
  }

  Widget _detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF344054),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ITEMS TABLE
  // ---------------------------------------------------------------------------

  Widget _buildItemsTable(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    const tableWidth = 760.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                _buildTableHeader(),

                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      'No items added',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    items.length,
                    (index) => _buildTableRow(index, items[index]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      color: const Color(0xFFF2F4F7),
      child: Row(
        children: [
          _headerCell('S.No', width: 45),
          _headerCell('Product / Service', flex: 4),
          _headerCell('HSN Code', width: 80),
          _headerCell('GST %', width: 65, alignment: Alignment.center),
          _headerCell('Qty', width: 60, alignment: Alignment.center),
          _headerCell('Rate', width: 105, alignment: Alignment.centerRight),
          _headerCell('Amount', width: 115, alignment: Alignment.centerRight),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text, {
    double? width,
    int? flex,
    Alignment alignment = Alignment.centerLeft,
  }) {
    Widget child = Align(
      alignment: alignment,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF344054),
        ),
      ),
    );

    if (flex != null) {
      return Expanded(flex: flex, child: child);
    }

    return SizedBox(width: width, child: child);
  }

  Widget _buildTableRow(int index, Map<String, dynamic> item) {
    final quantity = _number(item['quantity']);
    final rate = _number(item['price']);
    final gst = _number(item['gstPercent']);
    final amount = _number(item['amount']);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 45,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Text(
              _safeString(item['name']).isEmpty
                  ? '-'
                  : _safeString(item['name']),
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF16181D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(
            width: 80,
            child: Text(
              _safeString(item['hsnCode']).isEmpty
                  ? '-'
                  : _safeString(item['hsnCode']),
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
          ),

          SizedBox(
            width: 65,
            child: Text(
              '${gst.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
          ),

          SizedBox(
            width: 60,
            child: Text(
              quantity % 1 == 0
                  ? quantity.toStringAsFixed(0)
                  : quantity.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF344054),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(
            width: 105,
            child: Text(
              _money(rate),
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF475467),
              ),
            ),
          ),

          SizedBox(
            width: 115,
            child: Text(
              _money(amount),
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF16181D),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOTALS
  // ---------------------------------------------------------------------------

  Widget _buildTotalsSection(
    BuildContext context, {
    required double subtotal,
    required double sgst,
    required double cgst,
    required double roundOff,
    required double total,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          _amountRow('Sub Total', _money(subtotal)),
          _amountRow('SGST', _money(sgst)),
          _amountRow('CGST', _money(cgst)),
          _amountRow('Round Off', _money(roundOff)),

          SizedBox(height: context.hp(1)),

          const Divider(height: 1, color: Color(0xFFD0D5DD)),

          SizedBox(height: context.hp(1.2)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF16181D),
                ),
              ),
              Text(
                _money(total),
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: isTotal
                  ? const Color(0xFF16181D)
                  : const Color(0xFF667085),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF344054),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BANK DETAILS
  // ---------------------------------------------------------------------------

  Widget _buildBankDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.wp(12),
            height: context.wp(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_outlined,
              color: AppColors.primary,
              size: context.wp(6),
            ),
          ),

          SizedBox(width: context.wp(3)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Details',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16181D),
                  ),
                ),

                SizedBox(height: context.hp(1)),

                if (_safeString(invoice['bankName']).isNotEmpty)
                  _bankRow('Bank', _safeString(invoice['bankName'])),

                if (_safeString(invoice['accountNumber']).isNotEmpty)
                  _bankRow('A/C No.', _safeString(invoice['accountNumber'])),

                if (_safeString(invoice['ifsc']).isNotEmpty)
                  _bankRow('IFSC', _safeString(invoice['ifsc'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF98A2B3),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF344054),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT BADGE
  // ---------------------------------------------------------------------------

  Widget _buildPaymentBadge(BuildContext context, String status) {
    final isPaid = status.toLowerCase() == 'paid';

    final backgroundColor = isPaid
        ? AppColors.success.withValues(alpha: 0.10)
        : Colors.orange.withValues(alpha: 0.10);

    final foregroundColor = isPaid ? AppColors.success : Colors.orange.shade800;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(3),
        vertical: context.hp(0.9),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: context.wp(4),
            color: foregroundColor,
          ),
          SizedBox(width: context.wp(1.5)),
          Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRINT BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildPrintButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: context.hp(6.5),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: context.wp(5)),
        label: Text(
          title,
          style: AppTextStyles.button.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BLUETOOTH BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildBluetoothButton(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: context.hp(6.5),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(Icons.bluetooth_outlined, size: context.wp(5)),
        label: Text(
          'Print via Bluetooth',
          style: AppTextStyles.button.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: context.wp(9),
          height: context.wp(9),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: context.wp(4.5), color: AppColors.primary),
        ),

        SizedBox(width: context.wp(2.5)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16181D),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF98A2B3),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CONTACT ROW
  // ---------------------------------------------------------------------------

  Widget _contactRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF98A2B3)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF667085),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DIVIDER
  // ---------------------------------------------------------------------------

  Widget _sectionDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE4E7EC));
  }

  // ---------------------------------------------------------------------------
  // CONDITIONS
  // ---------------------------------------------------------------------------

  bool _hasBusinessDetails() {
    return _safeString(invoice['sellerGstin']).isNotEmpty ||
        _safeString(invoice['sellerLicense']).isNotEmpty ||
        _safeString(invoice['dispatchedThrough']).isNotEmpty ||
        _safeString(invoice['reference']).isNotEmpty ||
        _safeString(invoice['salesPerson']).isNotEmpty;
  }

  bool _hasBankDetails() {
    return _safeString(invoice['bankName']).isNotEmpty ||
        _safeString(invoice['accountNumber']).isNotEmpty ||
        _safeString(invoice['ifsc']).isNotEmpty;
  }
}
