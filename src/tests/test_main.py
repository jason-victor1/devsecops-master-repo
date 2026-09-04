from datetime import datetime, timezone
import uuid

from fastapi.testclient import TestClient

from app.main import API_SECRET_KEY, app

client = TestClient(app)


def test_healthz_endpoint() -> None:
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {
        "status": "healthy",
        "service": "event-ingestion-api",
    }


def test_ready_endpoint() -> None:
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json() == {"status": "ready", "storage_layer": "connected"}


def test_ingest_event_authorized() -> None:
    event_id = str(uuid.uuid4())
    payload = {
        "event_id": event_id,
        "event_type": "security.auth.login_success",
        "source": "auth-microservice",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "payload": {
            "user_id": "usr_991823",
            "ip_address": "192.168.1.10",
            "session_id": "sess_872391283",
        },
    }
    response = client.post(
        "/v1/events",
        json=payload,
        headers={"X-API-Key": API_SECRET_KEY},
    )
    assert response.status_code == 202
    data = response.json()
    assert data["status"] == "accepted"
    assert data["event_id"] == event_id
    assert "processed_at" in data


def test_ingest_event_unauthorized() -> None:
    payload = {
        "event_id": str(uuid.uuid4()),
        "event_type": "security.auth.login_failed",
        "source": "auth-microservice",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "payload": {"attempt": 1},
    }
    response = client.post(
        "/v1/events",
        json=payload,
        headers={"X-API-Key": "invalid-token"},
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid or missing API Authentication Token"


def test_ingest_event_invalid_schema() -> None:
    payload = {
        "event_id": "not-a-valid-uuid",
        "event_type": "x",  # Too short (min_length=3)
        "source": "",
        "timestamp": "invalid-timestamp",
        "payload": "not-a-dict",
    }
    response = client.post(
        "/v1/events",
        json=payload,
        headers={"X-API-Key": API_SECRET_KEY},
    )
    assert response.status_code == 422
