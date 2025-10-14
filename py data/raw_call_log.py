import frappe
from frappe.utils import getdate, get_datetime, now_datetime
import json

@frappe.whitelist(allow_guest=False)
def add_sync_record(sync_date, sync_time, user_email, all_raw_logs_json):
    """
    Creates a single Raw Call Log document containing all raw logs for a sync operation.
    """
    try:
        new_log = frappe.new_doc("Raw Call Log")
        new_log.sync_date = sync_date
        new_log.sync_time = sync_time
        new_log.user = user_email
        new_log.raw_log = all_raw_logs_json # Store all logs as a single JSON string
        new_log.insert(ignore_permissions=True)
        
        return {"success": True, "docname": new_log.name}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in add_sync_record")
        return {"success": False, "error": str(e)}

