import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../format.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';
import 'interest.dart';

/// Fertilizer credit and interest calculator. Works fully offline.
///
/// Order on screen: the answer first (summary), then the rate, the payback
/// date, and the list of purchases.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    final sheet = state.sheet;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.calculatorTitle),
        actions: [
          IconButton(
            iconSize: 32,
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      // Always visible, so Dad never has to scroll to find it.
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add, size: 32),
        label: Text(l.addPurchase, style: const TextStyle(fontSize: 20)),
        onPressed: () {
          sheet.purchases.add(
            Purchase(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              paybackOn: sheet.commonPaybackOn,
            ),
          );
          state.sheetChanged();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        // Extra space at the bottom so the add button never covers an item.
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          const _SummaryCard(),
          const SizedBox(height: 12),
          _RateCard(initialRate: sheet.rate),
          const SizedBox(height: 12),
          const _PaybackCard(),
          const SizedBox(height: 12),
          if (sheet.purchases.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.emptyList, textAlign: TextAlign.center),
            ),
          for (final p in sheet.purchases)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              // The key keeps each card's typed text with the right item.
              child: _PurchaseCard(key: ValueKey(p.id), purchase: p),
            ),
        ],
      ),
    );
  }
}

/// Total borrowed, total interest and amount to pay. Hidden behind a clear
/// message while any item has a problem, so a wrong total is never shown.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sheet = AppStateScope.of(context).sheet;
    if (sheet.purchases.isEmpty) return const SizedBox.shrink();

    final s = sheet.summary();
    if (s.hasErrors) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 32,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l.fixErrors, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      );
    }

    // No dashboard yet (Phase 2), so there is no paddy price and the
    // "paddy needed" line stays hidden.
    const double? latestPaddyPrice = null;
    final quintals = CreditSheet.paddyNeeded(s.amountToPay, latestPaddyPrice);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryLine(
              label: l.totalBorrowed,
              value: rupees(s.totalBorrowed),
            ),
            _SummaryLine(
              label: l.totalInterest,
              value: rupees(s.totalInterest),
            ),
            const Divider(height: 24),
            Text(l.amountToPay, style: theme.textTheme.titleMedium),
            Text(rupees(s.amountToPay), style: theme.textTheme.headlineMedium),
            if (quintals != null) ...[
              const SizedBox(height: 8),
              Text(l.paddyNeeded, style: theme.textTheme.titleMedium),
              Text(
                l.quintals(quintals.toStringAsFixed(1)),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      // Wrap lets long Telugu labels move the number to the next line
      // instead of being cut off.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

/// Interest rate number and whether it is a shop rate or a bank rate.
class _RateCard extends StatefulWidget {
  const _RateCard({required this.initialRate});

  final double initialRate;

  @override
  State<_RateCard> createState() => _RateCardState();
}

class _RateCardState extends State<_RateCard> {
  late final TextEditingController _rate;

  @override
  void initState() {
    super.initState();
    _rate = TextEditingController(text: _numberText(widget.initialRate));
  }

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    final sheet = state.sheet;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _rate,
              style: const TextStyle(fontSize: 24),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: l.interestRate,
                errorText: sheet.rate > 0 ? null : l.errRate,
              ),
              onChanged: (text) {
                sheet.rate = double.tryParse(text) ?? 0;
                state.sheetChanged();
              },
            ),
            RadioGroup<RateType>(
              groupValue: sheet.rateType,
              onChanged: (value) {
                if (value == null) return;
                sheet.rateType = value;
                state.sheetChanged();
              },
              child: Column(
                children: [
                  RadioListTile<RateType>(
                    contentPadding: EdgeInsets.zero,
                    value: RateType.perHundredPerMonth,
                    title: Text(l.ratePerHundredPerMonth),
                  ),
                  RadioListTile<RateType>(
                    contentPadding: EdgeInsets.zero,
                    value: RateType.percentPerYear,
                    title: Text(l.ratePercentPerYear),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "same payback date for all items" switch and the common date.
class _PaybackCard extends StatelessWidget {
  const _PaybackCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    final sheet = state.sheet;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.samePaybackForAll),
              value: sheet.samePaybackForAll,
              onChanged: (value) {
                sheet.setSamePaybackForAll(value);
                state.sheetChanged();
              },
            ),
            _DateButton(
              label: l.payingBackOn,
              date: sheet.commonPaybackOn,
              onPicked: (date) {
                sheet.commonPaybackOn = date;
                // Keep the hidden per-item dates in step while the switch is ON.
                if (sheet.samePaybackForAll) sheet.setSamePaybackForAll(true);
                state.sheetChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One purchase: name, amount, dates, and its result or problem.
class _PurchaseCard extends StatefulWidget {
  const _PurchaseCard({super.key, required this.purchase});

  final Purchase purchase;

  @override
  State<_PurchaseCard> createState() => _PurchaseCardState();
}

class _PurchaseCardState extends State<_PurchaseCard> {
  late final TextEditingController _name;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.purchase.name);
    _amount = TextEditingController(
      text: widget.purchase.amount > 0
          ? _numberText(widget.purchase.amount)
          : '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = AppStateScope.of(context);
    final sheet = state.sheet;
    final p = widget.purchase;
    final result = sheet.resultFor(p);
    final hasError = !result.isValid;

    // Ready-made names, so Dad can tap instead of typing.
    final quickNames = [
      l.itemUrea,
      l.itemDap,
      l.itemPotash,
      l.itemPesticide,
      l.itemSeeds,
    ];

    return Card(
      shape: hasError
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.error, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _name,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(labelText: l.itemName),
                    onChanged: (text) {
                      p.name = text;
                      state.sheetChanged();
                    },
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  tooltip: l.delete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => _delete(context),
                ),
              ],
            ),
            // Only shown until a name is chosen, to keep the card short.
            if (p.name.isEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final name in quickNames)
                    ActionChip(
                      label: Text(name, style: const TextStyle(fontSize: 18)),
                      onPressed: () {
                        _name.text = name;
                        p.name = name;
                        state.sheetChanged();
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              style: const TextStyle(fontSize: 24),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: l.amount,
                prefixText: '₹ ',
              ),
              onChanged: (text) {
                p.amount = double.tryParse(text) ?? 0;
                state.sheetChanged();
              },
            ),
            const SizedBox(height: 8),
            _DateButton(
              label: l.boughtOn,
              date: p.boughtOn,
              onPicked: (date) {
                p.boughtOn = date;
                state.sheetChanged();
              },
            ),
            if (!sheet.samePaybackForAll)
              _DateButton(
                label: l.payingBackOn,
                date: p.paybackOn,
                onPicked: (date) {
                  p.paybackOn = date;
                  state.sheetChanged();
                },
              ),
            const SizedBox(height: 8),
            if (hasError)
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorText(l, result.error!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(l.days(result.days), style: theme.textTheme.bodyLarge),
                  Text(
                    '${l.interest}: ${rupees(result.interest)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    '${l.itemTotal}: ${rupees(result.total)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Removes the item, with an Undo button in case of a wrong tap.
  void _delete(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    final list = state.sheet.purchases;
    final index = list.indexOf(widget.purchase);
    final removed = widget.purchase;
    list.removeAt(index);
    state.sheetChanged();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.removed, style: const TextStyle(fontSize: 18)),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () {
              list.insert(index.clamp(0, list.length), removed);
              state.sheetChanged();
            },
          ),
        ),
      );
  }
}

String _errorText(AppLocalizations l, PurchaseError error) => switch (error) {
  PurchaseError.amountNotPositive => l.errAmount,
  PurchaseError.missingBoughtDate => l.errBoughtDate,
  PurchaseError.missingPaybackDate => l.errPaybackDate,
  PurchaseError.boughtAfterPayback => l.errDateOrder,
};

/// "2" instead of "2.0", "2.5" stays "2.5".
String _numberText(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

/// A big button showing a label and a date; tapping opens a calendar.
class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_month, size: 32),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        date == null ? l.chooseDate : shortDate(date!, languageCode),
        style: theme.textTheme.titleLarge?.copyWith(
          color: date == null ? theme.colorScheme.primary : null,
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }
}
