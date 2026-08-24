import 'package:flutter/material.dart';
import 'package:invoice/core/constants/app_colors.dart';
import 'package:invoice/core/constants/app_responsive.dart';
import 'package:invoice/core/theme/app_textstyles.dart';
import 'package:invoice/views/home/invoices/create_invoice_screen.dart';
import 'package:invoice/views/home/invoices/invoice_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> products = [
    {
      'name': 'Dental Cleaning',
      'price': 800.0,
      'icon': Icons.cleaning_services_outlined,
    },
    {
      'name': 'Root Canal',
      'price': 3500.0,
      'icon': Icons.medical_services_outlined,
    },
    {
      'name': 'Tooth Filling',
      'price': 1200.0,
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'name': 'Tooth Extraction',
      'price': 1500.0,
      'icon': Icons.healing_outlined,
    },
    {
      'name': 'Dental Crown',
      'price': 5000.0,
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'name': 'Teeth Whitening',
      'price': 2500.0,
      'icon': Icons.auto_awesome_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dental Invoice'),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Products', style: AppTextStyles.titleLarge),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.hp(1)),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: context.wp(2.5),
                mainAxisSpacing: context.hp(1.5),
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return _ProductCard(
                  name: product['name'],
                  price: product['price'],
                  icon: product['icon'],
                );
              },
            ),

            Text('Invoice History', style: AppTextStyles.titleLarge),

            SizedBox(height: context.hp(2)),

            const _AllInvoicesCard(),

            SizedBox(height: context.hp(10)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Invoice', style: AppTextStyles.button),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final IconData icon;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.wp(2.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.wp(10),
              height: context.wp(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: context.wp(5)),
            ),

            const Spacer(),

            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: context.sp(13),
              ),
            ),

            SizedBox(height: context.hp(0.5)),

            Text(
              '₹${price.toStringAsFixed(0)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllInvoicesCard extends StatelessWidget {
  const _AllInvoicesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 6),
            color: AppColors.invoice.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceHistoryScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(context.wp(5)),
          child: Row(
            children: [
              // Icon
              Container(
                width: context.wp(15),
                height: context.wp(15),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: context.wp(7),
                ),
              ),

              SizedBox(width: context.wp(4)),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Invoices', style: AppTextStyles.titleLarge),

                    SizedBox(height: context.hp(0.7)),

                    Text(
                      'View, manage and track all your invoices '
                      'in one place.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),

                    SizedBox(height: context.hp(1.2)),
                  ],
                ),
              ),

              SizedBox(width: context.wp(2)),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.grey500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
