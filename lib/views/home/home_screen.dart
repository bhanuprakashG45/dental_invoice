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
      'stock': 150,
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF2563EB),
      'lightColor': Color(0xFFEFF6FF),
    },
    {
      'name': 'Root Canal',
      'price': 3500.0,
      'stock': 80,
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF7C3AED),
      'lightColor': Color(0xFFF5F3FF),
    },
    {
      'name': 'Tooth Filling',
      'price': 1200.0,
      'stock': 200,
      'icon': Icons.health_and_safety_rounded,
      'color': Color(0xFF059669),
      'lightColor': Color(0xFFECFDF5),
    },
    {
      'name': 'Tooth Extraction',
      'price': 4500.0,
      'stock': 60,
      'icon': Icons.medical_information_rounded,
      'color': Color(0xFFEA580C),
      'lightColor': Color(0xFFFFF7ED),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDCEB),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EAF4), Color(0xFFEAF1F8), Color(0xFFF0F4F9)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.wp(5),
              0,
              context.wp(5),
              context.hp(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopBar(),
                SizedBox(height: context.hp(0.5)),

                const _QuickActionCard(),
                SizedBox(height: context.hp(2.5)),
                _SectionHeader(
                  icon: Icons.receipt_long_rounded,
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
                SizedBox(height: context.hp(2.5)),
                _SectionHeader(
                  icon: Icons.shopping_bag_outlined,
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
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final double imageWidth = context.wp(60);
    final double imageHeight = context.hp(23);
    final double profileSize = context.wp(11);

    return SizedBox(
      height: imageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: context.hp(0),
            right: -context.wp(5),
            width: imageWidth,
            height: imageHeight - context.hp(1),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(300),
              ),
              child: Image.asset(
                'assets/images/homedental.png',
                width: imageWidth,
                height: imageHeight - context.hp(1),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: context.hp(2),
            child: Image.asset(
              'assets/images/login_img.png',
              width: context.wp(26),
              height: context.hp(11),
              fit: BoxFit.contain,
            ),
          ),

          // Profile icon with sufficient top spacing.
          Positioned(
            top: context.hp(3),
            right: context.wp(3),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.14),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // Add profile navigation here.
                },
                child: SizedBox(
                  width: profileSize,
                  height: profileSize,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: const Color(0xFF1E293B),
                    size: context.wp(6),
                  ),
                ),
              ),
            ),
          ),

          Positioned(top: context.hp(12), left: 0, child: _WelcomeHeader()),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Good Afternoon ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(13),
              ),
            ),
            const Text('👋', style: TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          'Welcome back!',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: context.sp(24),
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          'Manage your invoices and products easily.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey700.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontSize: context.sp(11),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
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
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4.5),
            vertical: context.wp(4.5),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                blurRadius: 16,
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
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.note_add_rounded,
                    color: Colors.white,
                    size: context.wp(7),
                  ),
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
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(15),
                      ),
                    ),
                    SizedBox(height: context.hp(0.3)),
                    Text(
                      'Generate an invoice for your customer quickly and easily.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                        fontSize: context.sp(10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.wp(2)),
              Container(
                width: context.wp(9),
                height: context.wp(9),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: const Color(0xFF2563EB),
                    size: context.wp(4.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onPressed;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF0F172A), size: context.wp(5.5)),
        SizedBox(width: context.wp(2.5)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: context.sp(16.5),
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey700,
                  fontWeight: FontWeight.w500,
                  fontSize: context.sp(10),
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
              vertical: context.hp(0.6),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  actionText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                    fontSize: context.sp(10.5),
                  ),
                ),
                SizedBox(width: context.wp(1)),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: const Color(0xFF2563EB),
                  size: context.wp(3.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceHistoryCard extends StatelessWidget {
  const _InvoiceHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: context.wp(13),
                height: context.wp(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF2563EB),
                    size: context.wp(6.5),
                  ),
                ),
              ),
              SizedBox(width: context.wp(3.5)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Invoices',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(14),
                      ),
                    ),
                    SizedBox(height: context.hp(0.3)),
                    Text(
                      'View and manage all your invoices in one place.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w500,
                        fontSize: context.sp(10),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: context.wp(8.5),
                height: context.wp(8.5),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFF2563EB),
                    size: context.wp(3.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final product = HomeScreen.products[index];

        return _ProductCard(
          name: product['name'],
          price: product['price'],
          stock: product['stock'],
          icon: product['icon'],
          color: product['color'],
          lightColor: product['lightColor'],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final int stock;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.stock,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
          // );
        },
        child: Container(
          padding: EdgeInsets.all(context.wp(3.5)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: context.wp(11),
                    height: context.wp(11),
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(icon, color: color, size: context.wp(6)),
                    ),
                  ),
                  Container(
                    width: context.wp(8),
                    height: context.wp(8),
                    decoration: BoxDecoration(
                      color: lightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: color,
                        size: context.wp(4),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(12.5),
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: context.hp(0.3)),
                  Text(
                    '₹ ${price.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(13),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: context.hp(0.8),
                  horizontal: context.wp(2.5),
                ),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: context.wp(3.5),
                      color: color,
                    ),
                    SizedBox(width: context.wp(1.5)),
                    Text(
                      'Stock: ',
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontWeight: FontWeight.w500,
                        fontSize: context.sp(10),
                      ),
                    ),
                    Text(
                      '$stock',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:invoice/core/constants/app_colors.dart';
// import 'package:invoice/core/constants/app_responsive.dart';
// import 'package:invoice/core/theme/app_textstyles.dart';
// import 'package:invoice/views/home/invoices/create_invoice_screen.dart';
// import 'package:invoice/views/home/invoices/invoice_history_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   static const List<Map<String, dynamic>> products = [
//     {
//       'name': 'Dental Cleaning',
//       'brand': 'SmileCare',
//       'price': 800.0,
//       'icon': Icons.cleaning_services_rounded,
//       'color': Color(0xFF2563EB),
//       'lightColor': Color(0xFFEFF6FF),
//     },
//     {
//       'name': 'Root Canal',
//       'brand': 'DentalPro',
//       'price': 3500.0,
//       'icon': Icons.medical_services_rounded,
//       'color': Color(0xFF7C3AED),
//       'lightColor': Color(0xFFF5F3FF),
//     },
//     {
//       'name': 'Tooth Filling',
//       'brand': 'DentCare',
//       'price': 1200.0,
//       'icon': Icons.health_and_safety_rounded,
//       'color': Color(0xFF059669),
//       'lightColor': Color(0xFFECFDF5),
//     },
//     {
//       'name': 'Tooth Extraction',
//       'brand': 'OralCare',
//       'price': 1500.0,
//       'icon': Icons.medical_information_rounded,
//       'color': Color(0xFFEA580C),
//       'lightColor': Color(0xFFFFF7ED),
//     },
//     {
//       'name': 'Dental Crown',
//       'brand': 'PremiumDent',
//       'price': 5000.0,
//       'icon': Icons.diamond_rounded,
//       'color': Color(0xFFCA8A04),
//       'lightColor': Color(0xFFFEFCE8),
//     },
//     {
//       'name': 'Teeth Whitening',
//       'brand': 'BrightSmile',
//       'price': 2500.0,
//       'icon': Icons.auto_awesome_rounded,
//       'color': Color(0xFFDB2777),
//       'lightColor': Color(0xFFFDF2F8),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF4F8CFF),
//               Color(0xFF8FB7FF),
//               Color(0xFFEAF2FF),
//               Color(0xFFF7F8FC),
//             ],
//             stops: [0.0, 0.18, 0.42, 0.75],
//           ),
//         ),
//         child: SafeArea(
//           bottom: false,
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: EdgeInsets.fromLTRB(
//               context.wp(5),
//               context.hp(2.2),
//               context.wp(5),
//               context.hp(4),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const _WelcomeHeader(),

//                 SizedBox(height: context.hp(2.8)),

//                 const _QuickActionCard(),

//                 SizedBox(height: context.hp(3)),

//                 _SectionHeader(
//                   title: 'Products',
//                   subtitle: 'Choose a service to create an invoice',
//                   actionText: 'View All',
//                   onPressed: () {},
//                 ),

//                 SizedBox(height: context.hp(1.6)),

//                 const _ProductsGrid(),

//                 SizedBox(height: context.hp(3)),

//                 _SectionHeader(
//                   title: 'Invoice History',
//                   subtitle: 'Manage your recent invoices',
//                   actionText: 'See All',
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const InvoiceHistoryScreen(),
//                       ),
//                     );
//                   },
//                 ),

//                 SizedBox(height: context.hp(1.6)),

//                 const _InvoiceHistoryCard(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _WelcomeHeader extends StatelessWidget {
//   const _WelcomeHeader();

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome back!',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.titleLarge.copyWith(
//                   fontWeight: FontWeight.w800,
//                   fontSize: context.sp(22),
//                   height: 1.1,
//                 ),
//               ),
//               SizedBox(height: context.hp(0.45)),
//               Text(
//                 'Manage your invoices with ease',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.grey700.withValues(alpha: 0.82),
//                   fontWeight: FontWeight.w500,
//                   fontSize: context.sp(10.5),
//                   height: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         SizedBox(width: context.wp(3)),

//         Material(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(15),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(15),
//             onTap: () {
//               // TODO: Add logout logic
//             },
//             child: Container(
//               width: context.wp(11),
//               height: context.wp(11),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.18),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(
//                   color: Colors.white.withValues(alpha: 0.32),
//                   width: 1,
//                 ),
//               ),
//               child: Center(
//                 child: Icon(
//                   Icons.logout_rounded,
//                   color: const Color(0xFFB91C1C),
//                   size: context.wp(5.2),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _QuickActionCard extends StatelessWidget {
//   const _QuickActionCard();

//   @override
//   Widget build(BuildContext context) {
//     const darkOrange = Color(0xFFE85D04);

//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(24),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(24),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
//           );
//         },
//         child: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFFFF9200), Color(0xFFFF6D00)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: darkOrange.withValues(alpha: 0.22),
//                 blurRadius: 24,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: IgnorePointer(
//                   child: CustomPaint(painter: _InvoiceDoodles()),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: context.wp(4.5),
//                   vertical: context.wp(4),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: context.wp(15),
//                       height: context.wp(15),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Color(0xFFFFB13B), Color(0xFFE85D04)],
//                         ),
//                         borderRadius: BorderRadius.circular(17),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(
//                               0xFFB93800,
//                             ).withValues(alpha: 0.32),
//                             blurRadius: 14,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.receipt_long_rounded,
//                           color: Colors.white,
//                           size: context.wp(7),
//                         ),
//                       ),
//                     ),

//                     SizedBox(width: context.wp(4)),

//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Create New Invoice',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTextStyles.titleMedium.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                               fontSize: context.sp(15),
//                               height: 1.2,
//                             ),
//                           ),
//                           SizedBox(height: context.hp(0.6)),
//                           Text(
//                             'Create and send professional invoices',
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: Colors.white.withValues(alpha: 0.82),
//                               fontWeight: FontWeight.w500,
//                               fontSize: context.sp(10),
//                               height: 1.35,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(width: context.wp(3)),

//                     ClipOval(
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                         child: Container(
//                           width: context.wp(9.5),
//                           height: context.wp(9.5),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 Colors.white.withValues(alpha: 0.32),
//                                 const Color(0xFFFFB13B).withValues(alpha: 0.30),
//                                 const Color(0xFFE85D04).withValues(alpha: 0.38),
//                               ],
//                               stops: const [0.0, 0.55, 1.0],
//                             ),
//                             border: Border(
//                               bottom: BorderSide(
//                                 color: const Color(
//                                   0xFFB93800,
//                                 ).withValues(alpha: 0.75),
//                                 width: 1.6,
//                               ),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(
//                                   0xFFB93800,
//                                 ).withValues(alpha: 0.22),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               color: Colors.white,
//                               size: context.wp(3.5),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String actionText;
//   final VoidCallback onPressed;

//   const _SectionHeader({
//     required this.title,
//     required this.subtitle,
//     required this.actionText,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.titleLarge.copyWith(
//                   fontWeight: FontWeight.w800,
//                   fontSize: context.sp(18),
//                   height: 1.15,
//                 ),
//               ),
//               SizedBox(height: context.hp(0.3)),
//               Text(
//                 subtitle,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.grey700,
//                   fontWeight: FontWeight.w500,
//                   fontSize: context.sp(10),
//                   height: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         SizedBox(width: context.wp(3)),

//         Material(
//           color: Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           child: InkWell(
//             onTap: onPressed,
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: context.wp(1.2),
//                 vertical: context.hp(0.7),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     actionText,
//                     style: AppTextStyles.labelLarge.copyWith(
//                       color: AppColors.primary,
//                       fontWeight: FontWeight.w700,
//                       fontSize: context.sp(10),
//                     ),
//                   ),
//                   SizedBox(width: context.wp(1)),
//                   Icon(
//                     actionText == 'See All'
//                         ? Icons.arrow_forward_rounded
//                         : Icons.grid_view_rounded,
//                     color: AppColors.primary,
//                     size: context.wp(4),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ProductsGrid extends StatelessWidget {
//   const _ProductsGrid();

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: HomeScreen.products.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: context.wp(2.5),
//         mainAxisSpacing: context.hp(1.4),
//         childAspectRatio: 1.05,
//       ),
//       itemBuilder: (context, index) {
//         final product = HomeScreen.products[index];

//         return _ProductCard(
//           name: product['name'],
//           brand: product['brand'],
//           color: product['color'],
//           lightColor: product['lightColor'],
//         );
//       },
//     );
//   }
// }

// class _ProductCard extends StatelessWidget {
//   final String name;
//   final String brand;
//   final Color color;
//   final Color lightColor;

//   const _ProductCard({
//     required this.name,
//     required this.brand,
//     required this.color,
//     required this.lightColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: lightColor,
//       borderRadius: BorderRadius.circular(18),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: context.wp(3),
//             vertical: context.wp(3),
//           ),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [lightColor, color.withValues(alpha: 0.08)],
//             ),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: color.withValues(alpha: 0.16), width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withValues(alpha: 0.07),
//                 blurRadius: 12,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: context.wp(7),
//                 height: context.wp(0.8),
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),

//               SizedBox(height: context.hp(1.4)),

//               Text(
//                 name,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.titleMedium.copyWith(
//                   fontWeight: FontWeight.w800,
//                   fontSize: context.sp(10.5),
//                   height: 1.2,
//                 ),
//               ),

//               SizedBox(height: context.hp(0.55)),

//               Text(
//                 brand,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: color,
//                   fontWeight: FontWeight.w700,
//                   fontSize: context.sp(8.5),
//                   height: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _InvoiceHistoryCard extends StatelessWidget {
//   const _InvoiceHistoryCard();

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(24),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(24),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const InvoiceHistoryScreen()),
//           );
//         },
//         child: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF4F46E5)],
//             ),
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF4338CA).withValues(alpha: 0.22),
//                 blurRadius: 24,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: IgnorePointer(
//                   child: CustomPaint(painter: _InvoiceHistoryDoodles()),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: context.wp(4.5),
//                   vertical: context.wp(4),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: context.wp(15),
//                       height: context.wp(15),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Color(0xFFA5B4FC),
//                             Color(0xFF818CF8),
//                             Color(0xFF4F46E5),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(17),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(
//                               0xFF312E81,
//                             ).withValues(alpha: 0.35),
//                             blurRadius: 14,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.receipt_long_rounded,
//                           color: Colors.white,
//                           size: context.wp(7),
//                         ),
//                       ),
//                     ),

