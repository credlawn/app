import frappe

@frappe.whitelist(allow_guest=False)
def delete_follow_up(mobile_no):
    """
    Deletes a follow-up record based on the mobile number.
    """
    try:
        if not mobile_no:
            frappe.throw("Mobile number is required.")

        # Find the follow-up record to delete
        follow_up_name = frappe.db.get_value(
            "Follow Up",
            {"mobile_no": mobile_no},
            "name"
        )

        if follow_up_name:
            frappe.delete_doc("Follow Up", follow_up_name, ignore_permissions=True)
            return {"success": True, "message": "Follow-up deleted successfully."}
        else:
            return {"success": False, "message": "Follow-up not found for this mobile number.", "mobile_no": mobile_no}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in delete_follow_up")
        return {"success": False, "error": str(e), "message": "Failed to delete follow-up."}
