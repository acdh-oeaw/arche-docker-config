#!/bin/bash
echo 'BEGIN; UPDATE resources SET transaction_id = NULL WHERE transaction_id IS NOT NULL; DELETE FROM transactions; COMMIT;' | psql

