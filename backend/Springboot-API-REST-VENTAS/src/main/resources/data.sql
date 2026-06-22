INSERT INTO venta (id_venta, direccion_compra, fecha_compra, valor_compra, despacho_generado)
VALUES
  (1, 'Av. Providencia 1234, Santiago', '2026-06-17', 159990, false),
  (2, 'Los Leones 455, Santiago', '2026-06-17', 89990, false),
  (3, 'Av. Concon Renaca 220, Vina del Mar', '2026-06-17', 249990, false)
ON DUPLICATE KEY UPDATE
  direccion_compra = VALUES(direccion_compra),
  fecha_compra = VALUES(fecha_compra),
  valor_compra = VALUES(valor_compra),
  despacho_generado = VALUES(despacho_generado);

UPDATE venta_seq SET next_val = 4 WHERE next_val < 4;