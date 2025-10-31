import frappe

@frappe.whitelist(allow_guest=False)
def submit_case_login(customer_name, mobile_no, login_date, ip_status, arn_no, remarks, user):
    try:
        # Create a new DocType record for Case Login
        doc = frappe.new_doc("Case Login") # Assuming "Case Login" is a DocType on the Frappe backend
        # Frappe's 'name' field will be auto-generated.
        doc.customer_name = customer_name
        doc.mobile_no = mobile_no
        doc.login_date = login_date
        doc.ip_status = ip_status
        doc.arn_no = arn_no
        doc.remarks = remarks
        doc.user = user
        doc.insert()
        frappe.db.commit()
        # Return Frappe's generated 'name' field
        return {"status": "success", "message": "Case Login submitted successfully", "frappe_name": doc.name}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Case Login Submission Error")
        return {"status": "error", "message": str(e)}
