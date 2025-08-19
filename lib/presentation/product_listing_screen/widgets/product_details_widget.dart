import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductDetailsWidget extends StatefulWidget {
  final TextEditingController nameController;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String selectedUnit;
  final Function(String) onUnitChanged;

  const ProductDetailsWidget({
    super.key,
    required this.nameController,
    this.selectedCategory,
    required this.onCategoryChanged,
    required this.descriptionController,
    required this.priceController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  State<ProductDetailsWidget> createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget> {
  final List<Map<String, dynamic>> categories = [
    {"name": "Fruits", "icon": "apple"},
    {"name": "Vegetables", "icon": "eco"},
    {"name": "Grains", "icon": "grain"},
    {"name": "Herbs", "icon": "local_florist"},
    {"name": "Dairy", "icon": "local_drink"},
    {"name": "Meat", "icon": "restaurant"},
    {"name": "Nuts", "icon": "nature"},
    {"name": "Honey", "icon": "honey_pot"},
  ];

  final List<String> units = [
    "per kg",
    "per g",
    "per item",
    "per bunch",
    "per bag",
    "per box",
    "per L",
    "per cm",
    "per mm",
  ];

  final List<String> productSuggestions = [
    "Organic Tomatoes",
    "Fresh Strawberries",
    "Sweet Corn",
    "Free-Range Eggs",
    "Raw Honey",
    "Mixed Greens",
    "Bell Peppers",
    "Organic Carrots",
    "Fresh Basil",
    "Grass-Fed Beef",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        _buildProductNameField(),
        SizedBox(height: 3.h),
        _buildCategorySelector(),
        SizedBox(height: 3.h),
        _buildDescriptionField(),
        SizedBox(height: 3.h),
        _buildPricingSection(),
      ],
    );
  }

  Widget _buildProductNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Product Name',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return productSuggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            widget.nameController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync with the main controller
            controller.text = widget.nameController.text;
            controller.addListener(() {
              widget.nameController.text = controller.text;
            });

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'e.g., Organic Tomatoes',
                prefixIcon: CustomIconWidget(
                  iconName: 'agriculture',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              textCapitalization: TextCapitalization.words,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 85.w,
                  constraints: BoxConstraints(maxHeight: 20.h),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Category',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: widget.selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select category',
            prefixIcon: CustomIconWidget(
              iconName: 'category',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category["name"],
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: category["icon"],
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(category["name"]),
                ],
              ),
            );
          }).toList(),
          onChanged: widget.onCategoryChanged,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.descriptionController.text.length}/500',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.descriptionController,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Describe your product, growing methods, freshness, etc.',
            counterText: '',
          ),
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) {
            setState(() {}); // Update character counter
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Price',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' *',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: widget.priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      prefixStyle:
                          AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  DropdownButtonFormField<String>(
                    value: units.contains(widget.selectedUnit)
                        ? widget.selectedUnit
                        : units.isNotEmpty
                            ? units.first
                            : null,
                    decoration: const InputDecoration(
                      hintText: 'Select unit',
                    ),
                    items: units.toSet().map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onUnitChanged(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
