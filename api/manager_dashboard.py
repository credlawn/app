import frappe
from frappe.utils import nowdate


@frappe.whitelist(allow_guest=False)
def get_manager_dashboard_data():
    try:
        today = nowdate()

        # Get current year and month
        current_year = frappe.utils.getdate(today).year
        current_month = frappe.utils.getdate(today).month

        # IP Approved counts
        ip_approved_today = frappe.db.count(
            "IP Approved",
            filters={
                "ipa_date": today
            }
        )

        ip_approved_mtd = frappe.db.count(
            "IP Approved",
            filters={
                "ipa_date": ["between", [f"{current_year}-{current_month:02d}-01", today]]
            }
        )

        # IP Decline counts
        ip_decline_today = frappe.db.count(
            "IP Decline",
            filters={
                "login_date": today
            }
        )

        ip_decline_mtd = frappe.db.count(
            "IP Decline",
            filters={
                "login_date": ["between", [f"{current_year}-{current_month:02d}-01", today]]
            }
        )

        return {
            "today": {
                "ip_approved": ip_approved_today,
                "ip_decline": ip_decline_today
            },
            "mtd": {
                "ip_approved": ip_approved_mtd,
                "ip_decline": ip_decline_mtd
            }
        }

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_manager_dashboard_data")
        frappe.throw(f"Failed to fetch manager dashboard data: {e}")
