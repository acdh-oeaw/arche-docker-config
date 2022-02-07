#!/bin/bash
echo 'BEGIN; UPDATE resources SET transaction_id = NULL, lock = NULL WHERE transaction_id IS NOT NULL OR lock IS NOT NULL; DELETE FROM transactions; COMMIT;' | psql

