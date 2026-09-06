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
      'color': Color(0xFF4F8CFF),
      'lightColor': Color(0xFFEAF2FF),
    },
    {
      'name': 'Root Canal',
      'price': 3500.0,
      'icon': Icons.medical_services_outlined,
      'color': Color(0xFF9B6BFF),
      'lightColor': Color(0xFFF2ECFF),
    },
    {
      'name': 'Tooth Filling',
      'price': 1200.0,
      'icon': Icons.health_and_safety_outlined,
      'color': Color(0xFF20B486),
      'lightColor': Color(0xFFE6F8F2),
    },
    {
      'name': 'Tooth Extraction',
      'price': 1500.0,
      'icon': Icons.healing_outlined,
      'color': Color(0xFFFF8A4C),
      'lightColor': Color(0xFFFFF0E8),
    },
    {
      'name': 'Dental Crown',
      'price': 5000.0,
      'icon': Icons.health_and_safety_outlined,
      'color': Color(0xFFFFB020),
      'lightColor': Color(0xFFFFF6DE),
    },
    {
      'name': 'Teeth Whitening',
      'price': 2500.0,
      'icon': Icons.auto_awesome_outlined,
      'color': Color(0xFFEC5C9A),
      'lightColor': Color(0xFFFFEAF3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      body: Column(
        children: [
          SizedBox(height: context.hp(1)),
          Container(
            width: double.infinity,
            color: const Color(0xFFF7F8FC),
            padding: EdgeInsets.fromLTRB(
              context.wp(5),
              context.hp(3),
              context.wp(5),
              context.hp(2),
            ),
            child: const _WelcomeHeader(),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                context.wp(5),
                context.hp(1),
                context.wp(5),
                context.hp(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _QuickActionCard(),

                  SizedBox(height: context.hp(3)),

                  _SectionHeader(
                    title: 'Invoice History',
                    subtitle: 'View and manage your invoices',
                    actionText: 'See All',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InvoiceHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: context.hp(1.5)),

                  const _InvoiceHistoryCard(),

                  SizedBox(height: context.hp(3)),

                  _SectionHeader(
                    title: 'Products',
                    subtitle: 'Choose a product to manage stock',
                    actionText: 'View All',
                    onPressed: () {},
                  ),

                  const _ProductsGrid(),
                ],
              ),
            ),
          ),
        ],
      ),

      // floatingActionButton: const _CreateInvoiceButton(),
    );
  }
}

// -----------------------------------------------------------------------------
// WELCOME HEADER - FIXED
// -----------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Afternoon 👋',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey500,
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                'Welcome back!',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: context.sp(25),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: context.wp(3)),

        Container(
          width: context.wp(13),
          height: context.wp(13),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: AppColors.grey700,
            size: context.wp(6),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// QUICK ACTION
// -----------------------------------------------------------------------------

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.wp(4.5)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: context.wp(14),
                height: context.wp(14),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.white,
                  size: context.wp(7),
                ),
              ),

              SizedBox(width: context.wp(4)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Invoice',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(16),
                      ),
                    ),

                    SizedBox(height: context.hp(0.4)),

                    Text(
                      'Generate an invoice for your customer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.78),
                        fontSize: context.sp(11),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: context.wp(9),
                height: context.wp(9),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white,
                  size: context.wp(4.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION HEADER
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onPressed;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(20),
                ),
              ),

              SizedBox(height: context.hp(0.35)),

              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey700,
                  fontSize: context.sp(11.5),
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(3),
              vertical: context.hp(0.8),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              actionText,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: context.sp(11.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCTS GRID
// -----------------------------------------------------------------------------

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: HomeScreen.products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.wp(3.5),
        mainAxisSpacing: context.hp(1.8),
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        final product = HomeScreen.products[index];

        return _ProductCard(
          name: product['name'],
          price: product['price'],
          icon: product['icon'],
          color: product['color'],
          lightColor: product['lightColor'],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// PRODUCT CARD
// -----------------------------------------------------------------------------

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.all(context.wp(4)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: context.wp(14),
                    height: context.wp(14),
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(icon, color: color, size: context.wp(7)),
                  ),

                  Container(
                    width: context.wp(8),
                    height: context.wp(8),
                    decoration: BoxDecoration(
                      color: lightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: color,
                      size: context.wp(4),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: context.sp(14),
                ),
              ),

              SizedBox(height: context.hp(0.7)),

              Row(
                children: [
                  Text(
                    '₹',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(13),
                    ),
                  ),

                  SizedBox(width: context.wp(0.5)),

                  Text(
                    price.toStringAsFixed(0),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(14),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(1)),

              Container(
                width: context.wp(9),
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INVOICE HISTORY CARD

class _InvoiceHistoryCard extends StatelessWidget {
  const _InvoiceHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceHistoryScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.wp(4)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF4F7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // ----------------------------------------------------------------
              // COLORFUL ICON
              // ----------------------------------------------------------------
              Container(
                width: context.wp(16),
                height: context.wp(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.65),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: context.wp(6),
                        height: context.wp(6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.white,
                      size: context.wp(7),
                    ),
                  ],
                ),
              ),

              SizedBox(width: context.wp(4)),

              // ----------------------------------------------------------------
              // CONTENT
              // ----------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'All Invoices',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(19),
                            ),
                          ),
                        ),

                        SizedBox(width: context.wp(1.5)),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.wp(2),
                            vertical: context.hp(0.35),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Manage',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: const Color(0xFF20A66A),
                              fontWeight: FontWeight.w700,
                              fontSize: context.sp(9),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.hp(0.6)),

                    Text(
                      'View and manage all your invoices',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                        fontSize: context.sp(11.5),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: context.wp(2)),

              // ----------------------------------------------------------------
              // ARROW BUTTON
              // ----------------------------------------------------------------
              Container(
                width: context.wp(10),
                height: context.wp(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: context.wp(4.5),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateInvoiceButton extends StatelessWidget {
  const _CreateInvoiceButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text(
        'Create Invoice',
        style: AppTextStyles.button.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: context.sp(13),
        ),
      ),
    );
  }
}
