class InvoiceItemModel {
  final String service;
  final String hsnCode;
  final double gst;
  final double quantity;
  final double rate;
  final double amount;

  const InvoiceItemModel({
    required this.service,
    required this.hsnCode,
    required this.gst,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  factory InvoiceItemModel.fromPreviewMap(Map<String, dynamic> json) {
    final quantity = _toDouble(json['quantity']);
    final rate = _toDouble(json['rate'] ?? json['price']);

    return InvoiceItemModel(
      service: _toString(json['service'] ?? json['name']),
      hsnCode: _toString(json['hsnCode']),
      gst: _toDouble(json['gst'] ?? json['gstPercent']),
      quantity: quantity,
      rate: rate,
      amount: _toDouble(json['amount'] ?? (quantity * rate)),
    );
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      service: _toString(json['service']),
      hsnCode: _toString(json['hsnCode']),
      gst: _toDouble(json['gst']),
      quantity: _toDouble(json['quantity']),
      rate: _toDouble(json['rate']),
      amount: _toDouble(json['amount']),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'service': service,
      'hsnCode': hsnCode,
      'gst': _numberValue(gst),
      'quantity': _numberValue(quantity),
      'rate': _numberValue(rate),
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'service': service,
      'hsnCode': hsnCode,
      'gst': gst,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }
}

class InvoiceModel {
  final String? id;

  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String companyGstin;
  final String companyDlNo;

  final String invoiceNo;
  final String financialYear;
  final String invoiceDate;

  final String dispatchedThrough;
  final String reference;
  final String salesperson;

  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String customerGstin;
  final String customerEmail;

  final List<InvoiceItemModel> items;

  final String paymentStatus;

  final String bankName;
  final String accountNumber;
  final String ifscCode;

  final double subtotal;
  final double sgst;
  final double cgst;
  final double roundOff;
  final double totalAmount;

  final bool isSynced;

  const InvoiceModel({
    this.id,
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
    this.isSynced = false,
  });

  factory InvoiceModel.fromPreviewMap(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => InvoiceItemModel.fromPreviewMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <InvoiceItemModel>[];

    return InvoiceModel(
      id: json['id']?.toString(),

      companyName: _toString(json['companyName'] ?? json['sellerName']),
      companyAddress: _toString(
        json['companyAddress'] ?? json['sellerAddress'],
      ),
      companyPhone: _toString(json['companyPhone'] ?? json['sellerPhone']),
      companyEmail: _toString(json['companyEmail'] ?? json['sellerEmail']),
      companyGstin: _toString(json['companyGstin'] ?? json['sellerGstin']),
      companyDlNo: _toString(json['companyDlNo'] ?? json['sellerLicense']),

      invoiceNo: _toString(json['invoiceNo'] ?? json['invoiceNumber']),
      financialYear: _toString(json['financialYear']),
      invoiceDate: _formatDate(json['invoiceDate'] ?? json['date']),

      dispatchedThrough: _toString(json['dispatchedThrough']),
      reference: _toString(json['reference']),
      salesperson: _toString(json['salesperson'] ?? json['salesPerson']),

      customerName: _toString(json['customerName']),
      customerAddress: _toString(json['customerAddress']),
      customerPhone: _toString(json['customerPhone']),
      customerGstin: _toString(json['customerGstin']),
      customerEmail: _toString(json['customerEmail']),

      items: items,

      paymentStatus: _toString(json['paymentStatus']).toLowerCase(),

      bankName: _toString(json['bankName']),
      accountNumber: _toString(json['accountNumber']),
      ifscCode: _toString(json['ifscCode'] ?? json['ifsc']),

      subtotal: _toDouble(json['subtotal']),
      sgst: _toDouble(json['sgst']),
      cgst: _toDouble(json['cgst']),
      roundOff: _toDouble(json['roundOff']),
      totalAmount: _toDouble(json['totalAmount'] ?? json['total']),

      isSynced: json['isSynced'] == true,
    );
  }

  factory InvoiceModel.fromLocalJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    InvoiceItemModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <InvoiceItemModel>[];

    return InvoiceModel(
      id: json['id']?.toString(),

      companyName: _toString(json['companyName']),
      companyAddress: _toString(json['companyAddress']),
      companyPhone: _toString(json['companyPhone']),
      companyEmail: _toString(json['companyEmail']),
      companyGstin: _toString(json['companyGstin']),
      companyDlNo: _toString(json['companyDlNo']),

      invoiceNo: _toString(json['invoiceNo']),
      financialYear: _toString(json['financialYear']),
      invoiceDate: _toString(json['invoiceDate']),

      dispatchedThrough: _toString(json['dispatchedThrough']),
      reference: _toString(json['reference']),
      salesperson: _toString(json['salesperson']),

      customerName: _toString(json['customerName']),
      customerAddress: _toString(json['customerAddress']),
      customerPhone: _toString(json['customerPhone']),
      customerGstin: _toString(json['customerGstin']),
      customerEmail: _toString(json['customerEmail']),

      items: items,

      paymentStatus: _toString(json['paymentStatus']),

      bankName: _toString(json['bankName']),
      accountNumber: _toString(json['accountNumber']),
      ifscCode: _toString(json['ifscCode']),

      subtotal: _toDouble(json['subtotal']),
      sgst: _toDouble(json['sgst']),
      cgst: _toDouble(json['cgst']),
      roundOff: _toDouble(json['roundOff']),
      totalAmount: _toDouble(json['totalAmount']),

      isSynced: json['isSynced'] == true,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'companyEmail': companyEmail,
      'companyGstin': companyGstin,
      'companyDlNo': companyDlNo,

      'invoiceNo': invoiceNo,
      'financialYear': financialYear,
      'invoiceDate': invoiceDate,

      'dispatchedThrough': dispatchedThrough,
      'reference': reference,
      'salesperson': salesperson,

      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'customerGstin': customerGstin,
      'customerEmail': customerEmail,

      'items': items.map((item) => item.toApiJson()).toList(),

      'paymentStatus': paymentStatus,

      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,

      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'companyEmail': companyEmail,
      'companyGstin': companyGstin,
      'companyDlNo': companyDlNo,

      'invoiceNo': invoiceNo,
      'financialYear': financialYear,
      'invoiceDate': invoiceDate,

      'dispatchedThrough': dispatchedThrough,
      'reference': reference,
      'salesperson': salesperson,

      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'customerGstin': customerGstin,
      'customerEmail': customerEmail,

      'items': items.map((item) => item.toLocalJson()).toList(),

      'paymentStatus': paymentStatus,

      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,

      'subtotal': subtotal,
      'sgst': sgst,
      'cgst': cgst,
      'roundOff': roundOff,
      'totalAmount': totalAmount,

      'isSynced': isSynced,
    };
  }

  InvoiceModel copyWith({String? id, bool? isSynced}) {
    return InvoiceModel(
      id: id ?? this.id,

      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyEmail: companyEmail,
      companyGstin: companyGstin,
      companyDlNo: companyDlNo,

      invoiceNo: invoiceNo,
      financialYear: financialYear,
      invoiceDate: invoiceDate,

      dispatchedThrough: dispatchedThrough,
      reference: reference,
      salesperson: salesperson,

      customerName: customerName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      customerGstin: customerGstin,
      customerEmail: customerEmail,

      items: items,

      paymentStatus: paymentStatus,

      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,

      subtotal: subtotal,
      sgst: sgst,
      cgst: cgst,
      roundOff: roundOff,
      totalAmount: totalAmount,

      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class InvoiceResponseModel {
  final bool success;
  final String message;
  final InvoiceModel? data;

  const InvoiceResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory InvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? InvoiceModel.fromLocalJson(
              Map<String, dynamic>.from(json['data']),
            ).copyWith(id: json['data']['_id']?.toString(), isSynced: true)
          : null,
    );
  }
}

// Helpers

String _toString(dynamic value) {
  return value?.toString() ?? '';
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

dynamic _numberValue(double value) {
  return value == value.roundToDouble() ? value.toInt() : value;
}

String _formatDate(dynamic value) {
  if (value == null) return '';

  final valueString = value.toString();

  if (valueString.length >= 10 &&
      RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(valueString)) {
    return valueString.substring(0, 10);
  }

  return valueString;
}
