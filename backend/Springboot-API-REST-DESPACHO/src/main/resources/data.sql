INSERT INTO despacho (id_despacho, fecha_despacho, patente_camion, intento, id_compra, direccion_compra, valor_compra, despachado)
VALUES
  (1, '2026-06-18', 'ABCD12', 1, 1, 'Av. Providencia 1234, Santiago', 159990, false),
  (2, '2026-06-18', 'EFGH34', 1, 2, 'Los Leones 455, Santiago', 89990, false)
ON DUPLICATE KEY UPDATE
  fecha_despacho = VALUES(fecha_despacho),
  patente_camion = VALUES(patente_camion),
  intento = VALUES(intento),
  id_compra = VALUES(id_compra),
  direccion_compra = VALUES(direccion_compra),
  valor_compra = VALUES(valor_compra),
  despachado = VALUES(despachado);

UPDATE despacho_seq SET next_val = 3 WHERE next_val < 3;