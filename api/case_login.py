import frappe

@frappe.whitelist(allow_guest=False)
def submit_case_login(customer_name, mobile_no, login_date, ip_status, arn_no, remarks, user, sync_id):
    try:
        existing_doc_name = frappe.db.get_value(
            "Case Login",
            {"sync_id": sync_id},
            "name"
        )

        if existing_doc_name:
            doc = frappe.get_doc("Case Login", existing_doc_name)
            doc.customer_name = customer_name
            doc.mobile_no = mobile_no
            doc.login_date = login_date
            doc.ip_status = ip_status
            doc.arn_no = arn_no
            doc.remarks = remarks
            doc.user = user
            doc.save()
            frappe.db.commit()
            return {"status": "success", "message": "Case Login updated successfully", "frappe_name": doc.name}
        else:
            doc = frappe.new_doc("Case Login")
            doc.customer_name = customer_name
            doc.mobile_no = mobile_no
            doc.login_date = login_date
            doc.ip_status = ip_status
            doc.arn_no = arn_no
            doc.remarks = remarks
            doc.user = user
            doc.sync_id = sync_id
            doc.insert()
            frappe.db.commit()
            return {"status": "success", "message": "Case Login submitted successfully", "frappe_name": doc.name}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Case Login Submission Error")
        return {"status": "error", "message": str(e)}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Case Login Submission Error")
        return {"status": "error", "message": str(e)}
