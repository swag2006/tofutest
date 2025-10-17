from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok", "region": os.getenv("AWS_DEFAULT_REGION", "unknown")}

@app.get("/")
def root():
    return {"message": "API running", "bucket": os.getenv("S3_BUCKET_NAME"), "table": os.getenv("DYNAMODB_TABLE_NAME")}

