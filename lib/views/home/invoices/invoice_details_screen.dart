import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? invoiceData;
  final VoidCallback? onPrevious;
  final ValueChanged<Map<String, dynamic>>? onNext;

  const InvoiceDetailsScreen({
    super.key,
    this.invoiceData,
    this.onPrevious,
    this.onNext,
  });

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _invoiceNoController;
  late final TextEditingController _financialYearController;
  late final TextEditingController _invoiceDateController;
  late final TextEditingController _dispatchedThroughController;
  late final TextEditingController _referenceController;
  late final TextEditingController _salespersonController;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final data = widget.invoiceData ?? {};

    _invoiceNoController = TextEditingController(
      text: data['invoiceNo']?.toString() ?? '',
    );

    _financialYearController = TextEditingController(
      text: data['financialYear']?.toString() ?? _getFinancialYear(),
    );

    final existingDate = data['invoiceDate']?.toString();

    if (existingDate != null && existingDate.isNotEmpty) {
      final parsedDate = DateTime.tryParse(existingDate);

      if (parsedDate != null) {
        _selectedDate = parsedDate;
      }
    }

    _invoiceDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_selectedDate),
    );

    _dispatchedThroughController = TextEditingController(
      text: data['dispatchedThrough']?.toString() ?? '',
    );

    _referenceController = TextEditingController(
      text: data['reference']?.toString() ?? '',
    );

    _salespersonController = TextEditingController(
      text: data['salesperson']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _invoiceNoController.dispose();
    _financialYearController.dispose();
    _invoiceDateController.dispose();
    _dispatchedThroughController.dispose();
    _referenceController.dispose();
    _salespersonController.dispose();

    super.dispose();
  }

  String _getFinancialYear() {
    final now = DateTime.now();

    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final endYear = startYear + 1;

    return '$startYear-${endYear.toString().substring(2)}';
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
      _invoiceDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = <String, dynamic>{
      ...?widget.invoiceData,

      'invoiceNo': _invoiceNoController.text.trim(),
      'financialYear': _financialYearController.text.trim(),

      // API-friendly ISO date.
      'invoiceDate': _selectedDate.toIso8601String(),

      'dispatchedThrough': _dispatchedThroughController.text.trim(),

      'reference': _referenceController.text.trim(),

      'salesperson': _salespersonController.text.trim(),
    };

    widget.onNext?.call(data);
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.grey100,
        foregroundColor: AppColors.primary,
        centerTitle: false,
        title: Text('Invoice Details', style: AppTextStyles.headlineLarge),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(5),
                    vertical: context.hp(1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      SizedBox(height: context.hp(2.5)),

                      _buildSectionTitle(
                        'Invoice Information',
                        Icons.receipt_long_outlined,
                      ),

                      SizedBox(height: context.hp(1.5)),

                      _buildTextField(
                        controller: _invoiceNoController,
                        label: 'Invoice Number',
                        hint: 'Enter invoice number',
                        prefixIcon: Icons.receipt_outlined,
                        validator: (value) =>
                            _requiredValidator(value, 'Invoice number'),
                      ),

                      SizedBox(height: context.hp(1.8)),

                      _buildTextField(
                        controller: _financialYearController,
                        label: 'Financial Year',
                        hint: 'e.g. 2026-27',
                        prefixIcon: Icons.calendar_month_outlined,
                        validator: (value) =>
                            _requiredValidator(value, 'Financial year'),
                      ),

                      SizedBox(height: context.hp(1.8)),

                      _buildDateField(),

                      SizedBox(height: context.hp(2.5)),

                      _buildSectionTitle(
                        'Dispatch & Reference',
                        Icons.local_shipping_outlined,
                      ),

                      SizedBox(height: context.hp(1.5)),

                      _buildTextField(
                        controller: _dispatchedThroughController,
                        label: 'Dispatched Through',
                        hint: 'e.g. Courier, Transport, Self',
                        prefixIcon: Icons.local_shipping_outlined,
                      ),

                      SizedBox(height: context.hp(1.8)),

                      _buildTextField(
                        controller: _referenceController,
                        label: 'Reference',
                        hint: 'Enter reference number',
                        prefixIcon: Icons.link_outlined,
                      ),

                      SizedBox(height: context.hp(2.5)),

                      _buildSectionTitle(
                        'Sales Information',
                        Icons.person_outline,
                      ),

                      SizedBox(height: context.hp(1.5)),

                      _buildTextField(
                        controller: _salespersonController,
                        label: 'Salesperson',
                        hint: 'Enter salesperson name',
                        prefixIcon: Icons.person_outline,
                      ),

                      SizedBox(height: context.hp(3)),
                    ],
                  ),
                ),
              ),

              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wp(4.5)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: context.wp(12),
            height: context.wp(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: context.sp(24),
            ),
          ),

          SizedBox(width: context.wp(3.5)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Details',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.hp(0.4)),
                Text(
                  'Enter the basic information for this invoice.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: context.sp(19), color: AppColors.primary),
        SizedBox(width: context.wp(2)),
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),

        SizedBox(height: context.hp(0.8)),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey500.withValues(alpha: 0.65),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.grey500,
              size: context.sp(20),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.wp(4),
              vertical: context.hp(1.8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Date',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),

        SizedBox(height: context.hp(0.8)),

        TextFormField(
          controller: _invoiceDateController,
          readOnly: true,
          onTap: _selectDate,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Select invoice date',
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.grey500,
              size: context.sp(20),
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey500,
              size: context.sp(22),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.wp(4),
              vertical: context.hp(1.8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.wp(4),
        context.hp(1.5),
        context.wp(4),
        context.hp(1.5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onPrevious ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, context.hp(6)),
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          SizedBox(width: context.wp(3)),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, context.hp(6)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
