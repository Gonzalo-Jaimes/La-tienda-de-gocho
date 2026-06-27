-- 1. Eliminar los registros de "Daniel Vega"
DO $$ 
DECLARE
  vega_id UUID;
BEGIN
  SELECT id INTO vega_id FROM clientes WHERE nombre = 'Daniel Vega' LIMIT 1;
  IF vega_id IS NOT NULL THEN
    -- Borrar detalles de las ventas de Daniel Vega
    DELETE FROM ventas_detalle WHERE venta_id IN (SELECT id FROM ventas_cabecera WHERE cliente_id = vega_id);
    -- Borrar las cabeceras de ventas de Daniel Vega
    DELETE FROM ventas_cabecera WHERE cliente_id = vega_id;
    -- Borrar abonos si los hubiera
    DELETE FROM abonos WHERE cliente_id = vega_id;
    -- Finalmente borrar el cliente
    DELETE FROM clientes WHERE id = vega_id;
  END IF;
END $$;

-- 2. Crear tabla de compras/gastos
CREATE TABLE IF NOT EXISTS compras_mercancia (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha TIMESTAMPTZ DEFAULT NOW(),
    descripcion TEXT NOT NULL,
    monto NUMERIC NOT NULL
);

-- Habilitar RLS para la nueva tabla y crear política permisiva
ALTER TABLE compras_mercancia ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acceso completo compras_mercancia" ON compras_mercancia
    FOR ALL USING (true) WITH CHECK (true);

-- Migrar el historial hardcodeado a la nueva tabla
INSERT INTO compras_mercancia (fecha, descripcion, monto) VALUES
('2026-06-10 10:00:00+00', 'Chocolates Lote 1 (4 cajas x12)', 164000),
('2026-06-10 10:00:00+00', 'Galletas (20 paquetes)', 130000),
('2026-06-14 10:00:00+00', 'Mayonesas (1 caja x12)', 62500),
('2026-06-14 10:00:00+00', 'Diablitos (1 caja x12)', 80000),
('2026-06-18 10:00:00+00', 'Chocolates Lote 2 (4 cajas x12)', 144000),
('2026-06-23 10:00:00+00', 'Palitos (1 caja x18)', 20000),
('2026-06-23 10:00:00+00', 'Otros gastos operativos', 46000),
('2026-06-24 10:00:00+00', 'Cajas de Chocolate Por Mayor (4 cajas)', 144000);

-- 3. Agregar columna vendedor a ventas_cabecera
ALTER TABLE ventas_cabecera ADD COLUMN IF NOT EXISTS vendedor TEXT DEFAULT 'Gonzalo';
