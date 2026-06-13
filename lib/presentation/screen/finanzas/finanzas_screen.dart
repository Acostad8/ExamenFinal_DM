// ─── IMPORTACIONES ───────────────────────────────────────────────────────────
// Paquetes de Flutter, Riverpod, el paquete de swipe (slidable),
// traducciones, modelo, y los providers necesarios
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/model/movimiento_model.dart';
import 'package:examen_final/providers/auth_provider.dart';
import 'package:examen_final/providers/movimiento_provider.dart';

// Pantalla principal de gestión financiera
class FinanzasScreen extends ConsumerStatefulWidget {
  const FinanzasScreen({super.key});

  @override
  ConsumerState<FinanzasScreen> createState() => _FinanzasScreenState();
}

// ─── ESTADO DE LA PANTALLA ───────────────────────────────────────────────────
class _FinanzasScreenState extends ConsumerState<FinanzasScreen> {
  //GUARDA EL ID DEL USUARIO CUYA INFORMACIÓN SE HA CARGADO, PARA EVITAR RECARGAS INNECESARIAS SI EL USUARIO NO CAMBIA.
  int? _loadedUserId;

  // ─── CARGA INICIAL DE MOVIMIENTOS ──────────────────────────────────────────
  // Carga los movimientos del usuario solo una vez por sesión
  void _ensureLoaded(int userId) {
    if (_loadedUserId == userId) return;
    _loadedUserId = userId;
    // addPostFrameCallback asegura que la carga ocurra después del primer render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        //carga los movimientos desde SQLite y los asigna al provider para que estén disponibles en toda la aplicación.
        ref.read(movimientoProvider.notifier).setUserId(userId);
      }
    });
  }

  // ─── CONSTRUCCIÓN DE LA PANTALLA ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    //obtiene el usuario autenticado del provider authProvider.
    //Si hay un usuario, llama a _ensureLoaded con su ID para cargar sus movimientos financieros.
    //Esto garantiza que los datos se carguen solo una vez por sesión y evita recargas innecesarias
    // si el usuario no cambia.
    final user = ref.watch(authProvider);
    if (user != null) _ensureLoaded(user.id!);

    //Obtiene la lista de movimientos financieros del provider movimientoProvider.
    final movimientos = ref.watch(movimientoProvider);
    //Traducciones
    final texts = AppLocalizations.of(context)!;

    // ─── CÁLCULO DEL RESUMEN FINANCIERO ──────────────────────────────────────
    // Cálculos de resumen financiero derivados de la lista de movimientos
    final totalIngresos = movimientos
        //recorre la lista y va filtrando solo los movimientos de ingreso
        .where((m) => m.tipo == 'ingreso')
        //fold es una función que reduce la lista a un solo valor,
        // en este caso sumando el valor de cada movimiento de ingreso.
        .fold(0.0, (sum, m) => sum + m.valor);
    final totalGastos = movimientos
        //Recorre la lista de movimientos y va filtrando solo los movimientos de gasto
        .where((m) => m.tipo == 'gasto')
        //fold es una función que reduce la lista a un solo valor,
        // en este caso sumando el valor de cada movimiento de gasto.
        .fold(0.0, (sum, m) => sum + m.valor);

    //Calcular el total lo que ingreso y lo que se gasto
    final balance = totalIngresos - totalGastos;

    // ─── ESTRUCTURA VISUAL PRINCIPAL ─────────────────────────────────────────
    //coloca widgets en un Stack para superponer el FAB sobre la lista de movimientos.
    //permite colocar widget uno encima del otro
    return Stack(
      //APILA EL COLUMN Y EL ROW UNO SOBRE OTRO EN LA MISMA POSICIÓN, PERMITIENDO QUE EL FAB SE MUESTRE SOBRE LA LISTA DE MOVIMIENTOS.
      children: [
        Column(
          children: [
            // ─── SECCIÓN: TARJETAS DE RESUMEN ──────────────────────────────
            // Tarjetas de resumen: ingresos, gastos y balance
            _SummaryCards(
              totalIngresos: totalIngresos,
              totalGastos: totalGastos,
              balance: balance,
              texts: texts,
            ),
            // ─── SECCIÓN: ENCABEZADO DE LA LISTA ───────────────────────────
            // Encabezado de la lista de movimientos
            Padding(
              padding:
                  //
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  //Ícono y título del encabezado, usando traducciones para el texto
                  Icon(
                    Icons.list_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  //TEXTO MOVIMIENTOS
                  Text(
                    texts.movements,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // ─── SECCIÓN: LISTA DE MOVIMIENTOS ─────────────────────────────
            // El área expandida muestra la lista de movimientos o un mensaje vacío si no hay movimientos registrados.
            Expanded(
              // Muestra mensaje vacío o la lista según el estado del provider
              child: movimientos.isEmpty
                  //MENSAJE EN QUE CASO DE QUE NO HAYA MOVIMIENTOS
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            texts.noMovements,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  // ListView.builder es un widget que construye una lista de forma perezosa,
                  //creando solo los elementos visibles en pantalla.
                  //Lista de movimiento financieros, cada uno representado por un widget _MovimientoItem
                  //que muestra su información y permite editar o eliminar el movimiento mediante acciones
                  //de deslizar.
                  : ListView.builder(
                      itemCount: movimientos.length,
                      itemBuilder: (context, index) {
                        final m = movimientos[index];
                        return _MovimientoItem(
                          movimiento: m,
                          texts: texts,
                          userId: user?.id ?? 0,
                          onEdit: () => _showMovimientoDialog(
                            context,
                            movimiento: m,
                            userId: user!.id!,
                          ),
                          onDelete: () => _showDeleteDialog(context, m.id!),
                        );
                      },
                    ),
            ),
          ],
        ),
        // ─── SECCIÓN: BOTÓN FLOTANTE (FAB) ───────────────────────────────────
        // FAB flotante para agregar un nuevo movimiento
        Positioned(
          //16PX DESDE ABAJO
          bottom: 16,
          //16PX DESDE LA DERECHA
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () =>
                _showMovimientoDialog(context, userId: user?.id ?? 0),
            icon: const Icon(Icons.add),
            label: Text(texts.registerMovement),
          ),
        ),
      ],
    );
  }

  // ─── MODAL DE CREACIÓN / EDICIÓN ─────────────────────────────────────────
  // Abre el modal de creación o edición; cuando cierra aplica el CRUD correspondiente
  Future<void> _showMovimientoDialog(
    BuildContext context, {
    MovimientoModel? movimiento,
    required int userId,
  }) async {
    final result = await showDialog<MovimientoModel>(
      context: context,
      builder: (ctx) =>
          _MovimientoDialog(movimiento: movimiento, userId: userId),
    );
    if (result != null && mounted) {
      if (movimiento == null) {
        // Sin movimiento previo → insertar
        await ref.read(movimientoProvider.notifier).addMovimiento(result);
      } else {
        // Con movimiento previo → actualizar
        await ref.read(movimientoProvider.notifier).updateMovimiento(result);
      }
    }
  }

  // ─── DIÁLOGO DE CONFIRMACIÓN DE ELIMINACIÓN ───────────────────────────────
  // Muestra diálogo de confirmación antes de eliminar un movimiento
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

// ─── WIDGET: GRUPO DE TARJETAS DE RESUMEN ────────────────────────────────────
// Widget que agrupa las tres tarjetas de resumen financiero
class _SummaryCards extends StatelessWidget {
  // ─── PROPIEDADES ───────────────────────────────────────────────────────────
  final double totalIngresos; // suma de todos los ingresos
  final double totalGastos; // suma de todos los gastos
  final double balance; // resultado de ingresos - gastos
  final AppLocalizations texts; // textos traducidos

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
          // Fila superior: ingresos y gastos lado a lado
          Row(
            children: [
              // ─── TARJETA INGRESOS ─────────────────────────────────────────
              Expanded(
                child: _SummaryCard(
                  label: texts.totalIncome,
                  value: totalIngresos,
                  color: Colors.green.shade600,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              // ─── TARJETA GASTOS ───────────────────────────────────────────
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
          // ─── TARJETA BALANCE (ancho completo) ────────────────────────────
          // Tarjeta de balance a ancho completo; cambia de color si es negativo
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

// ─── WIDGET: TARJETA INDIVIDUAL DE RESUMEN ───────────────────────────────────
// Tarjeta individual con ícono, etiqueta y valor monetario
class _SummaryCard extends StatelessWidget {
  // ─── PROPIEDADES ───────────────────────────────────────────────────────────
  final String label; // texto de la etiqueta (ej: "Total Ingresos")
  final double value; // valor monetario a mostrar
  final Color color; // color del ícono y borde
  final IconData icon; // ícono a mostrar
  final bool fullWidth; // true = ocupa todo el ancho (tarjeta de balance)

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    // ─── LÓGICA DE COLOR NEGATIVO ─────────────────────────────────────────
    final isNegative = value < 0; // detecta si el balance es negativo
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      // ─── DECORACIÓN DE LA TARJETA ─────────────────────────────────────
      // fondo semitransparente y borde del color del tipo de movimiento
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Ícono circular con fondo semitransparente
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // ─── TEXTO: ETIQUETA Y VALOR ────────────────────────────────────
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
                // Muestra el valor en rojo si el balance es negativo
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

// ─── WIDGET: ITEM DE MOVIMIENTO EN LA LISTA ───────────────────────────────────
// Item de la lista con swipe para editar o eliminar
class _MovimientoItem extends StatelessWidget {
  // ─── PROPIEDADES ───────────────────────────────────────────────────────────
  final MovimientoModel movimiento; // datos del movimiento a mostrar
  final AppLocalizations texts; // textos traducidos
  final int userId; // id del usuario dueño
  final VoidCallback onEdit; // función que se ejecuta al tocar Editar
  final VoidCallback onDelete; // función que se ejecuta al tocar Eliminar

  const _MovimientoItem({
    required this.movimiento,
    required this.texts,
    required this.userId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ─── LÓGICA DE COLOR E ÍCONO SEGÚN TIPO ──────────────────────────────
    // true si es ingreso, false si es gasto; determina color e ícono
    final isIngreso = movimiento.tipo == 'ingreso';
    final color = isIngreso ? Colors.green.shade600 : Colors.red.shade600;

    // ─── WIDGET DESLIZABLE (SWIPE) ────────────────────────────────────────
    return Slidable(
      key: ValueKey(movimiento.id),
      // Acciones que aparecen al deslizar hacia la izquierda
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // ─── BOTÓN EDITAR ───────────────────────────────────────────────
          SlidableAction(
            flex: 1,
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: texts.edit,
          ),
          // ─── BOTÓN ELIMINAR ─────────────────────────────────────────────
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
      // ─── CONTENIDO VISIBLE DEL ITEM ──────────────────────────────────────
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        // decoración: esquinas redondeadas y sombra sutil
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          // Ícono de flecha arriba/abajo según el tipo de movimiento
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
          // ─── DESCRIPCIÓN Y FECHA ──────────────────────────────────────
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
          // Valor con signo + o - según si es ingreso o gasto
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

  // ─── FORMATO DE FECHA ─────────────────────────────────────────────────────
  // Convierte la fecha de formato ISO (YYYY-MM-DD) a formato legible (DD/MM/YYYY)
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

// ─── WIDGET: MODAL DE CREACIÓN / EDICIÓN DE MOVIMIENTO ───────────────────────
// Modal para crear o editar un movimiento financiero
class _MovimientoDialog extends StatefulWidget {
  final MovimientoModel?
  movimiento; // null = modo creación, no null = modo edición
  final int userId;

  const _MovimientoDialog({this.movimiento, required this.userId});

  @override
  State<_MovimientoDialog> createState() => _MovimientoDialogState();
}

class _MovimientoDialogState extends State<_MovimientoDialog> {
  // ─── VARIABLES DE ESTADO DEL FORMULARIO ──────────────────────────────────
  final _formKey = GlobalKey<FormState>(); // llave para validar el formulario
  late String _tipo; // 'ingreso' o 'gasto'
  late TextEditingController
  _descController; // controlador del campo descripción
  late TextEditingController _valorController; // controlador del campo valor
  late DateTime _selectedDate; // fecha seleccionada por el usuario

  // ─── INICIALIZACIÓN ───────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Pre-carga los valores existentes si es edición, o valores por defecto si es creación
    _tipo = widget.movimiento?.tipo ?? 'ingreso';
    _descController = TextEditingController(
      text: widget.movimiento?.descripcion ?? '',
    );
    _valorController = TextEditingController(
      text: widget.movimiento != null
          ? widget.movimiento!.valor.toStringAsFixed(0)
          : '', //VACIO SI ES CREACION
    );
    _selectedDate = widget.movimiento != null
        ? _parseFecha(widget.movimiento!.fecha)
        : DateTime.now(); //HOY SI ES NUEVO
  }

  // ─── CONVERSIÓN DE FECHA ──────────────────────────────────────────────────
  // Convierte el string de fecha ISO a DateTime; usa la fecha actual si falla
  DateTime _parseFecha(String fecha) {
    try {
      return DateTime.parse(fecha);
    } catch (_) {
      return DateTime.now();
    }
  }

  // ─── LIMPIEZA DE MEMORIA ──────────────────────────────────────────────────
  //SE LLLAMA CUANDO EL WIDGET ES ELIMINADO
  //USADO PARA LIMPIAR MEMORIA DE LOS CONTROLADORES DE TEXTO PARA EVITAR FUGAS DE MEMORIA
  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // ─── SELECTOR DE FECHA ────────────────────────────────────────────────────
  // Abre el selector de fecha del sistema
  Future<void> _selectDate() async {
    //espera que el usuario seleccione una fecha en el selector de fecha del sistema.
    //El selector se inicializa con la fecha actualmente seleccionada (_selectedDate)
    // y permite seleccionar fechas entre el 1 de enero de 2000 y el 31 de diciembre de 2100.
    final picked = await showDatePicker(
      context: context, //pantalla a mostrarse
      initialDate: _selectedDate, //fecha inicial del selector
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    //se actualiza la variables _selectedDate con la fecha seleccionada por el usuario.
    // Si el usuario cancela el selector (picked es null), no se realiza ningún cambio.
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ─── FORMATOS DE FECHA ────────────────────────────────────────────────────
  // Fecha en formato legible para mostrar al usuario (DD/MM/YYYY)
  String get _formattedDate =>
      '${_selectedDate.day.toString().padLeft(2, '0')}/'
      '${_selectedDate.month.toString().padLeft(2, '0')}/'
      '${_selectedDate.year}';

  // Fecha en formato ISO para guardar en SQLite (YYYY-MM-DD)
  String get _storedDate =>
      '${_selectedDate.year}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  // ─── CONSTRUCCIÓN DEL MODAL ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    //PARA DETECTAR SI ES EDICION O CREACION
    //PARA CAMBIAR EL TITULO EL ICONO Y EL TEXTO DEL BOTON DE CONFIRMAR SEGUN EL MODO
    final isEditing = widget.movimiento != null;

    // Dialog personalizado con formulario para ingresar o editar un movimiento financiero.
    //ventana emergente que se muestra sobre la pantalla actual, con un formulario para
    // ingresar o editar un movimiento financiero.
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── ENCABEZADO DEL MODAL ───────────────────────────────────────
            // Encabezado con ícono y título dinámico según el modo
            Row(
              children: [
                Icon(
                  //cambia el icono segun si es edicion o creacion
                  isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  //cambia el texto del titulo segun si es edicion o creacion
                  isEditing ? texts.updateMovement : texts.registerMovement,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ─── FORMULARIO DE DATOS ────────────────────────────────────────
            //formulario para ingresar o editar los datos del movimiento financiero
            Form(
              //key del formulario para validar los campos antes de guardar
              key: _formKey,
              child: Column(
                children: [
                  // ─── CAMPO: TIPO DE MOVIMIENTO ────────────────────────────
                  // Selector de tipo: ingreso o gasto
                  DropdownButtonFormField<String>(
                    initialValue: _tipo,
                    decoration: InputDecoration(
                      labelText: texts.movementType,
                      prefixIcon: const Icon(Icons.swap_vert_circle_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    //SELECTOR DE INGRESO
                    items: [
                      DropdownMenuItem(
                        value: 'ingreso',
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.green.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(texts.income),
                          ],
                        ),
                      ),
                      //SELECTOR DE GASTO
                      DropdownMenuItem(
                        value: 'gasto',
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.red.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(texts.expense),
                          ],
                        ),
                      ),
                    ],
                    //Guarda el valor de la variable seleccionada en _tipo cada vez que
                    //el usuario cambia la selección
                    onChanged: (v) => setState(() => _tipo = v!),
                  ),
                  const SizedBox(height: 14),
                  // ─── CAMPO: DESCRIPCIÓN ───────────────────────────────────
                  // Campo de descripción con validación de no vacío
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: texts.description,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    //Valida que el campo no esté vacío; si lo está, muestra un mensaje de error usando las traducciones.
                    validator: (v) => v == null || v.isEmpty
                        ? texts.descriptionRequired
                        : null,
                  ),
                  const SizedBox(height: 14),
                  // ─── CAMPO: VALOR ─────────────────────────────────────────
                  // Campo de valor numérico con validación de formato
                  TextFormField(
                    //keyboardType con decimal para que el teclado muestre el punto decimal, 7
                    //facilitando la entrada de valores monetarios.
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: texts.value,
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      //Valida que el campo no esté vacío y que el valor ingresado sea un número válido.
                      //}Si el campo está vacío, muestra un mensaje de error indicando que el valor es requerido.
                      // Si el valor no es un número válido, muestra un mensaje de error indicando que el valor es inválido.
                      //Si ambos casos son correctos, devuelve null para indicar que la validación fue exitosa.
                      if (v == null || v.isEmpty) return texts.valueRequired;

                      //double.tryParse intenta convertir el string ingresado a un número de punto flotante.
                      //Si la conversión falla (por ejemplo, si el usuario ingresó texto no numérico), devuelve null.
                      if (double.tryParse(v) == null) {
                        return texts.valueInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // ─── CAMPO: FECHA ─────────────────────────────────────────
                  // Selector de fecha; al tocarlo abre el del sistema
                  //permite que el widget sea tocable. Al tocarlo, se ejecuta la función _selectDate
                  // que abre el selector de fecha del sistema.
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: texts.date,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
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
            // ─── BOTONES DE ACCIÓN ──────────────────────────────────────────
            // OverflowBar: barra de acciones que se adapta al espacio disponible
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                // ─── BOTÓN CANCELAR ──────────────────────────────────────────
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(texts.cancel),
                ),
                // ─── BOTÓN GUARDAR / ACTUALIZAR ──────────────────────────────
                // Al confirmar, cierra el modal devolviendo el modelo construido
                FilledButton.icon(
                  onPressed: () {
                    //valida todos los campos del formulario; si son válidos, cierra el modal y devuelve un nuevo MovimientoModel con los datos ingresados o editados.
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop(
                        MovimientoModel(
                          id: widget
                              .movimiento
                              ?.id, //null SI ES CREACION, ID EXISTENTE SI ES EDICION
                          userId: widget.userId,
                          tipo: _tipo,
                          descripcion: _descController.text.trim(),
                          valor: double.parse(_valorController.text),
                          fecha:
                              _storedDate, //fecha en formato ISO para guardar en SQLite
                        ),
                      );
                    }
                  },
                  //cambia el icono y el texto del boton segun si es edicion o creacion
                  icon: Icon(isEditing ? Icons.save : Icons.check),
                  label: Text(
                    isEditing ? texts.updateMovement : texts.saveMovement,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
