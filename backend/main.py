"""Patchworks v2 — FastAPI skeleton.

Pure UPI dual ₹150 site visit fee.
Unlock call + GPS only after both paid.
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid

app = FastAPI(title="Patchworks v2", description="Trust but Verify")

# In-memory store for now (replace with Postgres / Supabase)
site_visits = {}

UPI_ID = "patchworks@upi"  # Super Admin UPI — replace with real
AMOUNT = 150

class InitiateFee(BaseModel):
    job_id: int
    customer_id: int
    pro_id: int

class ConfirmFee(BaseModel):
    site_visit_id: str
    party: str  # "customer" or "pro"
    proof_url: Optional[str] = None

@app.post("/site-visit/initiate")
def initiate_site_visit(data: InitiateFee):
    """Create site visit and return UPI deep link for both parties."""
    sv_id = str(uuid.uuid4())[:8]
    ref = f"PW-SV-{sv_id}"

    site_visits[sv_id] = {
        "id": sv_id,
        "job_id": data.job_id,
        "customer_id": data.customer_id,
        "pro_id": data.pro_id,
        "upi_ref": ref,
        "customer_paid": False,
        "pro_paid": False,
        "status": "pending",
        "created_at": datetime.utcnow().isoformat(),
    }

    upi_link = (
        f"upi://pay?pa={UPI_ID}&pn=Patchworks&am={AMOUNT}&cu=INR&tn={ref}"
    )

    return {
        "site_visit_id": sv_id,
        "upi_ref": ref,
        "amount": AMOUNT,
        "upi_deep_link": upi_link,
        "message": "Both Customer and Pro must pay ₹150. Unlock after both confirmed.",
    }

@app.post("/site-visit/confirm")
def confirm_payment(data: ConfirmFee):
    """Mark one party as paid (manual or after proof upload)."""
    sv = site_visits.get(data.site_visit_id)
    if not sv:
        raise HTTPException(404, "Site visit not found")

    if data.party == "customer":
        sv["customer_paid"] = True
        sv["customer_proof"] = data.proof_url
    elif data.party == "pro":
        sv["pro_paid"] = True
        sv["pro_proof"] = data.proof_url
    else:
        raise HTTPException(400, "party must be customer or pro")

    if sv["customer_paid"] and sv["pro_paid"]:
        sv["status"] = "both_paid"
    elif sv["customer_paid"]:
        sv["status"] = "customer_paid"
    elif sv["pro_paid"]:
        sv["status"] = "pro_paid"

    return {"status": sv["status"], "unlocked": sv["customer_paid"] and sv["pro_paid"]}

@app.get("/site-visit/{sv_id}/status")
def get_status(sv_id: str):
    """Check if call + GPS are unlocked."""
    sv = site_visits.get(sv_id)
    if not sv:
        raise HTTPException(404, "Site visit not found")
    unlocked = sv["customer_paid"] and sv["pro_paid"]
    return {
        "status": sv["status"],
        "unlocked": unlocked,
        "customer_paid": sv["customer_paid"],
        "pro_paid": sv["pro_paid"],
        "message": "Call + GPS unlocked" if unlocked else "Waiting for both ₹150 payments",
    }

@app.get("/")
def root():
    return {"app": "Patchworks v2", "motto": "Trust but Verify"}
