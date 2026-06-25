# Documentación del Sistema: Mini-ERP "La Tienda del Gocho"

## 1. Contexto y Objetivos
Aplicación web progresiva (Mobile-First) para la gestión de inventario, ventas cruzadas y control de deudas (cuentas por cobrar) de una tienda universitaria. El sistema reemplazará un archivo de Excel para permitir concurrencia (múltiples usuarios registrando datos al mismo tiempo) y desvincular la deuda del producto para asociarla al cliente.

## 2. Stack Tecnológico
*   **Frontend:** HTML5, CSS3, JavaScript Vanilla (manejo del DOM y peticiones asíncronas).
*   **Manejo de Datos en Cliente:** JSON para estructurar el intercambio de datos.
*   **Backend / Base de Datos:** Supabase (PostgreSQL) usando su API REST/cliente JS.
*   **Hosting:** Vercel.
*   **Entorno:** Google Antigravity IDE / GitHub.

## 3. Lógica de Negocio y Reglas Clave
*   **Venta de Combos:** Un producto puede estar compuesto por otros (Ej. "Combo Arepero"). Al vender un combo, el sistema debe descontar el stock de sus componentes individuales (Mayonesa y Diablito).
*   **Cuentas por Cobrar (El mayor dolor de cabeza actual):** La deuda le pertenece al `Cliente`, no a la `Venta` individual. 
    *   Si un cliente compra fiado, su `Saldo_Pendiente` aumenta.
    *   Si un cliente hace un abono general (Ej: $50.000), se descuenta de su `Saldo_Pendiente` global, sin importar qué productos específicos compró en el pasado.

## 4. Estructura de Base de Datos Propuesta (Supabase)

### Tabla: `productos`
*   `id` (UUID, Primary Key)
*   `nombre` (String) - Ej: Chocolates (Lote 2), Galletas (Paquete).
*   `costo_unidad` (Decimal)
*   `precio_venta` (Decimal)
*   `stock_actual` (Integer)
*   `es_combo` (Boolean) - Identificador para lógica de descuento múltiple.

### Tabla: `clientes`
*   `id` (UUID, Primary Key)
*   `nombre` (String)
*   `saldo_deuda` (Decimal) - Acumulador del total que debe.

### Tabla: `ventas_cabecera`
*   `id` (UUID, Primary Key)
*   `cliente_id` (UUID, Foreign Key)
*   `fecha` (Timestamp)
*   `total_venta` (Decimal)
*   `estado` (String) - 'Pagado' o 'Fiado'.

### Tabla: `ventas_detalle`
*   `id` (UUID, Primary Key)
*   `venta_id` (UUID, Foreign Key)
*   `producto_id` (UUID, Foreign Key)
*   `cantidad` (Integer)
*   `precio_unitario` (Decimal)

### Tabla: `abonos`
*   `id` (UUID, Primary Key)
*   `cliente_id` (UUID, Foreign Key)
*   `monto` (Decimal)
*   `fecha` (Timestamp)

## 5. Requerimientos de la Interfaz (UI/UX)
1.  **Punto de Venta (POS):** Pantalla principal con botones grandes para seleccionar productos, carrito de compras temporal en JSON, selección de cliente y botón de cobro (Pagado/Fiado).
2.  **Módulo de Deudores:** Lista de clientes con saldo mayor a 0. Botón directo de "Registrar Abono" que actualice la base de datos inmediatamente.