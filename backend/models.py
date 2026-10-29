"""Clean domain models for Patchworks v2.

Pure UPI site-visit fee (₹150 + ₹150).
No Firebase. Ready for FastAPI + SQLAlchemy or Django.
"""

from datetime import datetime
from enum import Enum
from typing import Optional

# Use SQLAlchemy-style for clarity; adapt to Django if preferred.

class Role(str, Enum):
    HOMEOWNER = "homeowner"
    SKILLED_PRO = "skilled_pro"  # mestri / plumber / electrician / etc.
    ADMIN = "admin"
    SUPERADMIN = "superadmin"

class SiteVisitStatus(str, Enum):
    PENDING = "pending"
    CUSTOMER_PAID = "customer_paid"
    PRO_PAID = "pro_paid"
    BOTH_PAID = "both_paid"  # unlock call + GPS
    CANCELLED = "cancelled"

class SiteVisit:
    """One site visit. Dual ₹150 fee required before contact unlock."""
    id: int
    job_id: int
    customer_id: int
    pro_id: int

    # UPI details
    upi_ref: str  # unique reference e.g. PW-SV-12345
    amount_each: int = 150

    customer_paid: bool = False
    customer_paid_at: Optional[datetime] = None
    customer_proof_url: Optional[str] = None  # optional screenshot

    pro_paid: bool = False
    pro_paid_at: Optional[datetime] = None
    pro_proof_url: Optional[str] = None

    status: SiteVisitStatus = SiteVisitStatus.PENDING
    created_at: datetime

    def is_unlocked(self) -> bool:
        """Call + GPS unlocked only when both have paid."""
        return self.customer_paid and self.pro_paid

class Job:
    """Job request. Negotiation happens outside platform."""
    id: int
    customer_id: int
    description: str
    location_text: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    skill_required: str  # e.g. "plumber", "mason", "electrician"
    status: str = "open"  # open / matched / in_progress / done / cancelled
    created_at: datetime

class User:
    id: int
    phone: str  # +91...
    name: str
    role: Role
    skills: list[str] = []  # for skilled_pro
    upi_id: Optional[str] = None  # for receiving later if needed
    is_active: bool = True
