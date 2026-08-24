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

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();

  final _productController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  String _paymentStatus = 'Paid';

  final List<Map<String, dynamic>> _items = [];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _productController.dispose();
    _quantityController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  void _addItem() {
    final product = _productController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    if (product.isEmpty) {
      _showMessage('Please enter product name');
      return;
    }

    if (quantity <= 0) {
      _showMessage('Please enter a valid quantity');
      return;
    }

    if (price <= 0) {
      _showMessage('Please enter a valid price');
      return;
    }

    setState(() {
      _items.add({
        'name': product,
        'quantity': quantity,
        'price': price,
        'total': quantity * price,
      });

      _productController.clear();
      _quantityController.text = '1';
      _priceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _grandTotal {
    return _items.fold(0, (sum, item) => sum + (item['total'] as double));
  }

  void _previewInvoice() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      _showMessage('Please add at least one item');
      return;
    }

    final invoice = {
      'invoiceNumber': 'INV-${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now(),
      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim(),
      'customerEmail': _customerEmailController.text.trim(),
      'customerAddress': _customerAddressController.text.trim(),
      'paymentStatus': _paymentStatus,
      'items': List<Map<String, dynamic>>.from(_items),
      'total': _grandTotal,
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: invoice)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer
              Text('Customer Details', style: AppTextStyles.titleLarge),

              SizedBox(height: context.hp(1.5)),

              TextFormField(
                controller: _customerNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: context.hp(1.5)),

              TextFormField(
                controller: _customerPhoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: context.hp(1.5)),

              TextFormField(
                controller: _customerEmailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              SizedBox(height: context.hp(1.5)),

              TextFormField(
                controller: _customerAddressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter customer address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              SizedBox(height: context.hp(3)),

              // Items
              Text('Invoice Items', style: AppTextStyles.titleLarge),

              SizedBox(height: context.hp(1.5)),

              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(
                  labelText: 'Product / Service',
                  hintText: 'Example: Dental Cleaning',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),

              SizedBox(height: context.hp(1.5)),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  SizedBox(width: context.wp(3)),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(1.5)),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Item'),
                ),
              ),

              SizedBox(height: context.hp(2)),

              if (_items.isNotEmpty)
                _ItemsList(items: _items, onRemove: _removeItem),

              SizedBox(height: context.hp(2)),

              // Payment
              Text('Payment Status', style: AppTextStyles.titleLarge),

              SizedBox(height: context.hp(1)),

              DropdownButtonFormField<String>(
                initialValue: _paymentStatus,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payments_outlined),
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

              SizedBox(height: context.hp(3)),

              // Total
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.wp(4)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total', style: AppTextStyles.titleMedium),
                    Text(
                      '₹${_grandTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(3)),

              SizedBox(
                width: double.infinity,
                height: 52,
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

        return Card(
          margin: EdgeInsets.only(bottom: context.hp(1)),
          child: Padding(
            padding: EdgeInsets.all(context.wp(3)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${item['quantity']} × ₹${item['price'].toStringAsFixed(2)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item['total'].toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
