from typing import Any, Dict, List
from firebase_admin import firestore


def get_db() -> firestore.Client:
    return firestore.client()


def fetch_project(project_id: str) -> Dict[str, Any]:
    snap = get_db().collection('projects').document(project_id).get()
    if not snap.exists:
      raise ValueError('Project not found')
    return snap.to_dict()


def log_whatsapp(payload: Dict[str, Any]) -> None:
    get_db().collection('whatsapp_logs').add(payload)


def list_coverages() -> List[Dict[str, Any]]:
    docs = get_db().collection('coverage_areas').stream()
    return [d.to_dict() for d in docs]


def list_contractors_near_city(city: str) -> List[Dict[str, Any]]:
    docs = get_db().collection('contractors').where('city', '==', city).stream()
    return [d.to_dict() for d in docs]
