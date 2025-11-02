import frappe
from frappe.utils import get_datetime

@frappe.whitelist(allow_guest=False)
def sync_feedback_data(feedback_list):
    """
    Syncs multiple feedback records from mobile to server.
    Optimized for batch processing to reduce network calls.

    Expected feedback structure:
    {
        "local_id": int,          # Local database ID
        "customer_name": str,     # Customer name
        "lead_frappe_id": str,    # Lead frappe ID
        "follow_up_date": str,    # Follow-up date (YYYY-MM-DD)
        "follow_up_time": str,    # Follow-up time (HH:MM AM/PM)
        "status": str,            # Feedback status
        "remarks": str,           # Remarks/comments
        "user": str,              # User ID
        "timestamp": str,         # Timestamp (ISO format)
        "mobile_no": str          # Mobile number
    }
    """
    if not feedback_list or not isinstance(feedback_list, list):
        frappe.throw("Valid feedback list is required")

    results = []
    for feedback in feedback_list:
        try:
            # Create new Leads Feedback document
            doc = frappe.get_doc({
                "doctype": "Leads Feedback",
                "customer_name": feedback.get("customer_name"),
                "lead_frappe_id": feedback.get("lead_frappe_id"),
                "follow_up_date": feedback.get("follow_up_date"),
                "follow_up_time": feedback.get("follow_up_time"),
                "status": feedback.get("status"),
                "remarks": feedback.get("remarks"),
                "user": feedback.get("user"),
                "timestamp": get_datetime(feedback.get("timestamp")),
                "mobile_no": feedback.get("mobile_no")
            })
            doc.insert()
            frappe.db.commit()
            results.append({
                "status": "success",
                "local_id": feedback.get("local_id"),
                "server_id": doc.name
            })
        except Exception as e:
            frappe.log_error(frappe.get_traceback(), "Feedback Sync Error")
            results.append({
                "status": "error",
                "local_id": feedback.get("local_id"),
                "error": str(e)
            })

    return {"results": results}
