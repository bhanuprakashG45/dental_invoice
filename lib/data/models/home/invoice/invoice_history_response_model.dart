class InvoiceHistoryResponseModel {
  final bool success;
  final String message;
  final InvoiceHistoryDataModel data;

  const InvoiceHistoryResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InvoiceHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceHistoryResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? InvoiceHistoryDataModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : const InvoiceHistoryDataModel(),
    );
  }
}

class InvoiceHistoryDataModel {
  final List<InvoiceHistoryModel> invoices;
  final int limit;
  final int totalRecords;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const InvoiceHistoryDataModel({
    this.invoices = const [],
    this.limit = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory InvoiceHistoryDataModel.fromJson(Map<String, dynamic> json) {
    return InvoiceHistoryDataModel(
      invoices: json['invoices'] is List
          ? (json['invoices'] as List)
                .whereType<Map>()
                .map(
                  (item) => InvoiceHistoryModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : [],

      limit: _toInt(json['limit'], 10),
      totalRecords: _toInt(json['totalRecords']),
      totalPages: _toInt(json['totalPages']),

      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
    );
  }

  static int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}

class InvoiceHistoryModel {
  final String id;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String companyGstin;
  final String companyDlNo;

  final String invoiceNo;
  final String financialYear;
  final DateTime? invoiceDate;

  final String dispatchedThrough;
  final String reference;
  final String salesperson;

  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String customerGstin;
  final String customerEmail;

  final List<InvoiceHistoryItemModel> items;

  final String paymentStatus;

  final String bankName;
  final String accountNumber;
  final String ifscCode;

  final double subtotal;
  final double sgst;
  final double cgst;
  final double roundOff;
  final double totalAmount;

  final bool isDeleted;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InvoiceHistoryModel({
    required this.id,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.companyEmail,
    required this.companyGstin,
    required this.companyDlNo,
    required this.invoiceNo,
    required this.financialYear,
    required this.invoiceDate,
    required this.dispatchedThrough,
    required this.reference,
    required this.salesperson,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.customerGstin,
    required this.customerEmail,
    required this.items,
    required this.paymentStatus,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.subtotal,
    required this.sgst,
    required this.cgst,
    required this.roundOff,
    required this.totalAmount,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceHistoryModel(
      id: json['_id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      companyAddress: json['companyAddress']?.toString() ?? '',
      companyPhone: json['companyPhone']?.toString() ?? '',
      companyEmail: json['companyEmail']?.toString() ?? '',
      companyGstin: json['companyGstin']?.toString() ?? '',
      companyDlNo: json['companyDlNo']?.toString() ?? '',

      invoiceNo: json['invoiceNo']?.toString() ?? '',
      financialYear: json['financialYear']?.toString() ?? '',
      invoiceDate: _parseDate(json['invoiceDate']),

      dispatchedThrough: json['dispatchedThrough']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      salesperson: json['salesperson']?.toString() ?? '',

      customerName: json['customerName']?.toString() ?? '',
      customerAddress: json['customerAddress']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerGstin: json['customerGstin']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',

      items: json['items'] is List
          ? (json['items'] as List)
                .whereType<Map>()
                .map(
                  (item) => InvoiceHistoryItemModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : [],

      paymentStatus: json['paymentStatus']?.toString() ?? '',

      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',

      subtotal: _toDouble(json['subtotal']),
      sgst: _toDouble(json['sgst']),
      cgst: _toDouble(json['cgst']),
      roundOff: _toDouble(json['roundOff']),
      totalAmount: _toDouble(json['totalAmount']),

      isDeleted: json['isDeleted'] == true,

      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'companyEmail': companyEmail,
      'companyGstin': companyGstin,
      'companyDlNo': companyDlNo,
      'invoiceNo': invoiceNo,
      'financialYear': financialYear,
      'invoiceDate': invoiceDate?.toIso8601String(),
      'dispatchedThrough': dispatchedThrough,
      'reference': reference,
      'salesperson': salesperson,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'customerGstin': customerGstin,
      'customerEmail': customerEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'paymentStatus': paymentStatus,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'subtotal': subtotal,
      'sgst': sgst,
      'cgst': cgst,
      'roundOff': roundOff,
      'totalAmount': totalAmount,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

class InvoiceHistoryItemModel {
  final String service;
  final String hsnCode;
  final double gst;
  final double quantity;
  final double rate;
  final double amount;

  const InvoiceHistoryItemModel({
    required this.service,
    required this.hsnCode,
    required this.gst,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  factory InvoiceHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceHistoryItemModel(
      service: json['service']?.toString() ?? '',
      hsnCode: json['hsnCode']?.toString() ?? '',
      gst: _toDouble(json['gst']),
      quantity: _toDouble(json['quantity']),
      rate: _toDouble(json['rate']),
      amount: _toDouble(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service,
      'hsnCode': hsnCode,
      'gst': gst,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
