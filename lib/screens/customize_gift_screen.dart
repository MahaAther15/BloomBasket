import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../widgets/primary_button.dart';

class CustomizeGiftScreen extends StatefulWidget {
  const CustomizeGiftScreen({super.key});

  @override
  State<CustomizeGiftScreen> createState() => _CustomizeGiftScreenState();
}

class _CustomizeGiftScreenState extends State<CustomizeGiftScreen> {
  String _selectedRibbon = 'Silk Cream';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CUSTOMIZE GIFT',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GIFT MESSAGE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'WRITE YOUR MESSAGE HERE...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.outline.withOpacity(0.4),
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.outline.withOpacity(0.2)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryGreen),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'RIBBON SELECTION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _OptionChip(
                  label: 'Silk Cream',
                  isActive: _selectedRibbon == 'Silk Cream',
                  onTap: () => setState(() => _selectedRibbon = 'Silk Cream'),
                ),
                _OptionChip(
                  label: 'Forest Velvet',
                  isActive: _selectedRibbon == 'Forest Velvet',
                  onTap: () => setState(() => _selectedRibbon = 'Forest Velvet'),
                ),
                _OptionChip(
                  label: 'Gold Satin',
                  isActive: _selectedRibbon == 'Gold Satin',
                  onTap: () => setState(() => _selectedRibbon = 'Gold Satin'),
                ),
                _OptionChip(
                  label: 'None',
                  isActive: _selectedRibbon == 'None',
                  onTap: () => setState(() => _selectedRibbon = 'None'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Text(
              'GIFT WRAP',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'PREMIUM RECYCLED PAPER',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Add a touch of sustainability and elegance.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: true,
              onChanged: (val) {},
              activeThumbColor: AppTheme.primaryGreen,
            ),

            const SizedBox(height: 60),

            PrimaryButton(
              label: 'Save Customization',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryGreen : Colors.white,
          border: Border.all(
            color: isActive ? AppTheme.primaryGreen : AppTheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? Colors.white : AppTheme.primaryGreen,
                fontSize: 10,
              ),
        ),
      ),
    );
  }
}
