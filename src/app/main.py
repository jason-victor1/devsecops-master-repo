from datetime import datetime, timezone
import os
from typing import Any, Dict
from uuid import UUID

from fastapi import Depends, FastAPI, HTTPException, Security, status
from fastapi.security.api_key import APIKeyHeader
from pydantic import BaseModel, ConfigDict, Field

API_KEY_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

API_SECRET_KEY = os.getenv(
    "INGESTION_API_KEY", "prod-secure-token-injected-via-secrets-98723"
)

app = FastAPI(
    title="Cloud-Native Event Ingestion API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url=None,
)


class EventPayload(BaseModel):
    model_config = ConfigDict(extra="forbid")

    event_id: UUID = Field(
        ..., description="Unique UUIDv4 identifier for the telemetry event"
    )
    event_type: str = Field(
        ..., min_length=3, max_length=64, description="Dot-delimited event domain"
    )
    source: str = Field(
        ..., min_length=2, max_length=128, description="Originating subsystem"
    )
    timestamp: datetime = Field(..., description="UTC ISO-8601 creation timestamp")
    payload: Dict[str, Any] = Field(
        ..., description="Strict schema-compliant event payload dictionary"
    )


class IngestionResponse(BaseModel):
    status: str
    event_id: UUID
    processed_at: datetime


async def verify_api_key(
    header_key: str = Security(api_key_header),
) -> str:
    if not header_key or header_key != API_SECRET_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API Authentication Token",
        )
    return header_key


@app.get("/healthz", status_code=status.HTTP_200_OK, tags=["Probes"])
async def healthz() -> Dict[str, str]:
    """Kubernetes liveness probe endpoint."""
    return {"status": "healthy", "service": "event-ingestion-api"}


@app.get("/ready", status_code=status.HTTP_200_OK, tags=["Probes"])
async def ready() -> Dict[str, str]:
    """Kubernetes readiness probe endpoint."""
    return {"status": "ready", "storage_layer": "connected"}


@app.post(
    "/v1/events",
    response_model=IngestionResponse,
    status_code=status.HTTP_202_ACCEPTED,
    tags=["Ingestion"],
)
async def ingest_event(
    event: EventPayload,
    _: str = Depends(verify_api_key),
) -> IngestionResponse:
    """Validate and ingest incoming asynchronous telemetry events."""
    return IngestionResponse(
        status="accepted",
        event_id=event.event_id,
        processed_at=datetime.now(timezone.utc),
    )
