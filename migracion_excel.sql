-- ============================================================
-- MIGRACIÓN: Datos faltantes del Excel V8
-- Ejecutar en Supabase SQL Editor DESPUÉS del schema inicial
-- ============================================================

-- 1. CLIENTES FALTANTES (todos con deuda $0 ya que pagaron)
INSERT INTO clientes (nombre, saldo_deuda) VALUES
    ('Mamá', 0),
    ('Itza', 0),
    ('Ender', 0),
    ('Emanuel', 0),
    ('Manuel', 0),
    ('Rene', 0),
    ('Jackson', 0),
    ('Ricardo', 0),
    ('Jherson', 0),
    ('Reina', 0),
    ('Nikol Yañez', 0),
    ('Kevin Arevalo', 0),
    ('Angely', 0),
    ('Gabriel', 0),
    ('Alejandro', 0),
    ('Pabon', 0),
    ('Nikol Negra', 0),
    ('Mariangel', 0)
ON CONFLICT DO NOTHING;

-- 2. VENTAS HISTÓRICAS (del Excel - Registro Diario de Ventas)
-- Usamos un bloque DO para poder referenciar IDs dinámicamente
DO $$
DECLARE
    v_venta_id UUID;
    v_cliente_id UUID;
    v_producto_id UUID;
