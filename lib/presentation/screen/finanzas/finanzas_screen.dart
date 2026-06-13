import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/model/movimiento_model.dart';
import 'package:examen_final/providers/auth_provider.dart';
import 'package:examen_final/providers/movimiento_provider.dart';

class FinanzasScreen extends ConsumerStatefulWidget {
  const FinanzasScreen({super.key});

  @override
  ConsumerState<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends ConsumerState<FinanzasScreen> {
  int? _loadedUserId;

  void _ensureLoaded(int userId) {
    if (_loadedUserId == userId) return;
    _loadedUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(movimientoProvider.notifier).setUserId(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user != null) _ensureLoaded(user.id!);

    final movimientos = ref.watch(movimientoProvider);
    final texts = AppLocalizations.of(context)!;

    final totalIngresos = movimientos
        .where((m) => m.tipo == 'ingreso')
        .fold(0.0, (sum, m) => sum + m.valor);
    final totalGastos = movimientos
        .where((m) => m.tipo == 'gasto')
        .fold(0.0, (sum, m) => sum + m.valor);
    final balance = totalIngresos - totalGastos;

    return Stack(
      children: [
        Column(
          children: [
            _SummaryCards(
              totalIngresos: totalIngresos,
              totalGastos: totalGastos,
              balance: balance,
              texts: texts,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.list_alt,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    texts.movements,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: movimientos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline),
                          const SizedBox(height: 12),
                          Text(
                            texts.noMovements,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: movimientos.length,
                      itemBuilder: (context, index) {
                        final m = movimientos[index];
                        return _MovimientoItem(
                          movimiento: m,
                          texts: texts,
                          userId: user?.id ?? 0,
                          onEdit: () => _showMovimientoDialog(
                              context, movimiento: m, userId: user!.id!),
                          onDelete: () =>
                              _showDeleteDialog(context, m.id!),
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showMovimientoDialog(
              context,
              userId: user?.id ?? 0,
            ),
            icon: const Icon(Icons.add),
            label: Text(texts.registerMovement),
          ),
        ),
      ],
    );
  }

  Future<void> _showMovimientoDialog(
    BuildContext context, {
    MovimientoModel? movimiento,
    required int userId,
  }) async {
    final result = await showDialog<MovimientoModel>(
      context: context,
      builder: (ctx) => _MovimientoDialog(
        movimiento: movimiento,
        userId: userId,
      ),
    );
    if (result != null && mounted) {
      if (movimiento == null) {
        await ref.read(movimientoProvider.notifier).addMovimiento(result);
      } else {
        await ref
            .read(movimientoProvider.notifier)
            .updateMovimiento(result);
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, int id) async {
    final texts = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(texts.confirmDelete),
        content: Text(texts.deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(texts.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(texts.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(movimientoProvider.notifier).deleteMovimiento(id);
    }
  }
}

class _SummaryCards extends StatelessWidget {
  final double totalIngresos;
  final double totalGastos;
  final double balance;
  final AppLocalizations texts;

  const _SummaryCards({
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: texts.totalIncome,
                  value: totalIngresos,
                  color: Colors.green.shade600,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: texts.totalExpenses,
                  value: totalGastos,
                  color: Colors.red.shade600,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            label: texts.balance,
            value: balance,
            color: balance >= 0
                ? Theme.of(context).colorScheme.primary
                : Colors.red.shade700,
            icon: Icons.account_balance_wallet_rounded,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$ ${value.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isNegative ? Colors.red.shade700 : color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovimientoItem extends StatelessWidget {
  final MovimientoModel movimiento;
  final AppLocalizations texts;
  final int userId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MovimientoItem({
    required this.movimiento,
    required this.texts,
    required this.userId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIngreso = movimiento.tipo == 'ingreso';
    final color =
        isIngreso ? Colors.green.shade600 : Colors.red.shade600;

    return Slidable(
      key: ValueKey(movimiento.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: texts.edit,
          ),
          SlidableAction(
            flex: 1,
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: texts.delete,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIngreso
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            movimiento.descripcion,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatDate(movimiento.fecha),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          trailing: Text(
            '${isIngreso ? '+' : '-'} \$ ${movimiento.valor.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return fecha;
    }
  }
}

class   _MovimientoDialog extends StatefulWidget {
  final MovimientoModel? movimiento;
  final int userId;

  const _MovimientoDialog({this.movimiento, required this.userId});

  @override
  State<_MovimientoDialog> createState() => _MovimientoDialogState();
}

class _MovimientoDialogState extends State<_MovimientoDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _tipo;
  late TextEditingController _descController;
  late TextEditingController _valorController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tipo = widget.movimiento?.tipo ?? 'ingreso';
    _descController =
        TextEditingController(text: widget.movimiento?.descripcion ?? '');
    _valorController = TextEditingController(
      text: widget.movimiento != null
          ? widget.movimiento!.valor.toStringAsFixed(0)
          : '',
    );
    _selectedDate = widget.movimiento != null
        ? _parseFecha(widget.movimiento!.fecha)
        : DateTime.now();
  }

  DateTime _parseFecha(String fecha) {
    try {
      return DateTime.parse(fecha);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _formattedDate =>
      '${_selectedDate.day.toString().padLeft(2, '0')}/'
      '${_selectedDate.month.toString().padLeft(2, '0')}/'
      '${_selectedDate.year}';

  String get _storedDate =>
      '${_selectedDate.year}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final isEditing = widget.movimiento != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isEditing ? texts.updateMovement : texts.registerMovement,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _tipo,
                    decoration: InputDecoration(
                      labelText: texts.movementType,
                      prefixIcon:
                          const Icon(Icons.swap_vert_circle_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'ingreso',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: Colors.green.shade600, size: 18),
                            const SizedBox(width: 8),
                            Text(texts.income),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'gasto',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward_rounded,
                                color: Colors.red.shade600, size: 18),
                            const SizedBox(width: 8),
                            Text(texts.expense),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _tipo = v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: texts.description,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? texts.descriptionRequired
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: texts.value,
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return texts.valueRequired;
                      if (double.tryParse(v) == null) {
                        return texts.valueInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: texts.date,
                        prefixIcon:
                            const Icon(Icons.calendar_today_outlined),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_formattedDate),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(texts.cancel),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop(
                        MovimientoModel(
                          id: widget.movimiento?.id,
                          userId: widget.userId,
                          tipo: _tipo,
                          descripcion: _descController.text.trim(),
                          valor: double.parse(_valorController.text),
                          fecha: _storedDate,
                        ),
                      );
                    }
                  },
                  icon: Icon(isEditing ? Icons.save : Icons.check),
                  label: Text(isEditing
                      ? texts.updateMovement
                      : texts.saveMovement),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
