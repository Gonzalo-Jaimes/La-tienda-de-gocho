
    (function () {
        'use strict';

        // ============================================================
        //  SUPABASE CONNECTION
        // ============================================================
        const SUPABASE_URL = 'https://lpenongoudqujuvbajnx.supabase.co';
        const SUPABASE_KEY = 'sb_publishable_CAfUNW76FcgoyO2wRCFm8w_B09OT2MS';
        const db = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
        let usandoDB = false; // Flag: true si Supabase está conectado

        // ============================================================
        //  DATA LAYER (fallback local si no hay DB)
        // ============================================================
        const EMOJIS = { 'Chocolates': '🍫', 'Palitos': '🥢', 'Galletas': '🍪', 'Mayonesa': '🫙', 'Diablitos': '🥫', 'Combo': '🫓' };
        function getEmoji(nombre) {
            for (const [key, val] of Object.entries(EMOJIS)) {
                if (nombre.toLowerCase().includes(key.toLowerCase())) return val;
            }
            return '📦';
        }

        let PRODUCTOS = [];
        let CLIENTES = [];
        let COMPRAS_HISTORIAL = [
            { fecha: '2026-06-10T10:00:00Z', descripcion: 'Chocolates Lote 1 (4 cajas x12)', monto: 164000 },
            { fecha: '2026-06-10T10:00:00Z', descripcion: 'Galletas (20 paquetes)', monto: 130000 },
            { fecha: '2026-06-14T10:00:00Z', descripcion: 'Mayonesas (1 caja x12)', monto: 62500 },
            { fecha: '2026-06-14T10:00:00Z', descripcion: 'Diablitos (1 caja x12)', monto: 80000 },
            { fecha: '2026-06-18T10:00:00Z', descripcion: 'Chocolates Lote 2 (4 cajas x12)', monto: 144000 },
            { fecha: '2026-06-23T10:00:00Z', descripcion: 'Palitos (1 caja x18)', monto: 20000 },
            { fecha: '2026-06-23T10:00:00Z', descripcion: 'Otros gastos operativos', monto: 46000 }
        ];
        let VENTAS_HISTORIAL = [];
        let abonosRecibidosTotal = 0;

        let carrito = [];
        let clienteSeleccionado = null;
        let deudorActivo = null;

        // Datos locales de respaldo (si Supabase no tiene datos)
        const PRODUCTOS_LOCAL = [
            { id: 'prod-chocolates', nombre: 'Chocolates', costo_unidad: 3000, precio_venta: 4000, stock_actual: 41, es_combo: false, emoji: '🍫' },
            { id: 'prod-palitos', nombre: 'Palitos', costo_unidad: 1111, precio_venta: 2000, stock_actual: 5, es_combo: false, emoji: '🥢' },
            { id: 'prod-galletas', nombre: 'Galletas (Paquete)', costo_unidad: 6500, precio_venta: 10000, stock_actual: 3, es_combo: false, emoji: '🍪' },
            { id: 'prod-mayonesa', nombre: 'Mayonesa Mediana', costo_unidad: 5208, precio_venta: 6000, stock_actual: 4, es_combo: false, emoji: '🫙' },
            { id: 'prod-diablitos', nombre: 'Diablitos Grandes', costo_unidad: 6667, precio_venta: 10000, stock_actual: 3, es_combo: false, emoji: '🥫' },
            { id: 'prod-combo-arepero', nombre: 'Combo Arepero', costo_unidad: 11875, precio_venta: 15000, es_combo: true, emoji: '🫓', componentes: [{ producto_id: 'prod-mayonesa', cantidad: 1 }, { producto_id: 'prod-diablitos', cantidad: 1 }] }
        ];
        const CLIENTES_LOCAL = [
            { id: 'cli-001', nombre: 'Camila', saldo_deuda: 1000 }, { id: 'cli-002', nombre: 'Darling', saldo_deuda: 8000 },
            { id: 'cli-003', nombre: 'Fabian', saldo_deuda: 0 }, { id: 'cli-004', nombre: 'Faysuri', saldo_deuda: 8000 },
            { id: 'cli-005', nombre: 'Julian', saldo_deuda: 18000 }, { id: 'cli-006', nombre: 'Michell', saldo_deuda: 69000 },
            { id: 'cli-009', nombre: 'Nikolee', saldo_deuda: 47000 }, { id: 'cli-013', nombre: 'Jhoani', saldo_deuda: 22000 }
        ];

        // ============================================================
        //  UTILITIES
        // ============================================================
        function formatCurrency(amount) { return '$ ' + Number(amount).toLocaleString('es-CO'); }
        function formatDate(dateString) { const d = new Date(dateString); return d.toLocaleDateString('es-CO') + ' ' + d.toLocaleTimeString('es-CO', {hour:'2-digit', minute:'2-digit'}); }
        function showToast(msg) { const t = document.getElementById('toast'); t.textContent = msg; t.className = 'toast toast--success show'; setTimeout(() => t.classList.remove('show'), 2500); }

        function switchTab(tabId) {
            document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
            document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
            document.getElementById('view-' + tabId).classList.add('active');
            event.currentTarget.classList.add('active');

            if (tabId === 'debtors') renderDeudores();
            if (tabId === 'inventory') renderInventarioList();
            if (tabId === 'summary') { renderHistorialVentas(); renderHistorialCompras(); calcularResumen(); }
        }

        function cerrarModales() { document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('active')); }

        // ============================================================
        //  SUPABASE: CARGAR DATOS
        // ============================================================
        async function cargarDatosDB() {
            try {
                // Cargar productos
                const { data: prods, error: errP } = await db.from('productos').select('*').order('nombre');
                if (errP) throw errP;

                if (prods && prods.length > 0) {
                    usandoDB = true;
                    // Cargar componentes de combos
                    const { data: comps } = await db.from('combo_componentes').select('*');

                    PRODUCTOS = prods.map(p => ({
                        id: p.id,
                        nombre: p.nombre,
                        costo_unidad: Number(p.costo_unidad),
                        precio_venta: Number(p.precio_venta),
                        stock_actual: p.stock_actual,
                        es_combo: p.es_combo,
                        emoji: getEmoji(p.nombre),
                        componentes: p.es_combo ? (comps || []).filter(c => c.combo_id === p.id).map(c => ({ producto_id: c.componente_id, cantidad: c.cantidad })) : undefined
                    }));

                    // Cargar clientes
                    const { data: clis } = await db.from('clientes').select('*').order('nombre');
                    if (clis) CLIENTES = clis.map(c => ({ id: c.id, nombre: c.nombre, saldo_deuda: Number(c.saldo_deuda) }));

                    // Cargar historial de ventas (últimas 50)
                    const { data: ventas } = await db.from('ventas_cabecera').select(`
                        id, fecha, total_venta, estado, metodo_pago,
                        clientes ( nombre ),
                        ventas_detalle ( cantidad, precio_unitario, productos ( nombre ) )
                    `).order('fecha', { ascending: false }).limit(50);

                    if (ventas) {
                        VENTAS_HISTORIAL = ventas.map(v => ({
                            id: v.id,
                            fecha: v.fecha,
                            cliente: v.clientes ? v.clientes.nombre : 'Consumidor Final',
                            desc: (v.ventas_detalle || []).map(d => `${d.productos ? d.productos.nombre : '?'} x${d.cantidad}`).join(', '),
                            total: Number(v.total_venta),
                            estado: v.estado,
                            metodo_pago: v.metodo_pago
                        }));
                    }

                    // Cargar total de abonos
                    const { data: abonos } = await db.from('abonos').select('monto');
                    if (abonos) abonosRecibidosTotal = abonos.reduce((s, a) => s + Number(a.monto), 0);

                    showToast('☁️ Conectado a Supabase');
                } else {
                    throw new Error('Sin datos en DB');
                }
            } catch (e) {
                console.warn('Supabase no disponible, usando datos locales:', e.message);
                usandoDB = false;
                PRODUCTOS = [...PRODUCTOS_LOCAL];
                CLIENTES = [...CLIENTES_LOCAL];
                VENTAS_HISTORIAL = [
                    { fecha: '2026-06-16T15:30:00Z', cliente: 'Julian', desc: 'Galletas (Paquete) x1', total: 10000, estado: 'Fiado', metodo_pago: null },
                    { fecha: '2026-06-16T16:00:00Z', cliente: 'Santiago', desc: 'Combo Arepero x1', total: 15000, estado: 'Pagado', metodo_pago: 'Efectivo' }
                ];
                showToast('📱 Modo local (sin DB)');
            }
        }

        // ============================================================
        //  PRODUCTOS & POS
        // ============================================================
        function getComboStock(prod) {
            if (!prod.es_combo || !prod.componentes) return 0;
            let minStock = Infinity;
            for (const comp of prod.componentes) {
                const c = PRODUCTOS.find(p => p.id === comp.producto_id);
                if (c) minStock = Math.min(minStock, Math.floor(c.stock_actual / comp.cantidad));
            }
            return minStock === Infinity ? 0 : minStock;
        }
        function getEffectiveStock(prod) { return prod.es_combo ? getComboStock(prod) : prod.stock_actual; }

        function renderProducts() {
            const grid = document.getElementById('product-grid'); grid.innerHTML = '';
            PRODUCTOS.forEach(prod => {
                const stock = getEffectiveStock(prod), isOut = stock <= 0;
                const card = document.createElement('div');
                card.className = 'product-card' + (isOut ? ' out-of-stock' : '') + (prod.es_combo ? ' is-combo' : '');
                card.innerHTML = `
                    <span class="product-card__combo-badge">COMBO</span>
                    <div class="product-card__emoji">${prod.emoji || '📦'}</div>
                    <div class="product-card__name">${prod.nombre}</div>
                    <div class="product-card__price">${formatCurrency(prod.precio_venta)}</div>
                    <div class="product-card__stock ${stock>0 && stock<=3 ? 'product-card__stock--low':''}">${isOut ? '⛔ Agotado' : '📦 '+stock+' dispon'}</div>
                `;
                if (!isOut) card.addEventListener('click', () => { agregarAlCarrito(prod.id); if(navigator.vibrate) navigator.vibrate(30); });
                grid.appendChild(card);
            });
        }

        function abrirModalNuevoProducto() {
            document.getElementById('new-prod-name').value = ''; document.getElementById('new-prod-cost').value = '';
            document.getElementById('new-prod-price').value = ''; document.getElementById('new-prod-stock').value = '';
            document.getElementById('modal-product').classList.add('active');
        }

        async function guardarNuevoProducto() {
            const nombre = document.getElementById('new-prod-name').value.trim();
            const costo = parseInt(document.getElementById('new-prod-cost').value) || 0;
            const precio = parseInt(document.getElementById('new-prod-price').value);
            const stock = parseInt(document.getElementById('new-prod-stock').value);

            if (!nombre || isNaN(precio) || isNaN(stock)) { alert('Campos inválidos.'); return; }

            if (usandoDB) {
                const { data, error } = await db.from('productos').insert({
                    nombre, costo_unidad: costo, precio_venta: precio, stock_actual: stock, es_combo: false
                }).select().single();
                if (error) { alert('Error al guardar: ' + error.message); return; }
                PRODUCTOS.push({ id: data.id, nombre: data.nombre, costo_unidad: Number(data.costo_unidad), precio_venta: Number(data.precio_venta), stock_actual: data.stock_actual, es_combo: false, emoji: getEmoji(nombre) });
            } else {
                PRODUCTOS.push({ id: 'prod-new-'+Date.now(), nombre, costo_unidad: costo, precio_venta: precio, stock_actual: stock, es_combo: false, emoji: getEmoji(nombre) });
            }
            cerrarModales(); renderProducts(); showToast('✅ Producto creado');
            if(document.getElementById('view-inventory').classList.contains('active')) renderInventarioList();
        }

        function abrirEditarProducto(id) {
            const p = PRODUCTOS.find(x => x.id === id);
            if (!p) return;
            document.getElementById('edit-prod-id').value = p.id;
            document.getElementById('edit-prod-name').value = p.nombre;
            document.getElementById('edit-prod-cost').value = p.costo_unidad;
            document.getElementById('edit-prod-price').value = p.precio_venta;
            document.getElementById('edit-prod-stock').value = p.stock_actual;
            document.getElementById('modal-edit-product').classList.add('active');
        }

        async function guardarEdicionProducto() {
            const id = document.getElementById('edit-prod-id').value;
            const nombre = document.getElementById('edit-prod-name').value.trim();
            const costo = parseInt(document.getElementById('edit-prod-cost').value) || 0;
            const precio = parseInt(document.getElementById('edit-prod-price').value);
            const stock = parseInt(document.getElementById('edit-prod-stock').value);

            if (!nombre || isNaN(precio) || isNaN(stock)) { alert('Campos inválidos.'); return; }

            const p = PRODUCTOS.find(x => x.id === id);
            if (!p) return;

            if (usandoDB) {
                const { error } = await db.from('productos').update({
                    nombre, costo_unidad: costo, precio_venta: precio, stock_actual: stock
                }).eq('id', id);
                if (error) { alert('Error: ' + error.message); return; }
            }

            p.nombre = nombre;
            p.costo_unidad = costo;
            p.precio_venta = precio;
            p.stock_actual = stock;
            p.emoji = getEmoji(nombre);

            cerrarModales(); renderProducts(); renderInventarioList();
            showToast('✅ Producto actualizado');
        }

        async function eliminarProducto() {
            const id = document.getElementById('edit-prod-id').value;
            if (!confirm('¿Seguro que quieres eliminar este producto? Esto no se puede deshacer.')) return;

            if (usandoDB) {
                const { error } = await db.from('productos').delete().eq('id', id);
                if (error) { alert('Error: No se puede eliminar si hay ventas registradas con este producto. ' + error.message); return; }
            }
            PRODUCTOS = PRODUCTOS.filter(x => x.id !== id);
            cerrarModales(); renderProducts(); renderInventarioList();
            showToast('🗑️ Producto eliminado');
        }

        // ============================================================
        //  CARRITO Y VENTAS
        // ============================================================
        function agregarAlCarrito(prodId) {
            const prod = PRODUCTOS.find(p => p.id === prodId), enC = carrito.find(i => i.producto_id === prodId);
            if ((enC ? enC.cantidad : 0) >= getEffectiveStock(prod)) return;
            if (enC) { enC.cantidad++; enC.subtotal = enC.cantidad * prod.precio_venta; }
            else { carrito.push({ producto_id: prod.id, nombre: prod.nombre, precio_unitario: prod.precio_venta, cantidad: 1, subtotal: prod.precio_venta }); }
            renderCarrito();
        }
        function modificarCantidad(prodId, delta) {
            const item = carrito.find(i => i.producto_id === prodId); if (!item) return;
            const n = item.cantidad + delta;
            if (n <= 0) carrito = carrito.filter(i => i.producto_id !== prodId);
            else if (n <= getEffectiveStock(PRODUCTOS.find(p=>p.id===prodId))) { item.cantidad = n; item.subtotal = n * item.precio_unitario; }
            renderCarrito();
        }

        function renderCarrito() {
            const $i = document.getElementById('cart-items'), $e = document.getElementById('cart-empty'), $s = document.getElementById('cart-summary');
            if (carrito.length === 0) { $e.style.display = 'block'; $i.innerHTML = ''; $s.style.display = 'none'; }
            else {
                $e.style.display = 'none'; $s.style.display = 'block';
                $i.innerHTML = carrito.map(i => `
                    <div class="cart-item">
                        <div class="cart-item__info"><div class="cart-item__name">${i.nombre}</div><div class="cart-item__price">${formatCurrency(i.precio_unitario)}</div></div>
                        <div class="cart-item__controls"><button class="cart-item__btn" onclick="POS.modificarCantidad('${i.producto_id}', -1)">−</button><span class="cart-item__qty">${i.cantidad}</span><button class="cart-item__btn" onclick="POS.modificarCantidad('${i.producto_id}', 1)">+</button></div>
                        <span class="cart-item__subtotal">${formatCurrency(i.subtotal)}</span>
                    </div>`).join('');
                document.getElementById('summary-items').textContent = carrito.reduce((s,i)=>s+i.cantidad,0);
                document.getElementById('summary-total').textContent = formatCurrency(carrito.reduce((s,i)=>s+i.subtotal,0));
            }
            document.getElementById('btn-pagado').disabled = carrito.length === 0;
            document.getElementById('btn-fiado').disabled = carrito.length === 0 || !clienteSeleccionado;
            document.getElementById('btn-clear').disabled = carrito.length === 0;
        }

        // ============================================================
        //  CLIENTES
        // ============================================================
        document.getElementById('client-input').addEventListener('input', e => {
            const q = e.target.value.toLowerCase(), sug = document.getElementById('client-suggestions');
            if(!q) { sug.classList.remove('active'); return; }
            const m = CLIENTES.filter(c => c.nombre.toLowerCase().includes(q));
            if(m.length === 0) sug.innerHTML = `<div class="client-suggestion" onclick="POS.crearCliente('${q}')">➕ Agregar "${q}"</div>`;
            else sug.innerHTML = m.map(c => `<div class="client-suggestion" onclick="POS.seleccionarCliente('${c.id}')"><span>${c.nombre}</span><span class="client-suggestion__debt">${c.saldo_deuda>0?'Debe '+formatCurrency(c.saldo_deuda):'✅'}</span></div>`).join('');
            sug.classList.add('active');
        });
        function seleccionarCliente(id) { clienteSeleccionado = CLIENTES.find(c => c.id === id); document.getElementById('client-input').value = clienteSeleccionado.nombre; document.getElementById('client-suggestions').classList.remove('active'); renderCarrito(); }

        async function crearCliente(n) {
            const nombreClean = n.charAt(0).toUpperCase() + n.slice(1);
            if (usandoDB) {
                const { data, error } = await db.from('clientes').insert({ nombre: nombreClean, saldo_deuda: 0 }).select().single();
                if (error) { alert('Error: ' + error.message); return; }
                const nc = { id: data.id, nombre: data.nombre, saldo_deuda: 0 };
                CLIENTES.push(nc); seleccionarCliente(nc.id);
            } else {
                const nc = { id: 'cli-new-'+Date.now(), nombre: nombreClean, saldo_deuda: 0 };
                CLIENTES.push(nc); seleccionarCliente(nc.id);
            }
        }

        // ============================================================
        //  CONFIRMAR VENTA Y ACTUALIZAR HISTORIALES
        // ============================================================
        document.getElementById('btn-pagado').addEventListener('click', () => abrirModalMetodoPago());
        document.getElementById('btn-fiado').addEventListener('click', () => procesarVenta('Fiado', null));
        document.getElementById('btn-clear').addEventListener('click', () => { carrito=[]; renderCarrito(); showToast('🗑️ Vaciado'); });

        function abrirModalMetodoPago() {
            const total = carrito.reduce((s,i)=>s+i.subtotal,0);
            document.getElementById('metodo-pago-total').textContent = formatCurrency(total);
            document.getElementById('modal-metodo-pago').classList.add('active');
        }

        function confirmarMetodoPago(metodo) {
            cerrarModales();
            procesarVenta('Pagado', metodo);
        }

        async function procesarVenta(estado, metodo_pago) {
            const total = carrito.reduce((s,i)=>s+i.subtotal,0);
            const descVenta = carrito.map(i => `${i.nombre} x${i.cantidad}`).join(', ');

            if (usandoDB) {
                try {
                    // 1. Crear cabecera de venta
                    const { data: venta, error: errV } = await db.from('ventas_cabecera').insert({
                        cliente_id: clienteSeleccionado ? clienteSeleccionado.id : null,
                        total_venta: total,
                        estado: estado,
                        metodo_pago: metodo_pago
                    }).select().single();
                    if (errV) throw errV;

                    // 2. Crear detalles de venta
                    const detalles = carrito.map(i => ({
                        venta_id: venta.id,
                        producto_id: i.producto_id,
                        cantidad: i.cantidad,
                        precio_unitario: i.precio_unitario
                    }));
                    await db.from('ventas_detalle').insert(detalles);

                    // 3. Descontar stock en DB
                    for (const item of carrito) {
                        const p = PRODUCTOS.find(x => x.id === item.producto_id);
                        if (!p.es_combo) {
                            const newStock = p.stock_actual - item.cantidad;
                            await db.from('productos').update({ stock_actual: newStock }).eq('id', p.id);
                            p.stock_actual = newStock;
                        } else if (p.componentes) {
                            for (const c of p.componentes) {
                                const comp = PRODUCTOS.find(x => x.id === c.producto_id);
                                if (comp) {
                                    const newStock = comp.stock_actual - (c.cantidad * item.cantidad);
                                    await db.from('productos').update({ stock_actual: newStock }).eq('id', comp.id);
                                    comp.stock_actual = newStock;
                                }
                            }
                        }
                    }

                    // 4. Actualizar deuda si es fiado
                    if (estado === 'Fiado' && clienteSeleccionado) {
                        const newDeuda = clienteSeleccionado.saldo_deuda + total;
                        await db.from('clientes').update({ saldo_deuda: newDeuda }).eq('id', clienteSeleccionado.id);
                        clienteSeleccionado.saldo_deuda = newDeuda;
                    }
                } catch (e) {
                    alert('Error al registrar venta: ' + e.message);
                    return;
                }
            } else {
                // Modo local: descontar stock
                carrito.forEach(i => {
                    const p = PRODUCTOS.find(x => x.id === i.producto_id);
                    if (!p.es_combo) { p.stock_actual -= i.cantidad; }
                    else if (p.componentes) { p.componentes.forEach(c => { const comp = PRODUCTOS.find(x => x.id === c.producto_id); if(comp) comp.stock_actual -= (c.cantidad * i.cantidad); }); }
                });
                if (estado === 'Fiado' && clienteSeleccionado) clienteSeleccionado.saldo_deuda += total;
            }

            // Registrar en historial local (para mostrar sin recargar)
            VENTAS_HISTORIAL.unshift({
                fecha: new Date().toISOString(),
                cliente: clienteSeleccionado ? clienteSeleccionado.nombre : 'Consumidor Final',
                desc: descVenta,
                total: total,
                estado: estado,
                metodo_pago: metodo_pago
            });

            carrito = []; clienteSeleccionado = null; document.getElementById('client-input').value = '';
            renderCarrito(); renderProducts();
            if (navigator.vibrate) navigator.vibrate(100);
            showToast(estado === 'Pagado' ? `✅ Venta (${metodo_pago})` : '📋 Venta fiada');
        }

        // ============================================================
        //  DEUDORES & ABONOS
        // ============================================================
        function renderDeudores() {
            const list = CLIENTES.filter(c => c.saldo_deuda > 0).sort((a,b) => b.saldo_deuda - a.saldo_deuda);
            document.getElementById('debtors-list').innerHTML = list.length === 0 
                ? `<div style="text-align:center; color:var(--text-muted); padding: 40px 0;">🎉 Nadie debe nada.</div>`
                : list.map(c => `<div class="debtor-card" onclick="POS.verDetalleDeudor('${c.id}')">
                    <div><div class="debtor-card__name">${c.nombre}</div><div class="debtor-card__debt">${formatCurrency(c.saldo_deuda)}</div></div>
                    <button class="debtor-card__btn" onclick="event.stopPropagation(); POS.iniciarAbono('${c.id}')">Abonar</button>
                </div>`).join('');
        }
        function iniciarAbono(id) { deudorActivo = CLIENTES.find(c => c.id === id); document.getElementById('payment-client-name').textContent = deudorActivo.nombre; document.getElementById('payment-client-debt').textContent = formatCurrency(deudorActivo.saldo_deuda); document.getElementById('payment-amount').value = ''; document.getElementById('modal-payment').classList.add('active'); }

        async function verDetalleDeudor(id) {
            const cliente = CLIENTES.find(c => c.id === id);
            if (!cliente) return;
            document.getElementById('debtor-detail-name').textContent = cliente.nombre;
            document.getElementById('debtor-detail-total').textContent = formatCurrency(cliente.saldo_deuda);
            deudorActivo = cliente;

            const listEl = document.getElementById('debtor-detail-list');
            listEl.innerHTML = '<div style="text-align:center; color:var(--text-muted); padding: 20px;">Calculando saldos...</div>';
            document.getElementById('modal-debtor-detail').classList.add('active');

            if (usandoDB) {
                try {
                    // Solo necesitamos las ventas fiadas, ordenadas de la MÁS VIEJA a la MÁS NUEVA
                    const { data: ventas } = await db.from('ventas_cabecera').select(`
                        id, fecha, total_venta,
                        ventas_detalle ( cantidad, productos ( nombre ) )
                    `).eq('cliente_id', id).eq('estado', 'Fiado').order('fecha', { ascending: true });

                    const totalFiadosHist = (ventas || []).reduce((sum, v) => sum + Number(v.total_venta), 0);
                    let totalPagado = totalFiadosHist - cliente.saldo_deuda;
                    
                    let itemsAMostrar = [];

                    // Si totalPagado es negativo, significa que debe más de lo que hay registrado en ventas fiadas
                    // Esto pasa por deudas iniciales del Excel que no tenían detalle de productos.
                    if (totalPagado < 0) {
                        itemsAMostrar.push({
                            desc: 'Deuda anterior (Sin detallar)',
                            fecha: null,
                            saldo_restante: Math.abs(totalPagado)
                        });
                        totalPagado = 0; // Ya no hay abonos que descontar a las ventas
                    }

                    // Recorremos de la más vieja a la más nueva
                    if (ventas) {
                        for (const v of ventas) {
                            const desc = (v.ventas_detalle || []).map(d => `${d.productos ? d.productos.nombre : '?'} x${d.cantidad}`).join(', ');
                            
                            if (totalPagado >= v.total_venta) {
                                // Esta venta ya fue totalmente pagada con abonos, la ignoramos
                                totalPagado -= v.total_venta;
                            } else if (totalPagado > 0) {
                                // Esta venta fue parcialmente pagada
                                const saldoRestante = v.total_venta - totalPagado;
                                itemsAMostrar.push({ desc: desc + ' (Abonado en parte)', fecha: v.fecha, saldo_restante: saldoRestante });
                                totalPagado = 0;
                            } else {
                                // Esta venta está totalmente sin pagar
                                itemsAMostrar.push({ desc: desc, fecha: v.fecha, saldo_restante: v.total_venta });
                            }
                        }
                    }

                    // Invertimos para mostrar lo más nuevo arriba
                    itemsAMostrar.reverse();

                    if (itemsAMostrar.length > 0) {
                        listEl.innerHTML = itemsAMostrar.map(h => `
                            <div class="debtor-detail-item">
                                <div class="debtor-detail-item__left">
                                    <span class="debtor-detail-item__prod">${h.desc}</span>
                                    ${h.fecha ? `<span class="debtor-detail-item__date">${formatDate(h.fecha)}</span>` : ''}
                                </div>
                                <span class="debtor-detail-item__val">${formatCurrency(h.saldo_restante)}</span>
                            </div>
                        `).join('');
                    } else {
                        listEl.innerHTML = '<div style="text-align:center; color:var(--text-muted); padding: 20px;">La deuda parece ser 0</div>';
                    }
                } catch (e) {
                    listEl.innerHTML = '<div style="color:var(--accent-danger); padding: 20px;">Error al calcular: ' + e.message + '</div>';
                }
            } else {
                listEl.innerHTML = '<div style="text-align:center; color:var(--text-muted); padding: 20px;">Solo disponible con conexión a base de datos</div>';
            }
        }

        function iniciarAbonoDesdeDetalle() {
            cerrarModales();
            iniciarAbono(deudorActivo.id);
        }

        async function confirmarAbono() {
            const monto = parseInt(document.getElementById('payment-amount').value);
            if (!monto || monto <= 0 || monto > deudorActivo.saldo_deuda) { alert('Monto inválido.'); return; }

            if (usandoDB) {
                try {
                    // Insertar abono
                    const { error: errA } = await db.from('abonos').insert({ cliente_id: deudorActivo.id, monto: monto });
                    if (errA) throw errA;
                    // Actualizar saldo del cliente
                    const newDeuda = deudorActivo.saldo_deuda - monto;
                    const { error: errC } = await db.from('clientes').update({ saldo_deuda: newDeuda }).eq('id', deudorActivo.id);
                    if (errC) throw errC;
                    deudorActivo.saldo_deuda = newDeuda;
                } catch (e) {
                    alert('Error: ' + e.message); return;
                }
            } else {
                deudorActivo.saldo_deuda -= monto;
            }

            abonosRecibidosTotal += monto;
            cerrarModales(); renderDeudores(); showToast(`✅ Abono registrado`);
        }

        // ============================================================
        //  INVENTARIO MODULE
        // ============================================================
        function renderInventarioList() {
            const list = document.getElementById('inventory-list'); list.innerHTML = '';
            PRODUCTOS.forEach(p => {
                const stock = getEffectiveStock(p);
                const isCombo = p.es_combo;
                const costoReal = isCombo ? (p.componentes || []).reduce((sum, c) => { const comp = PRODUCTOS.find(x=>x.id===c.producto_id); return sum + (comp ? comp.costo_unidad * c.cantidad : 0); }, 0) : p.costo_unidad;
                const ganancia = p.precio_venta - costoReal;
                const margen = costoReal > 0 ? Math.round((ganancia / p.precio_venta) * 100) : 100;

                list.innerHTML += `
                    <div class="inv-card">
                        <div class="inv-card__header">
                            <div class="inv-card__title">${p.emoji || '📦'} ${p.nombre} ${isCombo?'<span style="font-size:0.6rem; color:var(--accent-primary); margin-left:6px;">COMBO</span>':''}</div>
                            <div class="inv-card__stock ${stock<=0?'inv-card__stock--out':''}">${stock} unds</div>
                        </div>
                        <div class="inv-grid">
                            <div class="inv-stat"><span class="inv-stat__label">Costo</span><span class="inv-stat__val inv-stat__val--cost">${formatCurrency(costoReal)}</span></div>
                            <div class="inv-stat"><span class="inv-stat__label">Precio Venta</span><span class="inv-stat__val">${formatCurrency(p.precio_venta)}</span></div>
                            <div class="inv-stat"><span class="inv-stat__label">Ganancia Neta</span><span class="inv-stat__val inv-stat__val--profit">${formatCurrency(ganancia)}</span></div>
                            <div class="inv-stat"><span class="inv-stat__label">Margen</span><span class="inv-stat__val">${margen}%</span></div>
                        </div>
                        ${!isCombo ? `<button class="inv-card__edit" onclick="POS.abrirEditarProducto('${p.id}')">✏️ Editar</button>` : ''}
                    </div>
                `;
            });
        }

        // ============================================================
        //  DASHBOARD & HISTORIALES
        // ============================================================
        function switchHistorial(tipo) {
            document.getElementById('hist-ventas-container').style.display = tipo === 'ventas' ? 'block' : 'none';
            document.getElementById('hist-compras-container').style.display = tipo === 'compras' ? 'block' : 'none';
        }

        function renderHistorialVentas() {
            const list = document.getElementById('hist-ventas-list');
            if (VENTAS_HISTORIAL.length === 0) {
                list.innerHTML = '<div style="text-align:center; color:var(--text-muted); padding: 30px 0;">No hay ventas registradas</div>';
                return;
            }
            list.innerHTML = VENTAS_HISTORIAL.map(v => {
                const metodoBadge = v.metodo_pago ? `<span class="hist-item__badge ${v.metodo_pago==='Efectivo'?'badge--efectivo':'badge--transferencia'}">${v.metodo_pago==='Efectivo'?'💵':'📱'} ${v.metodo_pago}</span>` : '';
                return `
                <div class="hist-item ${v.estado==='Pagado'?'hist-item--sale-pagado':'hist-item--sale-fiado'}">
                    <div class="hist-item__left">
                        <span class="hist-item__title">${v.cliente}</span>
                        <span class="hist-item__desc">${v.desc}</span>
                    </div>
                    <div class="hist-item__right">
                        <span class="hist-item__val">${formatCurrency(v.total)}</span>
                        <div class="hist-item__badges">
                            <span class="hist-item__badge ${v.estado==='Pagado'?'badge--pagado':'badge--fiado'}">${v.estado}</span>
                            ${metodoBadge}
                        </div>
                    </div>
                </div>`;
            }).join('');
        }

        function renderHistorialCompras() {
            const list = document.getElementById('hist-compras-list');
            list.innerHTML = COMPRAS_HISTORIAL.map(c => `
                <div class="hist-item hist-item--purchase">
                    <div class="hist-item__left">
                        <span class="hist-item__title">${c.descripcion}</span>
                        <span class="hist-item__desc">${formatDate(c.fecha)}</span>
                    </div>
                    <div class="hist-item__right">
                        <span class="hist-item__val" style="color:var(--accent-warning);">- ${formatCurrency(c.monto)}</span>
                    </div>
                </div>
            `).join('');
        }

        function calcularResumen() {
            const inversion = COMPRAS_HISTORIAL.reduce((s, c) => s + c.monto, 0);
            
            let ventasPagadas = 0;
            let ventasTotales = 0;
            VENTAS_HISTORIAL.forEach(v => {
                ventasTotales += v.total;
                if(v.estado === 'Pagado') ventasPagadas += v.total;
            });

            const cobradoEnMano = ventasPagadas + abonosRecibidosTotal;
            const fiadoPorCobrar = CLIENTES.reduce((s, c) => s + c.saldo_deuda, 0);

            let valorInventarioCosto = 0;
            PRODUCTOS.forEach(p => { if(!p.es_combo) valorInventarioCosto += (p.stock_actual * p.costo_unidad); });
            const costoMercanciaVendida = inversion - valorInventarioCosto;
            let gananciaNeta = ventasTotales - costoMercanciaVendida;
            const margen = ventasTotales > 0 ? Math.round((gananciaNeta / ventasTotales) * 100) : 0;

            document.getElementById('dash-invest').textContent = formatCurrency(inversion);
            document.getElementById('dash-collected').textContent = formatCurrency(cobradoEnMano);
            document.getElementById('dash-debt').textContent = formatCurrency(fiadoPorCobrar);
            document.getElementById('dash-sales').textContent = formatCurrency(ventasTotales);
            document.getElementById('dash-profit').textContent = formatCurrency(gananciaNeta);
            document.getElementById('dash-profit-margin').textContent = `${margen}% Margen`;
        }

        // ============================================================
        //  INIT — Cargar datos de Supabase y renderizar
        // ============================================================
        async function init() {
            renderCarrito(); // Mostrar carrito vacío inmediatamente
            await cargarDatosDB();
            renderProducts();
        }
        init();

        window.POS = {
            switchTab, abrirModalNuevoProducto, cerrarModales, guardarNuevoProducto,
            modificarCantidad, crearCliente, seleccionarCliente, iniciarAbono, confirmarAbono,
            switchHistorial, confirmarMetodoPago,
            abrirEditarProducto, guardarEdicionProducto, eliminarProducto,
            verDetalleDeudor, iniciarAbonoDesdeDetalle
        };
    })();
    