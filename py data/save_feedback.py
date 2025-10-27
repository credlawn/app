import frappe

@frappe.whitelist(allow_guest=False)
def save_customer_feedback(mobile_no, remarks, status=None, reference_no=None, user=None, follow_up_date=None, follow_up_time=None):
    """
    Saves customer feedback related to a call.
    """
    try:
        if not mobile_no:
            frappe.throw("Mobile number is required.")

        feedback_doc = frappe.new_doc("Customer Feedback")
        feedback_doc.mobile_no = mobile_no
        feedback_doc.remarks = remarks
        feedback_doc.status = status
        feedback_doc.reference_no = reference_no
        feedback_doc.user = user
        if follow_up_date:
            feedback_doc.follow_up_date = follow_up_date
        if follow_up_time:
            feedback_doc.follow_up_time = follow_up_time
        feedback_doc.insert(ignore_permissions=True)

        return {"success": True, "message": "Feedback saved successfully."}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in save_customer_feedback")
        return {"success": False, "error": str(e), "message": "Failed to save feedback."}
