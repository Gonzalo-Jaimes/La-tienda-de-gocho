# Plan de Implementación: Inventario, Historiales y Resumen Financiero

Este plan describe la incorporación de los módulos restantes del Excel al sistema web actual (`index.html`).

## Open Questions
Ninguna por el momento. Los cálculos financieros se basarán en las fórmulas estándar de ganancias y pérdidas.

## Proposed Changes

Vamos a modificar `index.html` para agregar nuevas vistas (Tabs) y la lógica de cálculo financiero.

### 1. Sistema de Navegación (Bottom Nav)
- Expandir la barra inferior para incluir 4 botones:
  1. 🛒 POS (Ventas)
  2. 📒 Deudores
  3. 📦 Inventario
  4. 📊 Resumen

### 2. Módulo de Inventario (`#view-inventory`)
- Crear una vista que muestre una lista de todos los productos.
- Cada tarjeta de producto mostrará:
  - Nombre
  - Costo por unidad
  - Precio de venta
  - Ganancia por unidad (Monto y %)
  - Stock Actual
- La lista se generará dinámicamente a partir del array `PRODUCTOS`.

### 3. Módulo de Resumen Financiero (`#view-summary`)
- **Tarjetas de Métricas (Dashboard):**
  - **Inversión (Egresos):** Suma del historial de compras.
  - **En Mano (Cobrado):** Ventas pagadas + Abonos.
  - **Por Cobrar (Fiado):** Suma total de deudas de clientes.
  - **Ventas Totales:** Suma de todo lo vendido.
  - **Ganancia Neta:** (Ventas Totales - Costo de la mercancía vendida). Se mostrará el monto en Bs. y el % de margen.
- **Acordeones o Pestañas Internas para Historiales:**
  - **Historial de Ventas:** Lista de transacciones (quién compró, qué, cantidad, estado). Se actualizará dinámicamente cuando se haga una venta en el POS.
  - **Historial de Compras (Inversiones):** Lista de gastos e inversiones iniciales.

### 4. Lógica JavaScript (Mock de Datos)
- Agregar arrays en memoria para `VENTAS_HISTORIAL` y `COMPRAS_HISTORIAL` simulando los datos del Excel.
- Actualizar la función de `confirmarVenta()` para que, además de descontar stock, inserte un registro en `VENTAS_HISTORIAL` para que el resumen se actualice en tiempo real.
- Crear funciones de cálculo: `calcularResumenFinanciero()`.

## Verification Plan

### Manual Verification
1.  **Navegación:** Comprobar que los 4 botones del menú inferior funcionan y cambian de vista correctamente.
2.  **Inventario:** Verificar que los cálculos de ganancia por unidad coinciden con los precios establecidos.
3.  **Resumen:** 
    - Realizar una venta "Pagada" en el POS y verificar que la métrica "En Mano" y "Ventas Totales" aumentan.
    - Realizar una venta "Fiada" y verificar que la métrica "Por Cobrar" y "Ventas Totales" aumentan, pero "En Mano" no.
4.  **Historiales:** Comprobar que las nuevas ventas aparecen listadas en el historial de ventas dentro de la pestaña Resumen.
