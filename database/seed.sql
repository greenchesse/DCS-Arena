USE dcs_arena;

INSERT INTO sports (name, description, capacity, bracket_type)
VALUES
  ('Mobile Legends', '5v5 MOBA', 64, 'double_elimination'),
  ('Valorant', '5v5 Tactical FPS', 64, 'double_elimination'),
  ('Chess', '1v1 board game', 128, 'round_robin')
ON DUPLICATE KEY UPDATE
  description = VALUES(description),
  capacity = VALUES(capacity),
  bracket_type = VALUES(bracket_type);

INSERT INTO venues (name, location, capacity)
VALUES
  ('Gymnasium', 'ADNU Main Campus', 500),
  ('Computer Lab 1', 'CCS Building', 120),
  ('Covered Courts', 'Athletics Complex', 300)
ON DUPLICATE KEY UPDATE
  location = VALUES(location),
  capacity = VALUES(capacity);
