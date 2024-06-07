#!/bin/sh

echo "Loading data from S3..."
curl -sLo ./aws.json https://cloudx-json-bucket.s3.amazonaws.com/raw/aws/aws.json \
&& curl -sLo ./azure.json https://cloudx-json-bucket.s3.amazonaws.com/raw/azure/eastus.json \
&& curl -sLo ./google.json https://cloudx-json-bucket.s3.amazonaws.com/raw/google/global.json \
|| { echo "Failed to download JSON files. Exiting..."; exit 1; }

# Keep trying to load data if the database is still initializing.
until poetry run python ./import_data.py aws aws.json; do
  echo "Import failed for AWS, retrying in 5 seconds..."
  sleep 5
done

until poetry run python ./import_data.py azure azure.json; do
  echo "Import failed for Azure, retrying in 5 seconds..."
  sleep 5
done

until poetry run python ./import_data.py google google.json; do
  echo "Import failed for Google, retrying in 5 seconds..."
  sleep 5
done

poetry run uvicorn cid.main:app --host 0.0.0.0 --port 80
