-- ============================================================
-- SCRIPT: Cuadre de saldos de deuda
-- Calcula e inserta "Abonos Históricos" para que el historial
-- del cliente cuadre con su saldo actual.
-- ============================================================

DO $$
DECLARE
    rec RECORD;
    v_total_fiado NUMERIC;
    v_total_abonos NUMERIC;
    v_diferencia NUMERIC;
BEGIN
    FOR rec IN SELECT id, nombre, saldo_deuda FROM clientes LOOP
        
        -- Suma de todo lo comprado fiado
        SELECT COALESCE(SUM(total_venta), 0) INTO v_total_fiado
        FROM ventas_cabecera 
        WHERE cliente_id = rec.id AND estado = 'Fiado';
        
        -- Suma de abonos existentes
        SELECT COALESCE(SUM(monto), 0) INTO v_total_abonos
        FROM abonos 
        WHERE cliente_id = rec.id;
        
        -- Lo que debería deber matemáticamente vs lo que realmente debe
        v_diferencia := (v_total_fiado - v_total_abonos) - rec.saldo_deuda;
        
        -- Si la diferencia es > 0, significa que hizo pagos en el pasado (del Excel viejo)
        -- que no estaban en la tabla de abonos. Insertamos un abono de ajuste.
        IF v_diferencia > 0 THEN
            INSERT INTO abonos (cliente_id, monto, fecha)
            VALUES (rec.id, v_diferencia, '2026-06-24 00:00:00-05');
            RAISE NOTICE 'Cliente %: Se insertó un abono histórico de %', rec.nombre, v_diferencia;
        END IF;

    END LOOP;
END $$;