BEGIN

    -- ========== 10/06/2026 ==========

    -- Mamá: Chocolates Lote 1 x2 = $8,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Mamá';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 10:00:00-05', 8000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Itza: Chocolates x2 = $8,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Itza';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 10:15:00-05', 8000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Ender: Chocolates x6 = $24,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Ender';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 10:30:00-05', 24000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 6, 4000);

    -- Ender: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 10:31:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Emanuel: Chocolates x3 = $12,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Emanuel';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 11:00:00-05', 12000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 3, 4000);

    -- Faysuri: Chocolates x2 = $8,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Faysuri';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-10 11:15:00-05', 8000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Yerimar: Chocolates x2 = $8,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Yerimar';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 11:30:00-05', 8000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Michell: Chocolates x7 = $28,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Michell';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-10 12:00:00-05', 28000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 7, 4000);

    -- Michell: Galletas x1 = $10,000 (Fiado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-10 12:01:00-05', 10000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Manuel: Chocolates x2 = $8,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Manuel';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 12:30:00-05', 8000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Darling: Galletas x1 = $10,000 (Fiado, Abono $6,000)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Darling';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-10 13:00:00-05', 10000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Nando: Chocolates x2 = $8,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nando';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 13:30:00-05', 8000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Julian: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Julian';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 14:00:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Julian: Chocolates x1 = $4,000 (Pagado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 14:15:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- Julian: Chocolates x2 = $8,000 (Pagado)
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 14:30:00-05', 8000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Nikolee: Chocolates x5 = $20,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikolee';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 15:00:00-05', 20000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 5, 4000);

    -- Santiago: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Santiago';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-10 15:30:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- ========== 14/06/2026 ==========

    -- Rene: Combo Arepero x1 = $15,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Rene';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Combo%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-14 10:00:00-05', 15000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- ========== 15/06/2026 ==========

    -- Nikolee: Combo Arepero x1 = $15,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikolee';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-15 10:00:00-05', 15000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- Darling: Chocolates x1 = $4,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Darling';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-15 11:00:00-05', 4000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- ========== 16/06/2026 ==========

    -- Jackson: Combo Arepero x1 = $15,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Jackson';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Combo%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 09:00:00-05', 15000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- Ricardo: Chocolates x1 = $4,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Ricardo';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 09:30:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- Motato: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Motato';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 10:00:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Jherson: Combo Arepero x1 = $15,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Jherson';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Combo%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 10:30:00-05', 15000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- Michell: Combo Arepero x1 = $15,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Michell';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-16 11:00:00-05', 15000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- Julian: Galletas x1 = $10,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Julian';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-16 11:30:00-05', 10000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Santiago: Combo Arepero x1 = $15,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Santiago';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Combo%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 12:00:00-05', 15000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- Reina: Combo Arepero x1 = $15,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Reina';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 12:30:00-05', 15000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- Nando: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nando';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 13:00:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Nikol Yañez: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikol Yañez';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 13:30:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Kevin Arevalo: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Kevin Arevalo';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 14:00:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Fabian: Galletas x1 = $10,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Fabian';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 14:30:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Nando: Galletas x1 = $10,000 (Pagado)
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES ((SELECT id FROM clientes WHERE nombre = 'Nando'), '2026-06-16 15:00:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Angely: Combo Arepero x1 = $15,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Angely';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Combo%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-16 16:00:00-05', 15000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 15000);

    -- ========== VENTAS RECIENTES (Lote 2 / Palitos) ==========

    -- Camila: Chocolates x2 = $8,000 (Fiado, Abono $7,000)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Camila';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-20 10:00:00-05', 8000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Gabriel: Chocolates x1 = $4,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Gabriel';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-20 10:30:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- Alejandro: Chocolates x1 = $4,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Alejandro';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-20 11:00:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- Nando: Chocolates x2 = $8,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nando';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-20 11:30:00-05', 8000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 4000);

    -- Fabian: Chocolates x1 = $4,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Fabian';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-20 12:00:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- Luis: Galletas x2 = $20,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Luis';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-20 13:00:00-05', 20000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 10000);

    -- Luis: Diablitos x1 = $10,000 (Pagado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Diablitos%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-20 13:01:00-05', 10000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Nikolee: Galletas x2 = $20,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikolee';
    SELECT id INTO v_producto_id FROM productos WHERE nombre LIKE 'Galletas%';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-21 10:00:00-05', 20000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 10000);

    -- Jhoani: Galletas x1 = $10,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Jhoani';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-21 10:30:00-05', 10000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 10000);

    -- Jhoani: Chocolates x3 = $12,000 (Fiado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-21 10:31:00-05', 12000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 3, 4000);

    -- Michell: Chocolates x4 = $16,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Michell';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-22 10:00:00-05', 16000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 4, 4000);

    -- Nikolee: Chocolates x3 = $12,000 (Fiado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikolee';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado)
    VALUES (v_cliente_id, '2026-06-22 10:30:00-05', 12000, 'Fiado')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 3, 4000);

    -- Pabon: Palitos x2 = $4,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Pabon';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Palitos';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 10:00:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 2000);

    -- Nikol Negra: Palitos x1 = $2,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikol Negra';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 10:30:00-05', 2000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 2000);

    -- Nikol Yañez: Palitos x2 = $4,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nikol Yañez';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 11:00:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 2, 2000);

    -- Mariangel: Palitos x1 = $2,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Mariangel';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 11:30:00-05', 2000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 2000);

    -- Mariangel: Chocolates x1 = $4,000 (Pagado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 11:31:00-05', 4000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 4000);

    -- Nando: Palitos x1 = $2,000 (Pagado)
    SELECT id INTO v_cliente_id FROM clientes WHERE nombre = 'Nando';
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Palitos';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 12:00:00-05', 2000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 1, 2000);

    -- Nando: Chocolates x3 = $12,000 (Pagado)
    SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Chocolates';
    INSERT INTO ventas_cabecera (cliente_id, fecha, total_venta, estado, metodo_pago)
    VALUES (v_cliente_id, '2026-06-23 12:01:00-05', 12000, 'Pagado', 'Efectivo')
    RETURNING id INTO v_venta_id;
    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, 3, 4000);

END $$;

-- 3. ABONOS HISTÓRICOS
-- Darling abonó $6,000
INSERT INTO abonos (cliente_id, monto, fecha)
VALUES (
    (SELECT id FROM clientes WHERE nombre = 'Darling'),
    6000,
    '2026-06-12 10:00:00-05'
);

-- Camila abonó $7,000
INSERT INTO abonos (cliente_id, monto, fecha)
VALUES (
    (SELECT id FROM clientes WHERE nombre = 'Camila'),
    7000,
    '2026-06-22 10:00:00-05'
);

-- 4. VERIFICAR TOTALES
-- Después de ejecutar, estos queries deben coincidir con el Excel:
-- SELECT SUM(total_venta) FROM ventas_cabecera;  -- Debería ser ~$520,000
-- SELECT SUM(total_venta) FROM ventas_cabecera WHERE estado = 'Pagado';  -- ~$331,000
-- SELECT SUM(saldo_deuda) FROM clientes;  -- Debería ser $189,000
