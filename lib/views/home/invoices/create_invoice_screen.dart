import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  int _currentStep = 0;

  static const List<String> _stepTitles = [
    'Seller Details',
    'Invoice Details',
    'Bill To',
    'Invoice Items',
    'Payment & Bank',
    'Invoice Summary',
  ];

  static const List<IconData> _stepIcons = [
    Icons.storefront_outlined,
    Icons.receipt_long_outlined,
    Icons.person_outline,
    Icons.inventory_2_outlined,
    Icons.account_balance_outlined,
    Icons.summarize_outlined,
  ];

  // ---------------------------------------------------------------------------
  // DEFAULT VALUES
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
  // BANK CONTROLLERS
  // ---------------------------------------------------------------------------

  final _bankNameController = TextEditingController(text: _defaultBankName);

  final _accountNumberController = TextEditingController(
    text: _defaultAccountNumber,
  );

  final _ifscController = TextEditingController(text: _defaultIfsc);

  // ---------------------------------------------------------------------------
  // INVOICE CONTROLLERS
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
  // CUSTOMER CONTROLLERS
  // ---------------------------------------------------------------------------

  final _customerNameController = TextEditingController();

  final _customerPhoneController = TextEditingController();

  final _customerEmailController = TextEditingController();

  final _customerAddressController = TextEditingController();

  final _customerGstinController = TextEditingController();

  // ---------------------------------------------------------------------------
  // ITEM CONTROLLERS
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
  // ITEM CALCULATIONS
  // ---------------------------------------------------------------------------

  void _addItem() {
    final product = _productController.text.trim();
    final hsn = _hsnController.text.trim();

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;

    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    final gst = double.tryParse(_gstController.text.trim()) ?? -1;

    if (product.isEmpty) {
      _showMessage('Please enter product / service name');
      return;
    }

    if (hsn.isEmpty) {
      _showMessage('Please enter HSN code');
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

  double get _sgst => _totalGst / 2;

  double get _cgst => _totalGst / 2;

  double get _beforeRoundOff => _subtotal + _totalGst;

  double get _roundOff {
    return _beforeRoundOff.roundToDouble() - _beforeRoundOff;
  }

  double get _grandTotal {
    return _beforeRoundOff + _roundOff;
  }

  // ---------------------------------------------------------------------------
  // DATE
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
  // STEP VALIDATION
  // ---------------------------------------------------------------------------

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateSellerDetails();

      case 1:
        return _validateInvoiceDetails();

      case 2:
        return _validateBillTo();

      case 3:
        return _validateItems();

      case 4:
        return _validatePaymentAndBank();

      case 5:
        return _validateAllSteps();

      default:
        return true;
    }
  }

  bool _validateAllSteps() {
    return _validateSellerDetails() &&
        _validateInvoiceDetails() &&
        _validateBillTo() &&
        _validateItems() &&
        _validatePaymentAndBank();
  }

  // ---------------------------------------------------------------------------
  // SELLER VALIDATION
  // ---------------------------------------------------------------------------

  bool _validateSellerDetails() {
    final form = _formKey.currentState;

    if (form == null) {
      return false;
    }

    if (!_validateControllers([
      _sellerNameController,
      _sellerAddressController,
      _sellerPhoneController,
      _sellerEmailController,
    ])) {
      return false;
    }

    if (_phoneValidator(_sellerPhoneController.text) != null) {
      _showMessage(_phoneValidator(_sellerPhoneController.text)!);
      return false;
    }

    if (_emailValidator(_sellerEmailController.text) != null) {
      _showMessage(_emailValidator(_sellerEmailController.text)!);
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // INVOICE VALIDATION
  // ---------------------------------------------------------------------------

  bool _validateInvoiceDetails() {
    if (_invoiceNumberController.text.trim().isEmpty) {
      _showMessage('Please enter invoice number');
      return false;
    }

    if (_financialYearController.text.trim().isEmpty) {
      _showMessage('Please enter financial year');
      return false;
    }

    if (!_financialYearValidator(_financialYearController.text)) {
      _showMessage('Enter financial year in YYYY-YYYY format');
      return false;
    }

    if (_dispatchedThroughController.text.trim().isEmpty) {
      _showMessage('Please enter dispatched through');
      return false;
    }

    if (_referenceController.text.trim().isEmpty) {
      _showMessage('Please enter reference');
      return false;
    }

    if (_salesPersonController.text.trim().isEmpty) {
      _showMessage('Please enter salesperson name');
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // BILL TO VALIDATION
  // ---------------------------------------------------------------------------

  bool _validateBillTo() {
    if (_customerNameController.text.trim().isEmpty) {
      _showMessage('Please enter customer / company name');
      return false;
    }

    if (_customerAddressController.text.trim().isEmpty) {
      _showMessage('Please enter customer address');
      return false;
    }

    if (_customerPhoneController.text.trim().isEmpty) {
      _showMessage('Please enter customer phone number');
      return false;
    }

    if (_phoneValidator(_customerPhoneController.text) != null) {
      _showMessage(_phoneValidator(_customerPhoneController.text)!);
      return false;
    }

    if (_customerEmailController.text.trim().isEmpty) {
      _showMessage('Please enter customer email');
      return false;
    }

    if (_emailValidator(_customerEmailController.text) != null) {
      _showMessage(_emailValidator(_customerEmailController.text)!);
      return false;
    }

    // Customer GSTIN intentionally has no validation.

    return true;
  }

  // ---------------------------------------------------------------------------
  // ITEMS VALIDATION
  // ---------------------------------------------------------------------------

  bool _validateItems() {
    if (_items.isEmpty) {
      _showMessage('Please add at least one invoice item');
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // PAYMENT + BANK VALIDATION
  // ---------------------------------------------------------------------------

  bool _validatePaymentAndBank() {
    if (_paymentStatus.trim().isEmpty) {
      _showMessage('Please select payment status');
      return false;
    }

    if (_bankNameController.text.trim().isEmpty) {
      _showMessage('Please enter bank name');
      return false;
    }

    if (_accountNumberController.text.trim().isEmpty) {
      _showMessage('Please enter account number');
      return false;
    }

    if (_ifscController.text.trim().isEmpty) {
      _showMessage('Please enter IFSC code');
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // CONTROLLER VALIDATION
  // ---------------------------------------------------------------------------

  bool _validateControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      if (controller.text.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // NEXT / PREVIOUS
  // ---------------------------------------------------------------------------

  void _nextStep() {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep == 0) return;

    setState(() {
      _currentStep--;
    });
  }

  // ---------------------------------------------------------------------------
  // PREVIEW
  // ---------------------------------------------------------------------------

  void _previewInvoice() {
    if (!_validateAllSteps()) {
      return;
    }

    if (_items.isEmpty) {
      _showMessage('Please add at least one item');
      return;
    }

    final invoice = {
      'sellerName': _sellerNameController.text.trim(),
      'sellerAddress': _sellerAddressController.text.trim(),
      'sellerPhone': _sellerPhoneController.text.trim(),
      'sellerEmail': _sellerEmailController.text.trim(),
      'sellerGstin': _sellerGstinController.text.trim(),
      'sellerLicense': _sellerLicenseController.text.trim(),

      'invoiceNumber': _invoiceNumberController.text.trim(),
      'financialYear': _financialYearController.text.trim(),
      'date': _invoiceDate,
      'dispatchedThrough': _dispatchedThroughController.text.trim(),
      'reference': _referenceController.text.trim(),
      'salesPerson': _salesPersonController.text.trim(),

      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim(),
      'customerEmail': _customerEmailController.text.trim(),
      'customerAddress': _customerAddressController.text.trim(),
      'customerGstin': _customerGstinController.text.trim(),

      'items': List<Map<String, dynamic>>.from(_items),

      'paymentStatus': _paymentStatus,

      'subtotal': _subtotal,
      'sgst': _sgst,
      'cgst': _cgst,
      'roundOff': _roundOff,
      'totalGst': _totalGst,
      'total': _grandTotal,

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
  // VALIDATORS
  // ---------------------------------------------------------------------------

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final email = value.trim();

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  bool _financialYearValidator(String value) {
    return RegExp(r'^\d{4}-\d{4}$').hasMatch(value.trim());
  }

  // ---------------------------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
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

      body: Column(
        children: [
          _buildProgressHeader(),

          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wp(4),
                  vertical: context.hp(2),
                ),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ---------------------------------------------------------------------------
  // PROGRESS HEADER
  // ---------------------------------------------------------------------------

  Widget _buildProgressHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.wp(4),
        context.hp(1.8),
        context.wp(4),
        context.hp(1.6),
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.45)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_stepTitles.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          final activeColor = AppColors.primary;
          final inactiveColor = theme.dividerColor.withValues(alpha: 0.45);

          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (index < _currentStep) {
                      setState(() {
                        _currentStep = index;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent || isCompleted
                          ? activeColor
                          : colorScheme.surface,
                      border: Border.all(
                        color: isCurrent || isCompleted
                            ? activeColor
                            : inactiveColor,
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.18),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted ? Icons.check_rounded : _stepIcons[index],
                        size: 19,
                        color: isCurrent || isCompleted
                            ? Colors.white
                            : theme.textTheme.bodySmall?.color?.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ),
                  ),
                ),

                if (index < _stepTitles.length - 1)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.wp(1.2),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 3,
                        decoration: BoxDecoration(
                          color: index < _currentStep
                              ? activeColor
                              : inactiveColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CURRENT STEP
  // ---------------------------------------------------------------------------

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildSellerDetails();

      case 1:
        return _buildInvoiceDetails();

      case 2:
        return _buildBillTo();

      case 3:
        return _buildInvoiceItems();

      case 4:
        return _buildPaymentAndBank();

      case 5:
        return _buildInvoiceSummary();

      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // SELLER DETAILS
  // ---------------------------------------------------------------------------

  Widget _buildSellerDetails() {
    return _sectionCard(
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
            validator: _requiredValidator,
          ),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _sellerPhoneController,
            heading: 'Phone',
            hint: 'Enter 10-digit phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _phoneValidator,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _sellerEmailController,
            heading: 'Email',
            hint: 'Enter email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
          ),

          SizedBox(height: context.hp(2)),

          // GSTIN intentionally has NO validation.
          _field(
            controller: _sellerGstinController,
            heading: 'GSTIN',
            hint: 'Enter GST identification number',
            icon: Icons.receipt_long_outlined,
          ),

          SizedBox(height: context.hp(2)),

          // DL No. intentionally has NO validation.
          _field(
            controller: _sellerLicenseController,
            heading: 'DL No.',
            hint: 'Enter license number',
            icon: Icons.badge_outlined,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INVOICE DETAILS
  // ---------------------------------------------------------------------------

  Widget _buildInvoiceDetails() {
    return _sectionCard(
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Financial year is required';
                    }

                    if (!_financialYearValidator(value)) {
                      return 'Use YYYY-YYYY';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: context.hp(2)),

          _dateField(),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _dispatchedThroughController,
            heading: 'Dispatched Through',
            hint: 'Transport / courier',
            icon: Icons.local_shipping_outlined,
            validator: _requiredValidator,
          ),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _referenceController,
            heading: 'Reference',
            hint: 'Reference number',
            icon: Icons.link_outlined,
            validator: _requiredValidator,
          ),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _salesPersonController,
            heading: 'Salesperson',
            hint: 'Salesperson name',
            icon: Icons.person_outline,
            validator: _requiredValidator,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BILL TO
  // ---------------------------------------------------------------------------

  Widget _buildBillTo() {
    return _sectionCard(
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
            validator: _requiredValidator,
          ),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _customerPhoneController,
            heading: 'Phone',
            hint: 'Enter 10-digit phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _phoneValidator,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),

          SizedBox(height: context.hp(2)),

          _field(
            controller: _customerEmailController,
            heading: 'Email',
            hint: 'Enter email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
          ),

          SizedBox(height: context.hp(2)),

          // GSTIN intentionally has NO validation.
          _field(
            controller: _customerGstinController,
            heading: 'GSTIN',
            hint: 'GST identification number',
            icon: Icons.receipt_long_outlined,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INVOICE ITEMS
  // ---------------------------------------------------------------------------

  Widget _buildInvoiceItems() {
    return _sectionCard(
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

          _field(
            controller: _hsnController,
            heading: 'HSN Code',
            hint: 'Enter HSN code',
            icon: Icons.qr_code_2_outlined,
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

          _field(
            controller: _gstController,
            heading: 'GST %',
            hint: 'GST percentage',
            icon: Icons.percent_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT + BANK
  // ---------------------------------------------------------------------------

  Widget _buildPaymentAndBank() {
    return Column(
      children: [
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Payment status is required';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.payments_outlined),
                  hintText: 'Select payment status',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: const [
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
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
                validator: _requiredValidator,
              ),

              SizedBox(height: context.hp(2)),

              _field(
                controller: _accountNumberController,
                heading: 'Account Number',
                hint: 'Account number',
                icon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                validator: _requiredValidator,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              SizedBox(height: context.hp(2)),

              _field(
                controller: _ifscController,
                heading: 'IFSC Code',
                hint: 'IFSC code',
                icon: Icons.code_outlined,
                validator: _requiredValidator,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildInvoiceSummary() {
    return Column(
      children: [
        _totalCard(),

        SizedBox(height: context.hp(2)),

        _summaryInfoCard(
          title: 'Seller',
          icon: Icons.storefront_outlined,
          values: [
            _sellerNameController.text.trim(),
            _sellerPhoneController.text.trim(),
            _sellerEmailController.text.trim(),
          ],
        ),

        SizedBox(height: context.hp(2)),

        _summaryInfoCard(
          title: 'Bill To',
          icon: Icons.person_outline,
          values: [
            _customerNameController.text.trim(),
            _customerPhoneController.text.trim(),
            _customerEmailController.text.trim(),
          ],
        ),

        SizedBox(height: context.hp(2)),

        _summaryInfoCard(
          title: 'Payment',
          icon: Icons.payments_outlined,
          values: [_paymentStatus, _bankNameController.text.trim()],
        ),

        SizedBox(height: context.hp(3)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY INFO CARD
  // ---------------------------------------------------------------------------

  Widget _summaryInfoCard({
    required String title,
    required IconData icon,
    required List<String> values,
  }) {
    final filteredValues = values.where((value) => value.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
        ),
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

              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (filteredValues.isNotEmpty) ...[
            SizedBox(height: context.hp(1.5)),

            ...filteredValues.map(
              (value) => Padding(
                padding: EdgeInsets.only(bottom: context.hp(0.6)),
                child: Text(value, style: AppTextStyles.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ---------------------------------------------------------------------------

  Widget _buildBottomNavigation() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _stepTitles.length - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          context.wp(4),
          context.hp(1.2),
          context.wp(4),
          context.hp(1.2),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (!isFirst) ...[
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    label: Text(
                      'Previous',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: context.wp(3)),
                    ),
                  ),
                ),
              ),

              SizedBox(width: context.wp(3)),
            ],

            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLast ? _previewInvoice : _nextStep,
                  icon: Icon(
                    isLast
                        ? Icons.preview_outlined
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                  label: Text(
                    isLast ? 'Preview' : 'Next',
                    style: AppTextStyles.button,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: context.wp(3)),
                  ),
                ),
              ),
            ),
          ],
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
  // FIELD
  // ---------------------------------------------------------------------------

  Widget _field({
    required TextEditingController controller,
    required String heading,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
                child: const Icon(
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
                      '${item['quantity']} × '
                      '₹${(item['price'] as double).toStringAsFixed(2)}'
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
