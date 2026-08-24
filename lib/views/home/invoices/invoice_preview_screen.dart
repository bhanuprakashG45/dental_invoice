import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = invoice['items'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Preview')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.wp(4)),
        child: Column(
          children: [
            // Invoice
            Card(
              child: Padding(
                padding: EdgeInsets.all(context.wp(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DENTAL INVOICE',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Dental Clinic',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          invoice['invoiceNumber'],
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 16),

                    // Customer
                    Text('Bill To', style: AppTextStyles.titleMedium),

                    const SizedBox(height: 6),

                    Text(
                      invoice['customerName'],
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if ((invoice['customerPhone'] as String).isNotEmpty)
                      Text(
                        invoice['customerPhone'],
                        style: AppTextStyles.bodyMedium,
                      ),

                    if ((invoice['customerEmail'] as String).isNotEmpty)
                      Text(
                        invoice['customerEmail'],
                        style: AppTextStyles.bodyMedium,
                      ),

                    if ((invoice['customerAddress'] as String).isNotEmpty)
                      Text(
                        invoice['customerAddress'],
                        style: AppTextStyles.bodyMedium,
                      ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${_formatDate(invoice['date'])}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          invoice['paymentStatus'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: invoice['paymentStatus'] == 'Paid'
                                ? AppColors.success
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 12),

                    // Items
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Item', style: AppTextStyles.titleMedium),
                        ),
                        Expanded(
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Amount',
                            textAlign: TextAlign.end,
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item['name'],
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${item['quantity']}',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${item['total'].toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    const Divider(),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: AppTextStyles.titleLarge),
                        Text(
                          '₹${(invoice['total'] as double).toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: context.hp(2)),

            // Print Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Generate PDF and print
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print Invoice', style: AppTextStyles.button),
              ),
            ),

            SizedBox(height: context.hp(1.5)),

            // Bluetooth Print
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Bluetooth printing
                },
                icon: const Icon(Icons.bluetooth),
                label: const Text('Print via Bluetooth'),
              ),
            ),

            SizedBox(height: context.hp(3)),
          ],
        ),
      ),
    );
  }
}
