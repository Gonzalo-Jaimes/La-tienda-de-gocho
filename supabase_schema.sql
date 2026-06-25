-- ============================================================
-- Mini-ERP "La Tienda del Gocho" - Supabase Schema
-- Generado: 2026-06-23
-- ============================================================
-- Ejecutar este script en el SQL Editor de Supabase.
-- Crea las 5 tablas principales + 1 tabla auxiliar para combos.

-- Habilitar la extensión uuid-ossp para generar UUIDs automáticamente
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. TABLA: productos
-- ============================================================
CREATE TABLE productos (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre      TEXT NOT NULL,
    costo_unidad NUMERIC(12, 2) NOT NULL DEFAULT 0,
    precio_venta NUMERIC(12, 2) NOT NULL DEFAULT 0,
    stock_actual INTEGER NOT NULL DEFAULT 0,
    es_combo    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE productos IS 'Catálogo de productos de la tienda. es_combo=true indica que es un producto compuesto.';
COMMENT ON COLUMN productos.es_combo IS 'Si es TRUE, al vender se descuenta el stock de los componentes en combo_componentes.';

-- ============================================================
-- 1b. TABLA AUXILIAR: combo_componentes
-- Relación N:N entre un combo y sus productos componentes.
-- ============================================================
CREATE TABLE combo_componentes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    combo_id        UUID NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    componente_id   UUID NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    cantidad        INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT uq_combo_componente UNIQUE (combo_id, componente_id)
);

COMMENT ON TABLE combo_componentes IS 'Define qué productos individuales componen un combo y en qué cantidad.';

-- ============================================================
-- 2. TABLA: clientes
-- ============================================================
CREATE TABLE clientes (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre      TEXT NOT NULL,
    saldo_deuda NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE clientes IS 'Clientes de la tienda. saldo_deuda acumula lo que deben globalmente.';
COMMENT ON COLUMN clientes.saldo_deuda IS 'Acumulador del total que debe el cliente. Se incrementa al fiar y se reduce con abonos.';

-- ============================================================
-- 3. TABLA: ventas_cabecera
-- ============================================================
CREATE TABLE ventas_cabecera (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id   UUID REFERENCES clientes(id) ON DELETE SET NULL,
    fecha        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_venta  NUMERIC(12, 2) NOT NULL DEFAULT 0,
    estado       TEXT NOT NULL DEFAULT 'Pagado' CHECK (estado IN ('Pagado', 'Fiado')),
    metodo_pago  TEXT CHECK (metodo_pago IN ('Efectivo', 'Transferencia')),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE ventas_cabecera IS 'Encabezado de cada transacción de venta.';
COMMENT ON COLUMN ventas_cabecera.estado IS 'Pagado = cobrado al momento. Fiado = se suma a la deuda del cliente.';
COMMENT ON COLUMN ventas_cabecera.metodo_pago IS 'Efectivo o Transferencia. NULL cuando estado es Fiado.';

-- ============================================================
-- 4. TABLA: ventas_detalle
-- ============================================================
CREATE TABLE ventas_detalle (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id        UUID NOT NULL REFERENCES ventas_cabecera(id) ON DELETE CASCADE,
    producto_id     UUID NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    cantidad        INTEGER NOT NULL DEFAULT 1,
    precio_unitario NUMERIC(12, 2) NOT NULL DEFAULT 0
);

COMMENT ON TABLE ventas_detalle IS 'Líneas de detalle de cada venta. Cada fila = un producto vendido.';

-- ============================================================
-- 5. TABLA: abonos
-- ============================================================
CREATE TABLE abonos (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id  UUID NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    monto       NUMERIC(12, 2) NOT NULL CHECK (monto > 0),
    fecha       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE abonos IS 'Pagos parciales o totales que hace un cliente para reducir su saldo_deuda.';

-- ============================================================
-- ÍNDICES para mejorar rendimiento de consultas frecuentes
-- ============================================================
CREATE INDEX idx_ventas_cabecera_cliente  ON ventas_cabecera(cliente_id);
CREATE INDEX idx_ventas_cabecera_fecha    ON ventas_cabecera(fecha DESC);
CREATE INDEX idx_ventas_detalle_venta     ON ventas_detalle(venta_id);
CREATE INDEX idx_ventas_detalle_producto  ON ventas_detalle(producto_id);
CREATE INDEX idx_abonos_cliente           ON abonos(cliente_id);
CREATE INDEX idx_abonos_fecha             ON abonos(fecha DESC);
CREATE INDEX idx_combo_componentes_combo  ON combo_componentes(combo_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Habilitamos RLS pero creamos políticas permisivas
-- para acceso autenticado. Ajustar según necesidad.
-- ============================================================
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_cabecera ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_detalle ENABLE ROW LEVEL SECURITY;
ALTER TABLE abonos ENABLE ROW LEVEL SECURITY;
ALTER TABLE combo_componentes ENABLE ROW LEVEL SECURITY;

-- Políticas permisivas para que cualquier usuario autenticado
-- pueda leer y escribir (ajustar en producción)
CREATE POLICY "Acceso completo productos" ON productos
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Acceso completo clientes" ON clientes
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Acceso completo ventas_cabecera" ON ventas_cabecera
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Acceso completo ventas_detalle" ON ventas_detalle
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Acceso completo abonos" ON abonos
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Acceso completo combo_componentes" ON combo_componentes
    FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- DATOS SEMILLA (SEED) - Extraídos del Excel V8
-- ============================================================

-- --- Productos ---
INSERT INTO productos (nombre, costo_unidad, precio_venta, stock_actual, es_combo) VALUES
    ('Chocolates', 3000, 4000, 41, FALSE),
    ('Palitos', 1111.11, 2000, 5, FALSE),
    ('Galletas (Paquete)', 6500, 10000, 3, FALSE),
    ('Mayonesa Mediana', 5208.33, 6000, 4, FALSE),
    ('Diablitos Grandes', 6666.67, 10000, 3, FALSE),
    ('Combo Arepero (Mayo+Diab)', 11875, 15000, 0, TRUE);

-- --- Componentes del Combo Arepero ---
-- (Se hace con subconsultas para referenciar los UUIDs generados automáticamente)
INSERT INTO combo_componentes (combo_id, componente_id, cantidad)
SELECT
    (SELECT id FROM productos WHERE nombre = 'Combo Arepero (Mayo+Diab)'),
    (SELECT id FROM productos WHERE nombre = 'Mayonesa Mediana'),
    1;

INSERT INTO combo_componentes (combo_id, componente_id, cantidad)
SELECT
    (SELECT id FROM productos WHERE nombre = 'Combo Arepero (Mayo+Diab)'),
    (SELECT id FROM productos WHERE nombre = 'Diablitos Grandes'),
    1;

-- --- Clientes (con saldos actuales del Excel) ---
INSERT INTO clientes (nombre, saldo_deuda) VALUES
    ('Camila', 1000),
    ('Darling', 8000),
    ('Fabian', 0),
    ('Faysuri', 8000),
    ('Julian', 18000),
    ('Michell', 69000),
    ('Motato', 0),
    ('Nando', 8000),
    ('Nikolee', 47000),
    ('Santiago', 0),
    ('Yerimar', 8000),
    ('Luis', 0),
    ('Jhoani', 22000);
