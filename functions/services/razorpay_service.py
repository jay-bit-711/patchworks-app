from typing import Any, Dict

import razorpay

from services.config import RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET


def client() -> razorpay.Client:
    if not RAZORPAY_KEY_ID or not RAZORPAY_KEY_SECRET:
        raise ValueError('Razorpay keys missing')
    return razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))


def create_order(amount_paise: int, receipt: str, notes: Dict[str, str]) -> Dict[str, Any]:
    # Live mode keys are loaded from .env. For test mode, use rzp_test_* keys.
    return client().order.create(
        {
            'amount': amount_paise,
            'currency': 'INR',
            'receipt': receipt,
            'payment_capture': 1,
            'notes': notes,
        }
    )


def transfer_commission(builder_account_id: str, amount_paise: int, project_id: str) -> Dict[str, Any]:
    # Hidden commission transfer (10%) is backend-only and never returned to homeowner UI.
    return client().transfer.create(
        {
            'account': builder_account_id,
            'amount': amount_paise,
            'currency': 'INR',
            'notes': {'project_id': project_id, 'type': 'builder_settlement_after_commission'},
        }
    )
