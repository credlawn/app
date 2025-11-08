import frappe
import json

@frappe.whitelist(allow_guest=False)
def get_user_fcm_logs(page=1, search_term=None, status=None, filter_type=None):
    try:
        user_id = frappe.session.user
        if not user_id:
            frappe.throw("User not logged in.")

        page_size = 30
        offset = (int(page) - 1) * page_size

        conditions = "WHERE user = %s"
        params = [user_id]

        if status and status in ['Unread', 'Read']:
            conditions += " AND message_status = %s"
            params.append(status)

        if status == 'Read' and not filter_type:
            # For Read tab, exclude messages that belong to Report and IPA tabs
            conditions += " AND LOWER(title) NOT LIKE %s AND LOWER(title) NOT LIKE %s"
            params.extend(['%work%', '%ip%'])

        if filter_type == 'work_summary':
            conditions += " AND LOWER(title) LIKE %s AND DATE(creation) = CURDATE()"
            params.append('%work%')
        elif filter_type == 'ip_approved':
            conditions += " AND LOWER(title) LIKE %s AND DATE(creation) = CURDATE()"
            params.append('%ip%')



        if search_term:
            conditions += " AND (title LIKE %s OR body LIKE %s)"
            params.extend([f"%{search_term}%", f"%{search_term}%"])

        query = f"""
            SELECT name, title, body, message_status, creation
            FROM `tabFCM Log`
            {conditions}
            ORDER BY creation DESC
            LIMIT %s
            OFFSET %s
        """
        params.extend([page_size, offset])

        logs = frappe.db.sql(query, tuple(params), as_dict=True)

        return logs

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_user_fcm_logs")
        frappe.local.response.http_status_code = 500
        return {"error": str(e), "status": "error"}

@frappe.whitelist()
def update_fcm_log_status():
    try:
        data = json.loads(frappe.request.data)
        log_id = data.get("log_id")

        if not log_id:
            frappe.response["message"] = "Log ID is required."
            frappe.response.http_status_code = 400
            return

        doc = frappe.get_doc("FCM Log", log_id)
        doc.message_status = "Read"
        doc.save(ignore_permissions=True)
        frappe.db.commit()

        frappe.response["message"] = "FCM log status updated successfully."
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in update_fcm_log_status")
        frappe.response["message"] = str(e)
        frappe.response.http_status_code = 500

@frappe.whitelist()
def mark_fcm_log_screen_read():
    try:
        data = json.loads(frappe.request.data)
        log_id = data.get("log_id")

        if not log_id:
            frappe.response["message"] = "Log ID is required."
            frappe.response.http_status_code = 400
            return

        doc = frappe.get_doc("FCM Log", log_id)
        doc.screen_read = "Yes"
        doc.save(ignore_permissions=True)
        frappe.db.commit()

        frappe.response["message"] = "FCM log screen read marked successfully."
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in mark_fcm_log_screen_read")
        frappe.response["message"] = str(e)
        frappe.response.http_status_code = 500

@frappe.whitelist(allow_guest=False)
def get_unread_fcm_logs_count():
    try:
        user_id = frappe.session.user
        if not user_id:
            frappe.throw("User not logged in.")

        count = frappe.db.count("FCM Log", {
            "user": user_id,
            "message_status": "Unread"
        })

        return {"unread_count": count}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_unread_fcm_logs_count")
        frappe.local.response.http_status_code = 500
        return {"error": str(e), "status": "error"}
