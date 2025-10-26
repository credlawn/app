import frappe

@frappe.whitelist(allow_guest=True)
def save_fcm_token():
    try:
        data = frappe.local.form_dict
        user = data.get('user')
        fcm_token = data.get('fcm_token')
        device_id = data.get('device_id')

        if not fcm_token or not device_id:
            frappe.response["message"] = "FCM token and Device ID are required."
            frappe.response["status_code"] = 400
            return

        filters = {"device_id": device_id}
        
        existing_token_name = frappe.db.exists("FCM Token", filters)

        if existing_token_name:
            doc = frappe.get_doc("FCM Token", existing_token_name)
            doc.fcm_token = fcm_token
            if user:
                doc.user = user
            # If user is not provided, we do not clear an existing user link.
            # The link should only be established or changed if 'user' is explicitly sent.
            doc.save(ignore_permissions=True)
            message = "FCM token updated successfully."
        else:
            new_token_doc = frappe.new_doc("FCM Token")
            new_token_doc.fcm_token = fcm_token
            new_token_doc.device_id = device_id
            if user:
                new_token_doc.user = user
            new_token_doc.insert(ignore_permissions=True)
            message = "FCM token saved successfully."

        frappe.db.commit()
        frappe.response["message"] = message
        frappe.log_error(f"FCM token operation successful: {message}", "Save FCM Token")

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Save FCM Token Error")
        frappe.response["message"] = "An error occurred while saving the FCM token."
        frappe.response["status_code"] = 500
