import frappe

@frappe.whitelist(allow_guest=False)
def save_customer_feedback(mobile_no, remarks):
    """
    Saves customer feedback related to a call.
    """
    try:
        if not mobile_no:
            frappe.throw("Mobile number is required.")

        # Assuming a DocType named 'Customer Feedback' exists with fields 'mobile_no' and 'remarks'
        # If not, you might need to create this DocType in Frappe.
        feedback_doc = frappe.new_doc("Customer Feedback")
        feedback_doc.mobile_no = mobile_no
        feedback_doc.remarks = remarks
        feedback_doc.insert(ignore_permissions=True)

        return {"success": True, "message": "Feedback saved successfully."}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in save_customer_feedback")
        return {"success": False, "error": str(e), "message": "Failed to save feedback."}
