import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends State<AddExpenseScreen> {
  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();

  String? receiptData;

  final List<String> categories = [
    'Food',
    'Shopping',
    'Travel',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  Future<void> selectDate() async {
    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF20A4F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> showReceiptOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              const Text(
                'Add Receipt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF20A4F3),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  pickReceipt(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF20A4F3),
                ),
                title: const Text(
                  'Choose from Gallery',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  pickReceipt(ImageSource.gallery);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickReceipt(
    ImageSource source,
  ) async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(
        source: source,
        imageQuality: 60,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      final String encoded =
          base64Encode(bytes);

      if (!mounted) {
        return;
      }

      setState(() {
        receiptData = encoded;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to select receipt: $e',
          ),
        ),
      );
    }
  }

  void removeReceipt() {
    setState(() {
      receiptData = null;
    });
  }

  Future<void> saveExpense() async {
    final String amountText =
        amountController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
        ),
      );
      return;
    }

    final double? amount =
        double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount',
          ),
        ),
      );
      return;
    }

    final Expense expense = Expense(
      amount: amount,
      category: selectedCategory,
      description:
          descriptionController.text.trim(),
      date: selectedDate,
      receiptData: receiptData,
    );

    await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).addExpense(expense);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Expense added successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor:
            const Color(0xFFF6F8FB),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20A4F3),
                ),
                hintText: 'Enter amount',
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child:
                  DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF20A4F3),
                  ),
                  items:
                      categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(
                              category,
                            ),
                            size: 20,
                            color:
                                const Color(
                              0xFF20A4F3,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Date',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: selectDate,
              borderRadius:
                  BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF20A4F3),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'What was this expense for?',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Bill / Receipt',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (receiptData == null)
              InkWell(
                onTap: showReceiptOptions,
                borderRadius:
                    BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: Color(0xFF20A4F3),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add Receipt',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Take a photo or choose an image',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(receiptData!),
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                showReceiptOptions,
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                            label:
                                const Text('Change'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                removeReceipt,
                            icon: const Icon(
                              Icons.delete_outline,
                            ),
                            label:
                                const Text('Remove'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: saveExpense,
                icon: const Icon(
                  Icons.check_circle_outline,
                ),
                label: const Text(
                  'Save Expense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Your expense will be saved locally',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;

      case 'Shopping':
        return Icons.shopping_bag_outlined;

      case 'Travel':
        return Icons.flight_outlined;

      case 'Entertainment':
        return Icons.movie_outlined;

      case 'Bills':
        return Icons.receipt_long_outlined;

      case 'Health':
        return Icons.health_and_safety_outlined;

      case 'Other':
        return Icons.more_horiz_outlined;

      default:
        return Icons.receipt_long_outlined;
    }
  }
}