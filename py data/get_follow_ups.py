import frappe
from frappe.utils import now_datetime
from datetime import datetime

@frappe.whitelist(allow_guest=False)
def get_follow_ups(user_id):
    try:
        if not user_id:
            frappe.throw("User ID is required.")

        now = now_datetime()

        follow_ups = frappe.get_all(
            "Follow Up",
            filters={"user": user_id},
            fields=["customer_name", "mobile_no", "follow_up_date", "follow_up_time"],
            order_by="follow_up_date, follow_up_time"
        )

        for follow_up in follow_ups:
            follow_up_datetime = datetime.strptime(
                f"{follow_up.follow_up_date} {follow_up.follow_up_time}", "%Y-%m-%d %H:%M:%S"
            )
            follow_up["status"] = "Missed" if follow_up_datetime < now else "Upcoming"

        return {"success": True, "follow_ups": follow_ups}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_follow_ups")
        return {"success": False, "error": str(e)}
