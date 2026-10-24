import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';
import 'package:invoice/data/models/home/invoice/create_invoice_model.dart';
import 'package:invoice/provider/home/invoice/invoice_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  // ===========================================================================
  // PRINT FLOW
  // ===========================================================================

  Future<void> _printInvoice() async {
    final provider = context.read<InvoiceProvider>();

    if (provider.isLoading) {
      return;
    }

    final invoiceModel = InvoiceModel.fromPreviewMap(widget.invoice);

    final savedInvoice = await provider.createInvoice(invoiceModel);

    if (!mounted) {
      return;
    }

    if (savedInvoice == null) {
      _showSnackBar(
        'Invoice saved locally, but server sync failed.',
        isError: true,
      );

      return;
    }

    _showSnackBar('Invoice created successfully.', isError: false);

    await _generateAndPrintInvoice(savedInvoice);
  }

  // ===========================================================================
  // PDF GENERATION + SYSTEM PRINT
  // ===========================================================================

  Future<Uint8List> _generateInvoicePdf(InvoiceModel invoice) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    );

    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Bold.ttf'),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return _buildPdfContent(invoice);
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _generateAndPrintInvoice(InvoiceModel invoice) async {
    try {
      final pdfBytes = await _generateInvoicePdf(invoice);

      if (!mounted) {
        return;
      }

      await Printing.layoutPdf(
        name: 'Invoice-${invoice.invoiceNo}',
        format: PdfPageFormat.a4,
        onLayout: (format) async {
          return pdfBytes;
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        'Unable to print invoice. Please try again.',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // PDF CONTENT
  // ===========================================================================

  List<pw.Widget> _buildPdfContent(InvoiceModel invoice) {
    return [
      // -----------------------------------------------------------------------
      // BUSINESS HEADER
      // -----------------------------------------------------------------------
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.companyName.isEmpty
                      ? 'Business Name'
                      : invoice.companyName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                if (invoice.companyAddress.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 5),
                    child: pw.Text(
                      invoice.companyAddress,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),

                if (invoice.companyPhone.isNotEmpty ||
                    invoice.companyEmail.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Text(
                      [
                        if (invoice.companyPhone.isNotEmpty)
                          invoice.companyPhone,
                        if (invoice.companyEmail.isNotEmpty)
                          invoice.companyEmail,
                      ].join('  |  '),
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 5),

                pw.Text(
                  'Invoice No: ${invoice.invoiceNo}',
                  style: const pw.TextStyle(fontSize: 9),
                ),

                pw.Text(
                  'Date: ${_formatInvoiceDate(invoice.invoiceDate)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),

                if (invoice.financialYear.isNotEmpty)
                  pw.Text(
                    'FY: ${invoice.financialYear}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 18),

      pw.Divider(color: PdfColors.grey300),

      pw.SizedBox(height: 12),

      // -----------------------------------------------------------------------
      // SELLER DETAILS
      // -----------------------------------------------------------------------
      pw.Text(
        'Seller Details',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),

      pw.SizedBox(height: 7),

      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              invoice.companyName,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),

            if (invoice.companyAddress.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  invoice.companyAddress,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

            if (invoice.companyGstin.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'GSTIN: ${invoice.companyGstin}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

            if (invoice.companyDlNo.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3),
                child: pw.Text(
                  'DL No.: ${invoice.companyDlNo}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
          ],
        ),
      ),

      pw.SizedBox(height: 14),

      // -----------------------------------------------------------------------
      // BILL TO
      // -----------------------------------------------------------------------
      pw.Text(
        'Bill To',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),

      pw.SizedBox(height: 7),

      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              invoice.customerName,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),

            if (invoice.customerAddress.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  invoice.customerAddress,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

            if (invoice.customerPhone.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3),
                child: pw.Text(
                  'Phone: ${invoice.customerPhone}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

            if (invoice.customerEmail.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3),
                child: pw.Text(
                  'Email: ${invoice.customerEmail}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

            if (invoice.customerGstin.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3),
                child: pw.Text(
                  'GSTIN: ${invoice.customerGstin}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
          ],
        ),
      ),

      pw.SizedBox(height: 18),

      // -----------------------------------------------------------------------
      // INVOICE DETAILS
      // -----------------------------------------------------------------------
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        columnWidths: const {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            children: [
              _pdfHeaderCell('Dispatched Through'),
              _pdfHeaderCell('Reference'),
              _pdfHeaderCell('Salesperson'),
              _pdfHeaderCell('Payment Status'),
            ],
          ),

          pw.TableRow(
            children: [
              _pdfValueCell(invoice.dispatchedThrough),
              _pdfValueCell(invoice.reference),
              _pdfValueCell(invoice.salesperson),
              _pdfValueCell(invoice.paymentStatus.toUpperCase()),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 18),

      // -----------------------------------------------------------------------
      // ITEMS
      // -----------------------------------------------------------------------
      pw.Text(
        'Items & Services',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),

      pw.SizedBox(height: 7),

      pw.TableHelper.fromTextArray(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        headers: const [
          'S.No',
          'Product / Service',
          'HSN',
          'GST',
          'Qty',
          'Rate',
          'Amount',
        ],
        data: List.generate(invoice.items.length, (index) {
          final item = invoice.items[index];

          return [
            '${index + 1}',
            item.service,
            item.hsnCode,
            '${_number(item.gst).toStringAsFixed(0)}%',
            _quantity(item.quantity),
            _money(item.rate),
            _money(item.amount),
          ];
        }),
      ),

      pw.SizedBox(height: 18),

      // -----------------------------------------------------------------------
      // TOTALS
      // -----------------------------------------------------------------------
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: pw.Container()),

          pw.SizedBox(width: 20),

          pw.SizedBox(
            width: 230,
            child: pw.Column(
              children: [
                _pdfAmountRow('Sub Total', _money(invoice.subtotal)),

                _pdfAmountRow('SGST', _money(invoice.sgst)),

                _pdfAmountRow('CGST', _money(invoice.cgst)),

                _pdfAmountRow('Round Off', _money(invoice.roundOff)),

                pw.Divider(color: PdfColors.grey400),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 7),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Grand Total',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.Text(
                        _money(invoice.totalAmount),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      // BANK DETAILS
      // -----------------------------------------------------------------------
      if (_hasBankDetailsForModel(invoice)) ...[
        pw.SizedBox(height: 18),

        pw.Text(
          'Bank Details',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 7),

        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (invoice.bankName.isNotEmpty)
                pw.Text(
                  'Bank: ${invoice.bankName}',
                  style: const pw.TextStyle(fontSize: 9),
                ),

              if (invoice.accountNumber.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3),
                  child: pw.Text(
                    'A/C No.: ${invoice.accountNumber}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),

              if (invoice.ifscCode.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3),
                  child: pw.Text(
                    'IFSC: ${invoice.ifscCode}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
            ],
          ),
        ),
      ],

      pw.SizedBox(height: 35),

      // -----------------------------------------------------------------------
      // SIGNATURE
      // -----------------------------------------------------------------------
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.SizedBox(
          width: 160,
          child: pw.Column(
            children: [
              pw.SizedBox(height: 35),

              pw.Divider(color: PdfColors.grey800),

              pw.Text(
                'Authorized Signature',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  // ===========================================================================
  // PDF HELPERS
  // ===========================================================================

  pw.Widget _pdfHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pdfValueCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text.isEmpty ? '-' : text,
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  pw.Widget _pdfAmountRow(String title, String amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 9)),

          pw.Text(
            amount,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FORMATTERS
  // ===========================================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatInvoiceDate(String value) {
    if (value.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value);

      return _formatDate(date);
    } catch (_) {
      return value;
    }
  }

  String _money(dynamic value) {
    final amount = _number(value);

    return '₹${amount.toStringAsFixed(2)}';
  }

  String _safeString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  double _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString().replaceAll(',', '').trim() ?? '',
        ) ??
        0;
  }

  String _quantity(dynamic value) {
    final quantity = _number(value);

    if (quantity % 1 == 0) {
      return quantity.toStringAsFixed(0);
    }

    return quantity.toStringAsFixed(2);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final items =
        (widget.invoice['items'] as List?)
            ?.map((item) => Map<String, dynamic>.from(item as Map))
            .toList() ??
        [];

    final date = _getInvoiceDate();

    final subtotal = _number(widget.invoice['subtotal']);

    final sgst = _number(widget.invoice['sgst']);

    final cgst = _number(widget.invoice['cgst']);

    final totalGst = widget.invoice['totalGst'] != null
        ? _number(widget.invoice['totalGst'])
        : sgst + cgst;

    final roundOff = _number(widget.invoice['roundOff']);

    final total = widget.invoice['total'] != null
        ? _number(widget.invoice['total'])
        : subtotal + totalGst + roundOff;

    final paymentStatus = _safeString(widget.invoice['paymentStatus']).isEmpty
        ? 'Pending'
        : _safeString(widget.invoice['paymentStatus']);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      // =========================================================================
      // APP BAR
      // =========================================================================
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
          'Invoice Preview',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.card,
            fontWeight: FontWeight.w600,
            fontSize: context.sp(20),
          ),
        ),
      ),

      // =========================================================================
      // BODY
      // =========================================================================
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
                _buildInvoicePaper(
                  context,
                  items: items,
                  date: date,
                  subtotal: subtotal,
                  sgst: sgst,
                  cgst: cgst,
                  totalGst: totalGst,
                  roundOff: roundOff,
                  total: total,
                  paymentStatus: paymentStatus,
                ),

                SizedBox(height: context.hp(2.5)),

                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _getInvoiceDate() {
    final value = widget.invoice['date'];

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }

    return DateTime.now();
  }

  // ===========================================================================
  // INVOICE PAPER
  // ===========================================================================

  Widget _buildInvoicePaper(
    BuildContext context, {
    required List<Map<String, dynamic>> items,
    required DateTime date,
    required double subtotal,
    required double sgst,
    required double cgst,
    required double totalGst,
    required double roundOff,
    required double total,
    required String paymentStatus,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              height: 5,
              width: double.infinity,
              color: AppColors.primary,
            ),

            _buildBusinessHeader(context),

            _divider(),

            _buildInvoiceHeader(context, date: date),

            _divider(),

            _buildPartyAndInvoiceDetails(context),

            _divider(),

            _buildItemsSection(context, items),

            _divider(),

            _buildTotalsAndBankSection(
              context,
              subtotal: subtotal,
              sgst: sgst,
              cgst: cgst,
              totalGst: totalGst,
              roundOff: roundOff,
              total: total,
            ),

            _divider(),

            _buildPaymentStatus(context, paymentStatus),

            _divider(),

            _buildSignatureSection(context),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BUSINESS HEADER
  // ===========================================================================

  Widget _buildBusinessHeader(BuildContext context) {
    final sellerName = _safeString(widget.invoice['sellerName']);

    final sellerAddress = _safeString(widget.invoice['sellerAddress']);

    final sellerPhone = _safeString(widget.invoice['sellerPhone']);

    final sellerEmail = _safeString(widget.invoice['sellerEmail']);

    return Padding(
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
                  sellerName.isEmpty ? 'Business Name' : sellerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                if (sellerAddress.isNotEmpty) ...[
                  SizedBox(height: context.hp(0.7)),

                  Text(
                    sellerAddress,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF667085),
                      height: 1.45,
                    ),
                  ),
                ],

                if (sellerPhone.isNotEmpty || sellerEmail.isNotEmpty) ...[
                  SizedBox(height: context.hp(1)),

                  Wrap(
                    spacing: context.wp(4),
                    runSpacing: context.hp(0.6),
                    children: [
                      if (sellerPhone.isNotEmpty)
                        _contactRow(Icons.phone_outlined, sellerPhone),

                      if (sellerEmail.isNotEmpty)
                        _contactRow(Icons.email_outlined, sellerEmail),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessLogo(BuildContext context) {
    return Container(
      width: context.wp(18),
      height: context.wp(18),
      padding: EdgeInsets.all(context.wp(2.5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/applogo.PNG',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: context.wp(8),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // INVOICE HEADER
  // ===========================================================================

  Widget _buildInvoiceHeader(BuildContext context, {required DateTime date}) {
    final invoiceNumber = _safeString(widget.invoice['invoiceNumber']);

    final financialYear = _safeString(widget.invoice['financialYear']);

    return Padding(
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
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),

                SizedBox(height: context.hp(0.4)),

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

          Flexible(
            child: _buildInvoiceMeta(
              context,
              invoiceNumber: invoiceNumber,
              date: _formatDate(date),
              financialYear: financialYear,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceMeta(
    BuildContext context, {
    required String invoiceNumber,
    required String date,
    required String financialYear,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(3),
        vertical: context.hp(1.2),
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
            'INVOICE NO.',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF98A2B3),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),

          SizedBox(height: context.hp(0.3)),

          Text(
            invoiceNumber.isEmpty ? '-' : invoiceNumber,
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w900,
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

          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF475467),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PARTY DETAILS
  // ===========================================================================

  Widget _buildPartyAndInvoiceDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.wp(5)),
      child: Column(
        children: [
          _buildBillToCard(context),

          if (_hasBusinessDetails()) ...[
            SizedBox(height: context.hp(1.5)),
            _buildInvoiceDetailsCard(context),
          ],
        ],
      ),
    );
  }

  Widget _buildBillToCard(BuildContext context) {
    final name = _safeString(widget.invoice['customerName']);

    final address = _safeString(widget.invoice['customerAddress']);

    final phone = _safeString(widget.invoice['customerPhone']);

    final email = _safeString(widget.invoice['customerEmail']);

    final gstin = _safeString(widget.invoice['customerGstin']);

    return _outlinedSection(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, icon: Icons.person_outline, title: 'Bill To'),

          SizedBox(height: context.hp(1.3)),

          Text(
            name.isEmpty ? 'Customer' : name,
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w800,
            ),
          ),

          if (address.isNotEmpty) ...[
            SizedBox(height: context.hp(0.5)),

            Text(
              address,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
                height: 1.4,
              ),
            ),
          ],

          if (phone.isNotEmpty || email.isNotEmpty || gstin.isNotEmpty) ...[
            SizedBox(height: context.hp(1)),

            Wrap(
              spacing: context.wp(4),
              runSpacing: context.hp(0.7),
              children: [
                if (phone.isNotEmpty) _contactRow(Icons.phone_outlined, phone),

                if (email.isNotEmpty) _contactRow(Icons.email_outlined, email),

                if (gstin.isNotEmpty)
                  _contactRow(Icons.receipt_long_outlined, 'GSTIN: $gstin'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsCard(BuildContext context) {
    return _outlinedSection(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Invoice Details',
          ),

          SizedBox(height: context.hp(1.1)),

          _detailItem(
            'GSTIN',
            _safeString(widget.invoice['sellerGstin']),
            hideIfEmpty: true,
          ),

          _detailItem(
            'DL No.',
            _safeString(widget.invoice['sellerLicense']),
            hideIfEmpty: true,
          ),

          _detailItem(
            'Dispatched Through',
            _safeString(widget.invoice['dispatchedThrough']),
            hideIfEmpty: true,
          ),

          _detailItem(
            'Reference',
            _safeString(widget.invoice['reference']),
            hideIfEmpty: true,
          ),

          _detailItem(
            'Salesperson',
            _safeString(widget.invoice['salesPerson']),
            hideIfEmpty: true,
          ),
        ],
      ),
    );
  }

  Widget _outlinedSection(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: child,
    );
  }

  Widget _detailItem(String title, String value, {bool hideIfEmpty = false}) {
    if (hideIfEmpty && value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 125, child: SizedBox()),

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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ITEMS
  // ===========================================================================

  Widget _buildItemsSection(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    return Padding(
      padding: EdgeInsets.all(context.wp(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.shopping_bag_outlined,
            title: 'Items & Services',
            subtitle: '${items.length} ${items.length == 1 ? 'item' : 'items'}',
          ),

          SizedBox(height: context.hp(1.5)),

          _buildItemsTable(context, items),
        ],
      ),
    );
  }

  Widget _buildItemsTable(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    const tableWidth = 760.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
    final child = Align(
      alignment: alignment,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          color: const Color(0xFF344054),
          fontWeight: FontWeight.w800,
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

    final rate = _number(item['price'] ?? item['rate']);

    final gst = _number(item['gstPercent'] ?? item['gst']);

    final amount = item['amount'] != null
        ? _number(item['amount'])
        : quantity * rate;

    final service = _safeString(item['name'] ?? item['service']);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Text(
              service.isEmpty ? '-' : service,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF101828),
                fontWeight: FontWeight.w700,
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
              _quantity(quantity),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF344054),
                fontWeight: FontWeight.w700,
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
                color: const Color(0xFF101828),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOTALS + BANK
  // ===========================================================================

  Widget _buildTotalsAndBankSection(
    BuildContext context, {
    required double subtotal,
    required double sgst,
    required double cgst,
    required double totalGst,
    required double roundOff,
    required double total,
  }) {
    return Padding(
      padding: EdgeInsets.all(context.wp(5)),
      child: Column(
        children: [
          _buildTotalsSection(
            context,
            subtotal: subtotal,
            sgst: sgst,
            cgst: cgst,
            totalGst: totalGst,
            roundOff: roundOff,
            total: total,
          ),

          if (_hasBankDetails()) ...[
            SizedBox(height: context.hp(1.5)),

            _buildBankDetails(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsSection(
    BuildContext context, {
    required double subtotal,
    required double sgst,
    required double cgst,
    required double totalGst,
    required double roundOff,
    required double total,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.wp(4)),
        child: Column(
          children: [
            _amountRow('Sub Total', _money(subtotal)),

            _amountRow('SGST', _money(sgst)),

            _amountRow('CGST', _money(cgst)),

            _amountRow('Total GST', _money(totalGst)),

            _amountRow('Round Off', _money(roundOff)),

            SizedBox(height: context.hp(1)),

            const Divider(height: 1, color: Color(0xFFD0D5DD)),

            SizedBox(height: context.hp(1.2)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Total',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: const Color(0xFF101828),
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: context.hp(0.2)),

                      Text(
                        'Amount payable',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF98A2B3),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: context.wp(2)),

                Text(
                  _money(total),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF667085),
              fontWeight: FontWeight.w600,
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

  Widget _buildBankDetails(BuildContext context) {
    final bankName = _safeString(widget.invoice['bankName']);

    final accountNumber = _safeString(widget.invoice['accountNumber']);

    final ifsc = _safeString(
      widget.invoice['ifsc'] ?? widget.invoice['ifscCode'],
    );

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
            width: context.wp(11),
            height: context.wp(11),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_outlined,
              color: AppColors.primary,
              size: context.wp(5.5),
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
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: context.hp(0.9)),

                if (bankName.isNotEmpty) _bankRow('Bank', bankName),

                if (accountNumber.isNotEmpty)
                  _bankRow('A/C No.', accountNumber),

                if (ifsc.isNotEmpty) _bankRow('IFSC', ifsc),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAYMENT STATUS
  // ===========================================================================

  Widget _buildPaymentStatus(BuildContext context, String status) {
    final isPaid = status.toLowerCase() == 'paid';

    final backgroundColor = isPaid
        ? AppColors.success.withValues(alpha: 0.08)
        : Colors.orange.withValues(alpha: 0.08);

    final foregroundColor = isPaid ? AppColors.success : Colors.orange.shade800;

    return Padding(
      padding: EdgeInsets.all(context.wp(5)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(1.5),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: foregroundColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: context.wp(10),
              height: context.wp(10),
              decoration: BoxDecoration(
                color: foregroundColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: foregroundColor,
                size: context.wp(5),
              ),
            ),

            SizedBox(width: context.wp(3)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Status',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF667085),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: context.hp(0.2)),

                  Text(
                    status,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(3),
                vertical: context.hp(0.7),
              ),
              decoration: BoxDecoration(
                color: foregroundColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isPaid ? 'PAID' : status.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SIGNATURE
  // ===========================================================================

  Widget _buildSignatureSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.wp(5),
        context.hp(3),
        context.wp(5),
        context.hp(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: context.wp(38),
            child: Column(
              children: [
                SizedBox(height: context.hp(5)),

                Container(
                  height: 1,
                  width: double.infinity,
                  color: const Color(0xFF344054),
                ),

                SizedBox(height: context.hp(0.7)),

                Text(
                  'Authorized Signature',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTION BUTTONS
  // ===========================================================================

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: context.hp(6.5),
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _printInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.55,
                  ),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: isLoading
                    ? SizedBox(
                        width: context.wp(5),
                        height: context.wp(5),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.print_outlined, size: context.wp(5)),
                label: Text(
                  isLoading ? 'Saving Invoice...' : 'Print Invoice',
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            SizedBox(height: context.hp(1.2)),

            SizedBox(
              width: double.infinity,
              height: context.hp(6.5),
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _printViaBluetooth,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.primary.withValues(
                    alpha: 0.45,
                  ),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: Icon(Icons.bluetooth_outlined, size: context.wp(5)),
                label: Text(
                  'Print via Bluetooth',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // BLUETOOTH PERMISSIONS
  // ===========================================================================

  Future<bool> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final scanStatus = await Permission.bluetoothScan.request();

    final connectStatus = await Permission.bluetoothConnect.request();

    return scanStatus.isGranted && connectStatus.isGranted;
  }

  Future<bool> _ensureBluetoothReady() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final permissionGranted = await _requestBluetoothPermissions();

    if (!permissionGranted) {
      if (!mounted) {
        return false;
      }

      final openSettings = await _showBluetoothPermissionDialog();

      if (openSettings) {
        await openAppSettings();
      }

      return false;
    }

    final enabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (!enabled) {
      if (!mounted) {
        return false;
      }

      final result = await _showBluetoothOffDialog();

      if (result) {
        await _requestEnableBluetooth();

        await Future.delayed(const Duration(milliseconds: 500));

        final enabledAfterRequest =
            await PrintBluetoothThermal.bluetoothEnabled;

        if (enabledAfterRequest) {
          return true;
        }
      }

      return false;
    }

    return true;
  }

  // ===========================================================================
  // ANDROID BLUETOOTH ENABLE REQUEST
  // ===========================================================================

  Future<bool> _requestEnableBluetooth() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      const channel = MethodChannel('invoice/bluetooth');

      final result = await channel.invokeMethod<bool>('requestEnableBluetooth');

      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _showBluetoothPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Bluetooth Permission'),
          content: const Text(
            'Nearby devices permission is required to search for Bluetooth printers.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _showBluetoothOffDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Bluetooth is turned off'),
          content: const Text(
            'Bluetooth needs to be enabled before searching for printers.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Turn On'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ===========================================================================
  // BLUETOOTH PRINT FLOW
  // ===========================================================================

  Future<void> _printViaBluetooth() async {
    final provider = context.read<InvoiceProvider>();

    if (provider.isLoading) {
      return;
    }

    try {
      // -----------------------------------------------------------------------
      // 1. SAVE INVOICE
      // -----------------------------------------------------------------------

      final invoiceModel = InvoiceModel.fromPreviewMap(widget.invoice);

      final savedInvoice = await provider.createInvoice(invoiceModel);

      if (!mounted) {
        return;
      }

      if (savedInvoice == null) {
        _showSnackBar(
          'Invoice saved locally, but server sync failed.',
          isError: true,
        );

        return;
      }

      // -----------------------------------------------------------------------
      // 2. CHECK BLUETOOTH
      // -----------------------------------------------------------------------

      final bluetoothReady = await _ensureBluetoothReady();

      if (!bluetoothReady || !mounted) {
        return;
      }

      // -----------------------------------------------------------------------
      // 3. GET PAIRED BLUETOOTH PRINTERS
      // -----------------------------------------------------------------------

      _showSnackBar(
        'Searching for paired Bluetooth printers...',
        isError: false,
      );

      final devices = await PrintBluetoothThermal.pairedBluetooths;

      if (!mounted) {
        return;
      }

      if (devices.isEmpty) {
        await _showNoBluetoothPrintersDialog();
        return;
      }

      // -----------------------------------------------------------------------
      // 4. SELECT PRINTER
      // -----------------------------------------------------------------------

      final selectedPrinter = await _showBluetoothPrinterSelection(devices);

      if (!mounted || selectedPrinter == null) {
        return;
      }

      // -----------------------------------------------------------------------
      // 5. IMPORTANT
      //
      // print_bluetooth_thermal only supports ESC/POS thermal printing.
      // It cannot receive an A4 PDF.
      //
      // Therefore we do NOT pretend to send the A4 PDF through this package.
      // We open Android's native A4 print framework instead.
      // -----------------------------------------------------------------------

      _showSnackBar(
        '${selectedPrinter.name.isEmpty ? 'Printer' : selectedPrinter.name} selected.',
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 250));

      await _printA4Pdf(savedInvoice);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showSnackBar('Unable to find Bluetooth printers.', isError: true);
    }
  }

  // ===========================================================================
  // PRINTER SELECTION
  // ===========================================================================

  Future<BluetoothInfo?> _showBluetoothPrinterSelection(
    List<BluetoothInfo> devices,
  ) async {
    return showModalBottomSheet<BluetoothInfo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: context.hp(1.5)),

                Container(
                  width: context.wp(12),
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                SizedBox(height: context.hp(2)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.wp(5)),
                  child: Row(
                    children: [
                      Container(
                        width: context.wp(11),
                        height: context.wp(11),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.print_outlined,
                          color: AppColors.primary,
                          size: context.wp(5.5),
                        ),
                      ),

                      SizedBox(width: context.wp(3)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Printer',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: const Color(0xFF101828),
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            SizedBox(height: context.hp(0.3)),

                            Text(
                              '${devices.length} paired Bluetooth printer${devices.length == 1 ? '' : 's'} found',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.hp(1.5)),

                const Divider(height: 1, color: Color(0xFFE4E7EC)),

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.wp(4),
                      vertical: context.hp(1.5),
                    ),
                    itemCount: devices.length,
                    separatorBuilder: (_, __) {
                      return SizedBox(height: context.hp(1));
                    },
                    itemBuilder: (context, index) {
                      final printer = devices[index];

                      final printerName = printer.name.trim().isEmpty
                          ? 'Unknown Printer'
                          : printer.name;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(context, printer);
                        },
                        child: Container(
                          padding: EdgeInsets.all(context.wp(4)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4E7EC)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: context.wp(12),
                                height: context.wp(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE4E7EC),
                                  ),
                                ),
                                child: Icon(
                                  Icons.print_outlined,
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
                                      printerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: const Color(0xFF101828),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),

                                    SizedBox(height: context.hp(0.4)),

                                    Text(
                                      printer.macAdress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF98A2B3),
                                      ),
                                    ),

                                    SizedBox(height: context.hp(0.4)),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.bluetooth_connected,
                                          size: context.wp(3.5),
                                          color: AppColors.primary,
                                        ),

                                        SizedBox(width: context.wp(1)),

                                        Text(
                                          'Paired Bluetooth device',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.chevron_right_rounded,
                                color: const Color(0xFF98A2B3),
                                size: context.wp(6),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // NO BLUETOOTH PRINTERS
  // ===========================================================================

  Future<void> _showNoBluetoothPrintersDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('No printers found'),
          content: const Text(
            'No paired Bluetooth printers were found. Pair your printer from Bluetooth settings and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // A4 PRINT
  // ===========================================================================

  Future<void> _printA4Pdf(InvoiceModel invoice) async {
    try {
      final pdfBytes = await _generateInvoicePdf(invoice);

      if (!mounted) {
        return;
      }

      await Printing.layoutPdf(
        name: 'Invoice-${invoice.invoiceNo}',
        format: PdfPageFormat.a4,
        onLayout: (format) async {
          return pdfBytes;
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showSnackBar('Unable to open A4 print dialog.', isError: true);
    }
  }

  // ===========================================================================
  // CANON MESSAGE
  // ===========================================================================

  void _showCanonWirelessMessage() {
    if (!mounted) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            context.wp(5),
            context.hp(2.5),
            context.wp(5),
            context.hp(3),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.wp(12),
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              SizedBox(height: context.hp(2.5)),

              Container(
                width: context.wp(16),
                height: context.wp(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.print_outlined,
                  color: AppColors.primary,
                  size: context.wp(8),
                ),
              ),

              SizedBox(height: context.hp(1.8)),

              Text(
                'Canon G3010',
                style: AppTextStyles.titleLarge.copyWith(
                  color: const Color(0xFF101828),
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: context.hp(0.7)),

              Text(
                'This printer does not use Bluetooth.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF667085),
                  height: 1.5,
                ),
              ),

              SizedBox(height: context.hp(0.8)),

              Text(
                'Connect your phone to the Canon G3010 through Wi-Fi / Wireless Direct and use Print Invoice.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF98A2B3),
                  height: 1.5,
                ),
              ),

              SizedBox(height: context.hp(2.2)),

              SizedBox(
                width: double.infinity,
                height: context.hp(6),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(Icons.print_outlined, size: context.wp(5)),
                  label: Text(
                    'Use Print Invoice',
                    style: AppTextStyles.button.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // UI HELPERS
  // ===========================================================================

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
                  color: const Color(0xFF101828),
                  fontWeight: FontWeight.w800,
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

  Widget _contactRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF98A2B3)),

        const SizedBox(width: 5),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
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

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE4E7EC));
  }

  // ===========================================================================
  // CONDITIONS
  // ===========================================================================

  bool _hasBusinessDetails() {
    return _safeString(widget.invoice['sellerGstin']).isNotEmpty ||
        _safeString(widget.invoice['sellerLicense']).isNotEmpty ||
        _safeString(widget.invoice['dispatchedThrough']).isNotEmpty ||
        _safeString(widget.invoice['reference']).isNotEmpty ||
        _safeString(widget.invoice['salesPerson']).isNotEmpty;
  }

  bool _hasBankDetails() {
    return _safeString(widget.invoice['bankName']).isNotEmpty ||
        _safeString(widget.invoice['accountNumber']).isNotEmpty ||
        _safeString(
          widget.invoice['ifsc'] ?? widget.invoice['ifscCode'],
        ).isNotEmpty;
  }

  bool _hasBankDetailsForModel(InvoiceModel invoice) {
    return invoice.bankName.isNotEmpty ||
        invoice.accountNumber.isNotEmpty ||
        invoice.ifscCode.isNotEmpty;
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Colors.red.shade700 : AppColors.success,
        ),
      );
  }
}
