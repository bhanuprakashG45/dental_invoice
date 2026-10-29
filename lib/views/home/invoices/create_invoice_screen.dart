import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';
import 'package:invoice/data/models/home/products/products_model.dart';
import 'package:invoice/provider/home/products/products_provider.dart';
import 'package:invoice/views/home/invoices/invoice_preview_screen.dart';
import 'package:provider/provider.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  Timer? _productSearchDebounce;

  bool _showProductDropdown = false;
  bool _isProductSelected = false;

  static const String _defaultSellerName = 'SRI SUMUKH ASSOCIATES';
  static const String _defaultSellerAddress =
      '#76, Krishna Rajendra Road\nBasavanagudi\nBengaluru - 560 004';
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

  final _bankNameController = TextEditingController(text: _defaultBankName);
  final _accountNumberController = TextEditingController(
    text: _defaultAccountNumber,
  );
  final _ifscController = TextEditingController(text: _defaultIfsc);

  final _invoiceNumberController = TextEditingController(text: 'INV-1');
  final _financialYearController = TextEditingController(text: '2025-2026');
  final _dispatchedThroughController = TextEditingController(text: 'Courier');
  final _referenceController = TextEditingController(text: 'N/A');
  final _salesPersonController = TextEditingController(
    text: _defaultSalesPerson,
  );

  DateTime _invoiceDate = DateTime.now();

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerGstinController = TextEditingController();

  final _productController = TextEditingController();
  final _hsnController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _gstController = TextEditingController(text: '12');

  String _paymentStatus = 'Paid';

  final List<Map<String, dynamic>> _items = [];

  static const Color _background = Color(0xFFF0F7FF);
  static const Color _primary = Color(0xFF0866D9);
  static const Color _heading = Color(0xFF102A68);
  static const Color _border = Color(0xFFDCE5F0);
  static const Color _label = Color(0xFF526079);

  @override
  void dispose() {
    _productSearchDebounce?.cancel();

    for (final controller in [
      _sellerNameController,
      _sellerAddressController,
      _sellerPhoneController,
      _sellerEmailController,
      _sellerGstinController,
      _sellerLicenseController,
      _bankNameController,
      _accountNumberController,
      _ifscController,
      _invoiceNumberController,
      _financialYearController,
      _dispatchedThroughController,
      _referenceController,
      _salesPersonController,
      _customerNameController,
      _customerPhoneController,
      _customerEmailController,
      _customerAddressController,
      _customerGstinController,
      _productController,
      _hsnController,
      _quantityController,
      _priceController,
      _gstController,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Widget _responsiveFields(List<Widget> fields, {double spacing = 14}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 2 : 1;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: context.hp(1.8),
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  Widget _responsiveThreeFields(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700
            ? 3
            : constraints.maxWidth >= 430
            ? 2
            : 1;

        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: context.hp(1.8),
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create Invoice',
          style: AppTextStyles.titleLarge.copyWith(
            color: _heading,
            fontWeight: FontWeight.w800,
            fontSize: context.sp(21),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _heading),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEAF4FF),
                    Color(0xFFF4F9FF),
                    Color(0xFFF0F7FF),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      context.wp(4),
                      context.hp(1.5),
                      context.wp(4),
                      context.hp(3),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSellerDetails(),
                            SizedBox(height: context.hp(1.5)),
                            _buildInvoiceDetails(),
                            SizedBox(height: context.hp(1.5)),
                            _buildBillTo(),
                            SizedBox(height: context.hp(1.5)),
                            _buildInvoiceItems(),
                            SizedBox(height: context.hp(1.5)),
                            _buildPaymentAndBank(),
                            SizedBox(height: context.hp(1.5)),
                            _buildInvoiceSummary(),
                            SizedBox(height: context.hp(1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Fixed bottom button
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              color: _background,
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(4),
                vertical: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _previewInvoice,
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(
                        'Preview Invoice',
                        style: AppTextStyles.button.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EBF7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF234D80).withValues(alpha: 0.045),
            blurRadius: 14,
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
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: _primary),
              ),
              SizedBox(width: context.wp(3)),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _heading,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action != null) action,
            ],
          ),
          SizedBox(height: context.hp(2)),
          child,
        ],
      ),
    );
  }

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
          SizedBox(height: context.hp(1.8)),
          _field(
            controller: _sellerAddressController,
            heading: 'Address',
            hint: 'Enter complete address',
            icon: Icons.location_on_outlined,
            maxLines: 3,
            validator: _requiredValidator,
          ),
          SizedBox(height: context.hp(1.8)),
          _responsiveFields([
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
            _field(
              controller: _sellerEmailController,
              heading: 'Email',
              hint: 'Enter email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            _field(
              controller: _sellerGstinController,
              heading: 'GSTIN',
              hint: 'Enter GSTIN',
              icon: Icons.receipt_long_outlined,
            ),
            _field(
              controller: _sellerLicenseController,
              heading: 'DL No.',
              hint: 'Enter license number',
              icon: Icons.badge_outlined,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return _sectionCard(
      title: 'Invoice Details',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _responsiveFields([
            _field(
              controller: _invoiceNumberController,
              heading: 'Invoice No.',
              hint: 'Invoice number',
              icon: Icons.tag_rounded,
              validator: _requiredValidator,
            ),
            _field(
              controller: _financialYearController,
              heading: 'Financial Year',
              hint: 'YYYY-YYYY',
              icon: Icons.calendar_month_outlined,
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
            _dateField(),
            _field(
              controller: _dispatchedThroughController,
              heading: 'Dispatched Through',
              hint: 'Transport / courier',
              icon: Icons.local_shipping_outlined,
              validator: _requiredValidator,
            ),
            _field(
              controller: _referenceController,
              heading: 'Reference',
              hint: 'Reference number',
              icon: Icons.link_outlined,
              validator: _requiredValidator,
            ),
            _field(
              controller: _salesPersonController,
              heading: 'Salesperson',
              hint: 'Salesperson name',
              icon: Icons.person_outline,
              validator: _requiredValidator,
            ),
          ]),
        ],
      ),
    );
  }

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
          SizedBox(height: context.hp(1.8)),
          _field(
            controller: _customerAddressController,
            heading: 'Address',
            hint: 'Enter customer address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: _requiredValidator,
          ),
          SizedBox(height: context.hp(1.8)),
          _responsiveThreeFields([
            _field(
              controller: _customerPhoneController,
              heading: 'Phone',
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _phoneValidator,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            _field(
              controller: _customerGstinController,
              heading: 'GSTIN (optional)',
              hint: 'Enter GSTIN',
              icon: Icons.receipt_long_outlined,
            ),
            _field(
              controller: _customerEmailController,
              heading: 'Email',
              hint: 'Enter email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
          ]),
        ],
      ),
    );
  }

  void _onProductSearchChanged(String value) {
    _productSearchDebounce?.cancel();
    final query = value.trim();

    setState(() {
      _isProductSelected = false;
      _showProductDropdown = query.length >= 3;
    });

    if (query.length < 3) {
      context.read<ProductsProvider>().clearProducts();
      return;
    }

    _productSearchDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      await context.read<ProductsProvider>().searchProducts(query);

      if (!mounted) return;

      setState(() {
        _showProductDropdown = true;
      });
    });
  }

  void _selectProduct(ProductModel product) {
    setState(() {
      _productController.text = product.productName;
      _productController.selection = TextSelection.collapsed(
        offset: _productController.text.length,
      );
      _isProductSelected = true;
      _showProductDropdown = false;
    });

    FocusScope.of(context).unfocus();
  }

  Widget _productSearchField() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        final showDropdown =
            _showProductDropdown && _productController.text.trim().length >= 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldHeading('Product / Service'),
            SizedBox(height: context.hp(0.65)),
            TextFormField(
              controller: _productController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: _onProductSearchChanged,
              onTap: () {
                if (_productController.text.trim().length >= 3) {
                  setState(() => _showProductDropdown = true);
                }
              },
              decoration: _inputDecoration(
                hint: 'Search or enter product / service',
                icon: Icons.inventory_2_outlined,
                suffix: provider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(13),
                        child: SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _productController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _productController.clear();
                          context.read<ProductsProvider>().clearProducts();
                          setState(() {
                            _showProductDropdown = false;
                            _isProductSelected = false;
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
            ),
            if (showDropdown) ...[
              SizedBox(height: context.hp(0.8)),
              _buildProductDropdown(provider),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProductDropdown(ProductsProvider provider) {
    final products = provider.products;

    if (provider.isLoading && products.isEmpty) {
      return _dropdownMessage(
        const CircularProgressIndicator(strokeWidth: 2),
        'Searching products...',
      );
    }

    if (products.isEmpty) {
      return _dropdownMessage(
        const Icon(Icons.search_off_outlined, color: _label),
        'No product found. You can use '
        '"${_productController.text.trim()}" as a new product.',
      );
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: context.hp(32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: context.hp(0.5)),
        itemCount: products.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
        itemBuilder: (context, index) {
          final product = products[index];

          return ListTile(
            dense: true,
            leading: const Icon(Icons.inventory_2_outlined, color: _primary),
            title: Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: product.companyName.isNotEmpty
                ? Text(
                    product.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _selectProduct(product),
          );
        },
      ),
    );
  }

  Widget _dropdownMessage(Widget leading, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(3.5)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          SizedBox(width: 22, height: 22, child: Center(child: leading)),
          SizedBox(width: context.wp(3)),
          Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildInvoiceItems() {
    return _sectionCard(
      title: 'Invoice Items',
      icon: Icons.inventory_2_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _productSearchField(),
          SizedBox(height: context.hp(1.5)),

          _responsiveFields([
            _field(
              controller: _hsnController,
              heading: 'HSN Code',
              hint: 'Enter HSN code',
              icon: Icons.qr_code_2_outlined,
            ),
            _field(
              controller: _quantityController,
              heading: 'Quantity',
              hint: '1',
              icon: Icons.production_quantity_limits_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _field(
              controller: _priceController,
              heading: 'Rate (₹)',
              hint: '0.00',
              icon: Icons.currency_rupee_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _field(
              controller: _gstController,
              heading: 'GST %',
              hint: '12',
              icon: Icons.percent_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ]),

          SizedBox(height: context.hp(1.5)),

          // Single Add Item button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Add Item',
                style: AppTextStyles.button.copyWith(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),

          if (_items.isNotEmpty) ...[
            SizedBox(height: context.hp(2)),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Added Items',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: _heading,
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(2.5),
                    vertical: context.hp(0.4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.hp(1)),

            _ItemsList(items: _items, onRemove: _removeItem),
          ] else ...[
            SizedBox(height: context.hp(1.5)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: context.hp(2.2),
                horizontal: context.wp(3),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: _primary,
                      size: 22,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    'No items added yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _heading,
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.hp(0.4)),
                  Text(
                    'Enter product details above and tap Add Item.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _label,
                      fontSize: context.sp(11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addItem() {
    FocusScope.of(context).unfocus();

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

      _showProductDropdown = false;
      _isProductSelected = false;
    });

    context.read<ProductsProvider>().clearProducts();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Widget _buildPaymentAndBank() {
    return Column(
      children: [
        _sectionCard(
          title: 'Payment Details',
          icon: Icons.payments_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldHeading('Payment Status'),
              SizedBox(height: context.hp(0.65)),
              DropdownButtonFormField<String>(
                initialValue: _paymentStatus,
                validator: (value) => value == null || value.isEmpty
                    ? 'Payment status is required'
                    : null,
                decoration: _inputDecoration(
                  hint: 'Select payment status',
                  icon: Icons.payments_outlined,
                ),
                items: const [
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _paymentStatus = value);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: context.hp(1.5)),
        _sectionCard(
          title: 'Bank Details',
          icon: Icons.account_balance_outlined,
          child: _responsiveThreeFields([
            _field(
              controller: _bankNameController,
              heading: 'Bank Name',
              hint: 'Bank and branch name',
              icon: Icons.account_balance_outlined,
              validator: _requiredValidator,
            ),
            _field(
              controller: _accountNumberController,
              heading: 'Account Number',
              hint: 'Account number',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              validator: _requiredValidator,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _field(
              controller: _ifscController,
              heading: 'IFSC Code',
              hint: 'IFSC code',
              icon: Icons.code_outlined,
              validator: _requiredValidator,
            ),
          ]),
        ),
      ],
    );
  }

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + (item['amount'] as double));

  double get _totalGst => _items.fold(0, (sum, item) {
    final amount = item['amount'] as double;
    final gst = item['gstPercent'] as double;
    return sum + amount * gst / 100;
  });

  double get _sgst => _totalGst / 2;
  double get _cgst => _totalGst / 2;
  double get _beforeRoundOff => _subtotal + _totalGst;
  double get _roundOff => _beforeRoundOff.roundToDouble() - _beforeRoundOff;
  double get _grandTotal => _beforeRoundOff + _roundOff;

  Widget _buildInvoiceSummary() {
    return _sectionCard(
      title: 'Invoice Summary',
      icon: Icons.summarize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _totalRow('Subtotal', _subtotal),
          _totalRow('SGST', _sgst),
          _totalRow('CGST', _cgst),
          _totalRow('Round Off', _roundOff),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: _border),
          ),

          _totalRow('Total Amount', _grandTotal, isGrandTotal: true),

          SizedBox(height: context.hp(1.5)),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.wp(3.5)),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD5E7FC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee_rounded,
                      size: 18,
                      color: _primary,
                    ),
                    SizedBox(width: context.wp(1.5)),
                    Text(
                      'Amount in Words',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.hp(0.6)),
                Text(
                  _amountInWords(_grandTotal),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _heading,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String title, double amount, {bool isGrandTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.hp(0.65)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: isGrandTotal
                  ? AppTextStyles.titleMedium.copyWith(
                      color: _heading,
                      fontWeight: FontWeight.w800,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      color: _label,
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ),
          SizedBox(width: context.wp(3)),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: isGrandTotal
                ? AppTextStyles.titleLarge.copyWith(
                    color: _primary,
                    fontWeight: FontWeight.w800,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: _heading,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) return;

    setState(() => _invoiceDate = selectedDate);
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldHeading('Invoice Date'),
        SizedBox(height: context.hp(0.65)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(11),
            child: InputDecorator(
              decoration: _inputDecoration(
                hint: 'Select invoice date',
                icon: Icons.calendar_today_outlined,
              ),
              child: Text(
                _formatDate(_invoiceDate),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF172746),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldHeading(String title) {
    return Padding(
      padding: EdgeInsets.only(left: context.wp(0.5)),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: _label,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySmall.copyWith(
        color: const Color(0xFF9AA6B8),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: context.sp(15), color: const Color(0xFF53647C)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.wp(3),
        vertical: context.hp(1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }

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
        SizedBox(height: context.hp(0.65)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF172746),
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(hint: hint ?? '', icon: icon),
        ),
      ],
    );
  }

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

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  bool _financialYearValidator(String value) {
    return RegExp(r'^\d{4}-\d{4}$').hasMatch(value.trim());
  }

  bool _validateControllers(List<TextEditingController> controllers) {
    return controllers.every((controller) => controller.text.trim().isNotEmpty);
  }

  bool _validateSellerDetails() {
    if (!_validateControllers([
      _sellerNameController,
      _sellerAddressController,
      _sellerPhoneController,
      _sellerEmailController,
    ])) {
      _showMessage('Please complete all required seller details');
      return false;
    }

    final phoneError = _phoneValidator(_sellerPhoneController.text);
    if (phoneError != null) {
      _showMessage(phoneError);
      return false;
    }

    final emailError = _emailValidator(_sellerEmailController.text);
    if (emailError != null) {
      _showMessage(emailError);
      return false;
    }

    return true;
  }

  bool _validateInvoiceDetails() {
    if (_invoiceNumberController.text.trim().isEmpty) {
      _showMessage('Please enter invoice number');
      return false;
    }
    if (_financialYearController.text.trim().isEmpty ||
        !_financialYearValidator(_financialYearController.text)) {
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

  bool _validateBillTo() {
    if (_customerNameController.text.trim().isEmpty) {
      _showMessage('Please enter customer / company name');
      return false;
    }
    if (_customerAddressController.text.trim().isEmpty) {
      _showMessage('Please enter customer address');
      return false;
    }

    final phoneError = _phoneValidator(_customerPhoneController.text);
    if (phoneError != null) {
      _showMessage(phoneError);
      return false;
    }

    final emailError = _emailValidator(_customerEmailController.text);
    if (emailError != null) {
      _showMessage(emailError);
      return false;
    }
    return true;
  }

  bool _validateItems() {
    if (_items.isEmpty) {
      _showMessage('Please add at least one invoice item');
      return false;
    }
    return true;
  }

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

  bool _validateAllSteps() {
    return _validateSellerDetails() &&
        _validateInvoiceDetails() &&
        _validateBillTo() &&
        _validateItems() &&
        _validatePaymentAndBank();
  }

  void _previewInvoice() {
    if (!_validateAllSteps()) return;

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

  void _showMessage(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _amountInWords(double amount) {
    final whole = amount.round();
    if (whole == 0) return 'Zero Rupees Only';

    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String underThousand(int number) {
      if (number == 0) return '';
      if (number < 20) return ones[number];

      if (number < 100) {
        return '${tens[number ~/ 10]}'
            '${number % 10 == 0 ? '' : ' ${ones[number % 10]}'}';
      }

      return '${ones[number ~/ 100]} Hundred'
          '${number % 100 == 0 ? '' : ' ${underThousand(number % 100)}'}';
    }

    String convert(int number) {
      if (number == 0) return 'Zero';

      final parts = <String>[];
      final crore = number ~/ 10000000;
      number %= 10000000;
      final lakh = number ~/ 100000;
      number %= 100000;
      final thousand = number ~/ 1000;
      number %= 1000;

      if (crore > 0) {
        parts.add('${underThousand(crore)} Crore');
      }
      if (lakh > 0) {
        parts.add('${underThousand(lakh)} Lakh');
      }
      if (thousand > 0) {
        parts.add('${underThousand(thousand)} Thousand');
      }
      if (number > 0) {
        parts.add(underThousand(number));
      }

      return parts.join(' ');
    }

    return '${convert(whole)} Rupees Only';
  }
}

class _ItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int index) onRemove;

  const _ItemsList({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];

        final name = item['name'] as String? ?? '';
        final hsn = item['hsnCode'] as String? ?? '';
        final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
        final price = (item['price'] as num?)?.toDouble() ?? 0;
        final gst = (item['gstPercent'] as num?)?.toDouble() ?? 0;
        final amount = (item['amount'] as num?)?.toDouble() ?? 0;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: context.hp(1)),
          padding: EdgeInsets.all(context.wp(3)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _itemBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF234D80).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _itemPrimary,
                          fontSize: context.sp(13),
                          fontWeight: FontWeight.w800,
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
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: _itemHeading,
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (hsn.isNotEmpty) ...[
                          SizedBox(height: context.hp(0.3)),
                          Text(
                            'HSN: $hsn',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _itemLabel,
                              fontSize: context.sp(11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: context.wp(1)),

                  IconButton(
                    onPressed: () => onRemove(index),
                    tooltip: 'Remove item',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 21,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(1.2)),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wp(2.5),
                  vertical: context.hp(1),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _itemDetail(
                        context,
                        label: 'QTY',
                        value: _formatQuantity(quantity),
                      ),
                    ),
                    Expanded(
                      child: _itemDetail(
                        context,
                        label: 'RATE',
                        value: '₹${price.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _itemDetail(
                        context,
                        label: 'GST',
                        value: '${_formatQuantity(gst)}%',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(1.2)),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item Amount',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _itemLabel,
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: _itemPrimary,
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _itemDetail(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: _itemLabel,
            fontSize: context.sp(9),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.hp(0.3)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: _itemHeading,
            fontSize: context.sp(11),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatQuantity(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

const Color _itemPrimary = Color(0xFF0866D9);
const Color _itemHeading = Color(0xFF102A68);
const Color _itemLabel = Color(0xFF526079);
const Color _itemBorder = Color(0xFFDCE5F0);
