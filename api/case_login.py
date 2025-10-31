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
            return {"status": "success", "message": "Case Login updated successfully", "frappe_id": doc.name}
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
            return {"status": "success", "message": "Case Login submitted successfully", "frappe_id": doc.name}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Case Login Submission Error")
        return {"status": "error", "message": str(e)}

@frappe.whitelist(allow_guest=False)
def get_user_case_logins(user_id):
    try:
        case_logins = frappe.get_list(
            "Case Login",
            filters={
                "user": user_id,
                "app_sync": 1
            },
            fields=[
                "name",
                "sync_id",
                "customer_name",
                "mobile_no",
                "login_date",
                "ip_status",
                "arn_no",
                "remarks",
                "user",
            ]
        )
        formatted_case_logins = []
        for cl in case_logins:
            formatted_cl = {
                "frappe_id": cl.get("name"),
                "sync_id": cl.get("sync_id"),
                "customer_name": cl.get("customer_name"),
                "mobile_no": cl.get("mobile_no"),
                "login_date": cl.get("login_date"),
                "ip_status": cl.get("ip_status"),
                "arn_no": cl.get("arn_no"),
                "remarks": cl.get("remarks"),
                "user": cl.get("user"),
            }
            formatted_case_logins.append(formatted_cl)

        return {"status": "success", "data": formatted_case_logins}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Get User Case Logins Error")
        return {"status": "error", "message": str(e)}
