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
            date_str = str(follow_up.follow_up_date or "")
            time_str = str(follow_up.follow_up_time or "00:00:00")
            dt_str = f"{date_str} {time_str}"

            try:
                follow_up_datetime = datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S.%f")
            except ValueError:
                follow_up_datetime = datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S")

            follow_up["status"] = "Missed" if follow_up_datetime < now else "Upcoming"

        return {"success": True, "follow_ups": follow_ups}

    except Exception:
        frappe.log_error(frappe.get_traceback(), "Error in get_follow_ups")
        return {"success": False, "error": frappe.get_traceback()}

@frappe.whitelist(allow_guest=False)
def get_upcoming_follow_ups_count(user_id):
    try:
        if not user_id:
            frappe.throw("User ID is required.")

        now = now_datetime()

        count = frappe.db.count(
            "Follow Up",
            filters={
                "user": user_id,
                "follow_up_date": (">=", now.date()),
                "follow_up_time": (">=", now.time()),
            }
        )

        return {"success": True, "count": count}

    except Exception:
        frappe.log_error(frappe.get_traceback(), "Error in get_upcoming_follow_ups_count")
        return {"success": False, "error": frappe.get_traceback()}
