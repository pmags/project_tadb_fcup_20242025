#!/bin/bash

echo "Attempting to connect to PostgreSQL database..."

# Database
if psql -h localhost -U postgres -d postgres -c "\q"; then
  echo "Successfully connected to the PostgreSQL database."
else
  echo "Failed to connect to the PostgreSQL database."
  exit 1
fi

echo "Attempting to run YAP..."

# YAP
if yap -?; then
  echo "Successfully connected to the yap."
else
  echo "Failed to connect to the yap."
  exit 1
fi

echo "All container initialization checks passed."
exit 0