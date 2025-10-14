import frappe
from frappe.utils import now_datetime

@frappe.whitelist(allow_guest=False)
def log_error_from_app(error_message, error_context=None, user_id=None):
    """
    Logs an error from the mobile application to Frappe's Error Log.
    """
    try:
        title = f"App Error - {user_id or 'Unknown User'} - {now_datetime().strftime('%Y-%m-%d %H:%M:%S')}"
        message = f"Error Message: {error_message}\nContext: {error_context or 'N/A'}"
        
        frappe.log_error(message=message, title=title)
        return {"success": True}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in log_error_from_app")
        return {"success": False, "error": str(e)}

