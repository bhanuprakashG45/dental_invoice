import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';
import 'package:invoice/views/home/invoices/invoice_preview_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // DEFAULT SELLER DETAILS
  // ---------------------------------------------------------------------------

  static const String _defaultSellerName = 'SRI SUMUKH ASSOCIATES';

  static const String _defaultSellerAddress =
      '#76, Krishna Rajendra Road\n'
      'Basavanagudi\n'
      'Bengaluru - 560 004';

  static const String _defaultSellerPhone = '9844039405';

  static const String _defaultSellerEmail = 'ssri.sumukh76@gmail.com';

  static const String _defaultSellerGstin = '29AHDPM0272E1ZK';

  static const String _defaultSellerLicense = 'KA/BNG/II/20B/958';

  static const String _defaultBankName = 'SBI, Basavanagudi Branch';

  static const String _defaultAccountNumber = '54021257984';

  static const String _defaultIfsc = 'SBIN0040014';

  static const String _defaultSalesPerson = 'Srinivas';

  // ---------------------------------------------------------------------------
  // SELLER DETAILS
  // ---------------------------------------------------------------------------

  final _sellerNameController = TextEditingController(text: _defaultSellerName);

  final _sellerAddressController = TextEditingController(
    text: _defaultSellerAddress,
  );

  final _sellerPhoneController = TextEditingController(
    text: _defaultSellerPhone,
  );

  final _sellerEmailController = TextEditingController(
    text: _defaultSellerEmail,
  );

  final _sellerGstinController = TextEditingController(
    text: _defaultSellerGstin,
  );

  final _sellerLicenseController = TextEditingController(
    text: _defaultSellerLicense,
  );

  // ---------------------------------------------------------------------------
  // BANK DETAILS
  // ---------------------------------------------------------------------------

  final _bankNameController = TextEditingController(text: _defaultBankName);

  final _accountNumberController = TextEditingController(
    text: _defaultAccountNumber,
  );

  final _ifscController = TextEditingController(text: _defaultIfsc);

  // ---------------------------------------------------------------------------
  // INVOICE DETAILS
  // ---------------------------------------------------------------------------

  final _invoiceNumberController = TextEditingController(text: '075');

  final _financialYearController = TextEditingController(text: '2025-2026');

  final _dispatchedThroughController = TextEditingController();

  final _referenceController = TextEditingController();

  final _salesPersonController = TextEditingController(
    text: _defaultSalesPerson,
  );

  DateTime _invoiceDate = DateTime.now();

  // ---------------------------------------------------------------------------
  // CUSTOMER DETAILS
  // ---------------------------------------------------------------------------

  final _customerNameController = TextEditingController();

  final _customerPhoneController = TextEditingController();

  final _customerEmailController = TextEditingController();

  final _customerAddressController = TextEditingController();

  final _customerGstinController = TextEditingController();

  // ---------------------------------------------------------------------------
  // ITEM DETAILS
  // ---------------------------------------------------------------------------

  final _productController = TextEditingController();

  final _hsnController = TextEditingController();

  final _quantityController = TextEditingController(text: '1');

  final _priceController = TextEditingController();

  final _gstController = TextEditingController(text: '12');

  String _paymentStatus = 'Paid';

  final List<Map<String, dynamic>> _items = [];

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _sellerNameController.dispose();
    _sellerAddressController.dispose();
    _sellerPhoneController.dispose();
    _sellerEmailController.dispose();
    _sellerGstinController.dispose();
    _sellerLicenseController.dispose();

    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();

    _invoiceNumberController.dispose();
    _financialYearController.dispose();
    _dispatchedThroughController.dispose();
    _referenceController.dispose();
    _salesPersonController.dispose();

    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _customerGstinController.dispose();

    _productController.dispose();
    _hsnController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _gstController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ADD ITEM
  // ---------------------------------------------------------------------------

  void _addItem() {
    final product = _productController.text.trim();
    final hsn = _hsnController.text.trim();

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;

    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    final gst = double.tryParse(_gstController.text.trim()) ?? 0;

    if (product.isEmpty) {
      _showMessage('Please enter product / service name');
      return;
    }

    if (quantity <= 0) {
      _showMessage('Please enter a valid quantity');
      return;
    }

    if (price <= 0) {
      _showMessage('Please enter a valid rate');
      return;
    }

    if (gst < 0 || gst > 100) {
      _showMessage('Please enter a valid GST percentage');
      return;
    }

    final amount = quantity * price;

    setState(() {
      _items.add({
        'name': product,
        'hsnCode': hsn,
        'quantity': quantity,
        'price': price,
        'gstPercent': gst,
        'amount': amount,
        'total': amount,
      });

      _productController.clear();
      _hsnController.clear();
      _quantityController.text = '1';
      _priceController.clear();
      _gstController.text = '12';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // CALCULATIONS
  // ---------------------------------------------------------------------------

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + (item['amount'] as double));
  }

  double get _totalGst {
    return _items.fold(0, (sum, item) {
      final amount = item['amount'] as double;
      final gst = item['gstPercent'] as double;

      return sum + (amount * gst / 100);
    });
  }

  double get _sgst {
    return _totalGst / 2;
  }

  double get _cgst {
    return _totalGst / 2;
  }

  double get _beforeRoundOff {
    return _subtotal + _totalGst;
  }

  double get _roundOff {
    return _beforeRoundOff.roundToDouble() - _beforeRoundOff;
  }

  double get _grandTotal {
    return _beforeRoundOff + _roundOff;
  }

  // ---------------------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------------------

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      _invoiceDate = selectedDate;
    });
  }

  // ---------------------------------------------------------------------------
  // PREVIEW
  // ---------------------------------------------------------------------------

  void _previewInvoice() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      _showMessage('Please add at least one item');
      return;
    }

    final invoice = {
      // Seller
      'sellerName': _sellerNameController.text.trim(),
      'sellerAddress': _sellerAddressController.text.trim(),
      'sellerPhone': _sellerPhoneController.text.trim(),
      'sellerEmail': _sellerEmailController.text.trim(),
      'sellerGstin': _sellerGstinController.text.trim(),
      'sellerLicense': _sellerLicenseController.text.trim(),

      // Invoice
      'invoiceNumber': _invoiceNumberController.text.trim(),
      'financialYear': _financialYearController.text.trim(),
      'date': _invoiceDate,
      'dispatchedThrough': _dispatchedThroughController.text.trim(),
      'reference': _referenceController.text.trim(),
      'salesPerson': _salesPersonController.text.trim(),

      // Customer
      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim(),
      'customerEmail': _customerEmailController.text.trim(),
      'customerAddress': _customerAddressController.text.trim(),
      'customerGstin': _customerGstinController.text.trim(),

      // Items
      'items': List<Map<String, dynamic>>.from(_items),

      // Payment
      'paymentStatus': _paymentStatus,

      // Totals
      'subtotal': _subtotal,
      'sgst': _sgst,
      'cgst': _cgst,
      'roundOff': _roundOff,
      'totalGst': _totalGst,
      'total': _grandTotal,

      // Bank
      'bankName': _bankNameController.text.trim(),
      'accountNumber': _accountNumberController.text.trim(),
      'ifsc': _ifscController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: invoice)),
    );
  }

  // ---------------------------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4),
            vertical: context.hp(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // SELLER DETAILS
              // =================================================================
              _sectionCard(
                title: 'Seller Details',
                icon: Icons.storefront_outlined,
                child: Column(
                  children: [
                    _field(
                      controller: _sellerNameController,
                      heading: 'Clinic / Company Name',
                      hint: 'Enter company name',
                      icon: Icons.business_outlined,
                      validator: _requiredValidator,
                    ),

                    SizedBox(height: context.hp(2)),

                    _field(
                      controller: _sellerAddressController,
                      heading: 'Address',
                      hint: 'Enter complete address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _sellerPhoneController,
                            heading: 'Phone',
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _sellerEmailController,
                            heading: 'Email',
                            hint: 'Email address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _sellerGstinController,
                            heading: 'GSTIN',
                            hint: 'GST identification number',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _sellerLicenseController,
                            heading: 'DL No.',
                            hint: 'License number',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // =================================================================
              // INVOICE DETAILS
              // =================================================================
              _sectionCard(
                title: 'Invoice Details',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _invoiceNumberController,
                            heading: 'Invoice No.',
                            hint: 'Invoice number',
                            icon: Icons.numbers_outlined,
                            validator: _requiredValidator,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _financialYearController,
                            heading: 'Financial Year',
                            hint: 'YYYY-YYYY',
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(2)),

                    _dateField(),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _dispatchedThroughController,
                            heading: 'Dispatched Through',
                            hint: 'Transport / courier',
                            icon: Icons.local_shipping_outlined,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _referenceController,
                            heading: 'Reference',
                            hint: 'Reference number',
                            icon: Icons.link_outlined,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(2)),

                    _field(
                      controller: _salesPersonController,
                      heading: 'Salesperson',
                      hint: 'Salesperson name',
                      icon: Icons.person_outline,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // =================================================================
              // CUSTOMER DETAILS
              // =================================================================
              _sectionCard(
                title: 'Bill To',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _field(
                      controller: _customerNameController,
                      heading: 'Customer / Company Name',
                      hint: 'Enter customer name',
                      icon: Icons.person_outline,
                      validator: _requiredValidator,
                    ),

                    SizedBox(height: context.hp(2)),

                    _field(
                      controller: _customerAddressController,
                      heading: 'Address',
                      hint: 'Enter customer address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _customerPhoneController,
                            heading: 'Phone',
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _customerGstinController,
                            heading: 'GSTIN',
                            hint: 'GSTIN',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(2)),

                    _field(
                      controller: _customerEmailController,
                      heading: 'Email',
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // =================================================================
              // ITEMS
              // =================================================================
              _sectionCard(
                title: 'Invoice Items',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    _field(
                      controller: _productController,
                      heading: 'Product / Service',
                      hint: 'Example: Dental Cleaning',
                      icon: Icons.inventory_2_outlined,
                    ),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _hsnController,
                            heading: 'HSN Code',
                            hint: 'HSN',
                            icon: Icons.qr_code_2_outlined,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _gstController,
                            heading: 'GST %',
                            hint: 'GST percentage',
                            icon: Icons.percent_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _quantityController,
                            heading: 'Quantity',
                            hint: '1',
                            icon: Icons.production_quantity_limits_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _priceController,
                            heading: 'Rate',
                            hint: '0.00',
                            icon: Icons.currency_rupee_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(2)),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Item'),
                      ),
                    ),

                    if (_items.isNotEmpty) ...[
                      SizedBox(height: context.hp(2)),

                      const Divider(),

                      SizedBox(height: context.hp(1)),

                      _ItemsList(items: _items, onRemove: _removeItem),
                    ],
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // =================================================================
              // PAYMENT
              // =================================================================
              _sectionCard(
                title: 'Payment',
                icon: Icons.payments_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldHeading('Payment Status'),

                    SizedBox(height: context.hp(0.8)),

                    DropdownButtonFormField<String>(
                      initialValue: _paymentStatus,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.payments_outlined),
                        hintText: 'Select payment status',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _paymentStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // =================================================================
              // BANK DETAILS
              // =================================================================
              _sectionCard(
                title: 'Bank Details',
                icon: Icons.account_balance_outlined,
                child: Column(
                  children: [
                    _field(
                      controller: _bankNameController,
                      heading: 'Bank Name',
                      hint: 'Bank and branch name',
                      icon: Icons.account_balance_outlined,
                    ),

                    SizedBox(height: context.hp(2)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller: _accountNumberController,
                            heading: 'Account Number',
                            hint: 'Account number',
                            icon: Icons.account_balance_wallet_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        SizedBox(width: context.wp(3)),

                        Expanded(
                          child: _field(
                            controller: _ifscController,
                            heading: 'IFSC Code',
                            hint: 'IFSC code',
                            icon: Icons.code_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // =================================================================
              // TOTAL
              // =================================================================
              _totalCard(),

              SizedBox(height: context.hp(2.5)),

              // =================================================================
              // PREVIEW
              // =================================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _previewInvoice,
                  icon: const Icon(Icons.preview_outlined),
                  label: const Text(
                    'Preview Invoice',
                    style: AppTextStyles.button,
                  ),
                ),
              ),

              SizedBox(height: context.hp(3)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION CARD
  // ---------------------------------------------------------------------------

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),

              SizedBox(width: context.wp(3)),

              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.hp(2)),

          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FIELD HEADING
  // ---------------------------------------------------------------------------

  Widget _fieldHeading(String title) {
    return Padding(
      padding: EdgeInsets.only(left: context.wp(0.5)),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------

  Widget _field({
    required TextEditingController controller,
    required String heading,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldHeading(heading),

        SizedBox(height: context.hp(0.8)),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            alignLabelWithHint: false,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.wp(3.5),
              vertical: maxLines > 1 ? context.hp(1.8) : context.hp(1.7),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATE FIELD
  // ---------------------------------------------------------------------------

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldHeading('Invoice Date'),

        SizedBox(height: context.hp(0.8)),

        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.event_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.wp(3.5),
                vertical: context.hp(1.7),
              ),
            ),
            child: Text(
              _formatDate(_invoiceDate),
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TOTAL CARD
  // ---------------------------------------------------------------------------

  Widget _totalCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calculate_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: context.wp(3)),

              Text(
                'Invoice Summary',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: context.hp(2)),

          _totalRow('Subtotal', _subtotal),

          SizedBox(height: context.hp(1)),

          _totalRow('SGST', _sgst),

          SizedBox(height: context.hp(1)),

          _totalRow('CGST', _cgst),

          SizedBox(height: context.hp(1)),

          _totalRow('Round Off', _roundOff),

          Padding(
            padding: EdgeInsets.symmetric(vertical: context.hp(1)),
            child: const Divider(),
          ),

          _totalRow('Total Amount', _grandTotal, isGrandTotal: true),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOTAL ROW
  // ---------------------------------------------------------------------------

  Widget _totalRow(String title, double amount, {bool isGrandTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isGrandTotal
              ? AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: isGrandTotal
              ? AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                )
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // VALIDATOR
  // ---------------------------------------------------------------------------

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// =============================================================================
// ITEMS LIST
// =============================================================================

class _ItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int index) onRemove;

  const _ItemsList({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: context.hp(1)),
          padding: EdgeInsets.all(context.wp(3)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(width: context.wp(3)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: context.hp(0.5)),

                    if ((item['hsnCode'] as String).isNotEmpty)
                      Text(
                        'HSN: ${item['hsnCode']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                        ),
                      ),

                    SizedBox(height: context.hp(0.4)),

                    Text(
                      '${item['quantity']} × ₹${(item['price'] as double).toStringAsFixed(2)}'
                      '  •  GST ${item['gstPercent']}%',
                      style: AppTextStyles.bodySmall,
                    ),

                    SizedBox(height: context.hp(0.8)),

                    Text(
                      '₹${(item['amount'] as double).toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => onRemove(index),
                tooltip: 'Remove item',
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ],
          ),
        );
      }),
    );
  }
}