//                     SizedBox(width: context.wp(4)),

//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'View Invoice History',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTextStyles.titleMedium.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                               fontSize: context.sp(15),
//                               height: 1.2,
//                             ),
//                           ),
//                           SizedBox(height: context.hp(0.7)),
//                           Text(
//                             'Track and manage all your invoices',
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: Colors.white.withValues(alpha: 0.82),
//                               fontWeight: FontWeight.w500,
//                               fontSize: context.sp(10),
//                               height: 1.35,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(width: context.wp(3)),

//                     ClipOval(
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                         child: Container(
//                           width: context.wp(9.5),
//                           height: context.wp(9.5),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 Colors.white.withValues(alpha: 0.30),
//                                 const Color(0xFF818CF8).withValues(alpha: 0.30),
//                                 const Color(0xFF4338CA).withValues(alpha: 0.38),
//                               ],
//                               stops: const [0.0, 0.55, 1.0],
//                             ),
//                             border: Border(
//                               bottom: BorderSide(
//                                 color: const Color(
//                                   0xFF312E81,
//                                 ).withValues(alpha: 0.75),
//                                 width: 1.6,
//                               ),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(
//                                   0xFF312E81,
//                                 ).withValues(alpha: 0.22),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               color: Colors.white,
//                               size: context.wp(3.7),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _InvoiceDoodles extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final linePaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.15)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.25
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;

//     final softPaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.10)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.1
//       ..strokeCap = StrokeCap.round;

//     final invoice = Path()
//       ..moveTo(size.width - 82, -8)
//       ..lineTo(size.width - 32, -8)
//       ..lineTo(size.width - 32, 40)
//       ..lineTo(size.width - 40, 35)
//       ..lineTo(size.width - 48, 40)
//       ..lineTo(size.width - 56, 35)
//       ..lineTo(size.width - 64, 40)
//       ..lineTo(size.width - 82, 40)
//       ..close();

//     canvas.drawPath(invoice, linePaint);

//     canvas.drawLine(
//       Offset(size.width - 70, 5),
//       Offset(size.width - 45, 5),
//       linePaint,
//     );

//     canvas.drawLine(
//       Offset(size.width - 70, 14),
//       Offset(size.width - 50, 14),
//       linePaint,
//     );

//     canvas.drawLine(
//       Offset(size.width - 70, 23),
//       Offset(size.width - 56, 23),
//       linePaint,
//     );

//     final percentCenter = Offset(size.width - 125, 48);

//     canvas.drawCircle(percentCenter, 12, softPaint);

//     canvas.drawLine(
//       Offset(percentCenter.dx - 4, percentCenter.dy + 5),
//       Offset(percentCenter.dx + 5, percentCenter.dy - 5),
//       softPaint,
//     );

//     canvas.drawCircle(
//       Offset(percentCenter.dx - 4, percentCenter.dy - 4),
//       1.8,
//       softPaint,
//     );

//     canvas.drawCircle(
//       Offset(percentCenter.dx + 5, percentCenter.dy + 5),
//       1.8,
//       softPaint,
//     );

//     final document = Path()
//       ..moveTo(-10, size.height - 54)
//       ..lineTo(36, size.height - 54)
//       ..lineTo(36, size.height + 5)
//       ..lineTo(-10, size.height + 5)
//       ..close();

//     canvas.drawPath(document, linePaint);

//     canvas.drawLine(
//       Offset(2, size.height - 41),
//       Offset(27, size.height - 41),
//       linePaint,
//     );

//     canvas.drawLine(
//       Offset(2, size.height - 31),
//       Offset(22, size.height - 31),
//       linePaint,
//     );

//     canvas.drawLine(
//       Offset(2, size.height - 21),
//       Offset(28, size.height - 21),
//       linePaint,
//     );

//     final curve = Path()
//       ..moveTo(size.width - 145, size.height + 8)
//       ..cubicTo(
//         size.width - 100,
//         size.height - 42,
//         size.width - 45,
//         size.height - 35,
//         size.width + 12,
//         size.height - 4,
//       );

//     canvas.drawPath(curve, softPaint);

//     final sparkleX = size.width - 104;
//     final sparkleY = 78.0;

//     canvas.drawLine(
//       Offset(sparkleX, sparkleY - 7),
//       Offset(sparkleX, sparkleY + 7),
//       linePaint,
//     );

//     canvas.drawLine(
//       Offset(sparkleX - 7, sparkleY),
//       Offset(sparkleX + 7, sparkleY),
//       linePaint,
//     );

//     final dotPaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.18)
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(Offset(size.width - 80, 82), 1.8, dotPaint);

//     canvas.drawCircle(Offset(size.width - 70, 82), 1.8, dotPaint);

//     canvas.drawCircle(Offset(size.width - 60, 82), 1.8, dotPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class _InvoiceHistoryDoodles extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.12)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.2
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;

//     final circlePaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.08)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;

//     final receipt = Path()
//       ..moveTo(size.width - 78, -8)
//       ..lineTo(size.width - 30, -8)
//       ..lineTo(size.width - 30, 45)
//       ..lineTo(size.width - 38, 39)
//       ..lineTo(size.width - 46, 45)
//       ..lineTo(size.width - 54, 39)
//       ..lineTo(size.width - 62, 45)
//       ..lineTo(size.width - 78, 45)
//       ..close();

//     canvas.drawPath(receipt, paint);

//     canvas.drawLine(
//       Offset(size.width - 66, 6),
//       Offset(size.width - 43, 6),
//       paint,
//     );

//     canvas.drawLine(
//       Offset(size.width - 66, 15),
//       Offset(size.width - 48, 15),
//       paint,
//     );

//     canvas.drawLine(
//       Offset(size.width - 66, 24),
//       Offset(size.width - 52, 24),
//       paint,
//     );

//     canvas.drawCircle(Offset(size.width - 112, 38), 15, circlePaint);

//     canvas.drawCircle(Offset(size.width - 112, 38), 7, circlePaint);

//     final graph = Path()
//       ..moveTo(size.width - 148, size.height + 4)
//       ..cubicTo(
//         size.width - 120,
//         size.height - 25,
//         size.width - 92,
//         size.height - 10,
//         size.width - 66,
//         size.height - 30,
//       );

//     canvas.drawPath(graph, paint);

//     canvas.drawCircle(
//       Offset(size.width - 66, size.height - 30),
//       3,
//       circlePaint,
//     );

//     final document = Path()
//       ..moveTo(-12, size.height - 52)
//       ..lineTo(34, size.height - 52)
//       ..lineTo(34, size.height + 8)
//       ..lineTo(-12, size.height + 8)
//       ..close();

//     canvas.drawPath(document, paint);

//     canvas.drawLine(
//       Offset(2, size.height - 38),
//       Offset(25, size.height - 38),
//       paint,
//     );

//     canvas.drawLine(
//       Offset(2, size.height - 28),
//       Offset(20, size.height - 28),
//       paint,
//     );

//     canvas.drawLine(
//       Offset(2, size.height - 18),
//       Offset(27, size.height - 18),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
