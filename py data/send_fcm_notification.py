import frappe
import requests
import json
from google.oauth2 import service_account
from google.auth.transport.requests import Request


def get_access_token():
    service_account_path = frappe.conf.get("fcm_service_account_path")
    if not service_account_path:
        return None

    credentials = service_account.Credentials.from_service_account_file(
        service_account_path,
        scopes=["https://www.googleapis.com/auth/firebase.messaging"]
    )

    if not credentials.token or credentials.expired:
        credentials.refresh(Request())

    return credentials.token


@frappe.whitelist(allow_guest=True)
def send_fcm_notification(device_id, title, body, user=None, data_payload=None):
    try:
        fcm_token_doc_name = frappe.db.get_value("FCM Token", {"device_id": device_id}, "name")
        if not fcm_token_doc_name:
            frappe.get_doc({
                "doctype": "FCM Log",
                "title": title,
                "body": body,
                "status": "Failed",
                "device_id": device_id,
                "user": user,
                "response": "No FCM Token Doc found for device",
            }).insert(ignore_permissions=True)
            frappe.db.commit()
            return

        fcm_token = frappe.db.get_value("FCM Token", fcm_token_doc_name, "fcm_token")
        if not fcm_token:
            frappe.get_doc({
                "doctype": "FCM Log",
                "title": title,
                "body": body,
                "status": "Failed",
                "device_id": device_id,
                "user": user,
                "response": "FCM token missing in Token Doc",
            }).insert(ignore_permissions=True)
            frappe.db.commit()
            return

        access_token = get_access_token()
        if not access_token:
            frappe.get_doc({
                "doctype": "FCM Log",
                "title": title,
                "body": body,
                "status": "Failed",
                "device_id": device_id,
                "user": user,
                "response": "FCM Access Token not available",
            }).insert(ignore_permissions=True)
            frappe.db.commit()
            return

        with open(frappe.conf.get("fcm_service_account_path")) as f:
            project_id = json.load(f).get("project_id")

        if not project_id:
            frappe.get_doc({
                "doctype": "FCM Log",
                "title": title,
                "body": body,
                "status": "Failed",
                "device_id": device_id,
                "user": user,
                "response": "Firebase project_id missing",
            }).insert(ignore_permissions=True)
            frappe.db.commit()
            return

        url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
        message_payload = {
            "message": {
                "token": fcm_token,
                "notification": {
                    "title": title,
                    "body": body
                },
                "data": {
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    "title": title,
                    "body": body,
                    "device_id": device_id,
                    **(data_payload if data_payload else {})
                },
                "android": {
                    "priority": "HIGH",
                    "notification": {
                        "channel_id": "default_channel",
                        "default_sound": True,
                        "default_light_settings": True,
                        "default_vibrate_timings": True
                    }
                },
                "apns": {
                    "headers": {"apns-priority": "10"},
                    "payload": {
                        "aps": {
                            "alert": {"title": title, "body": body},
                            "sound": "default"
                        }
                    }
                }
            }
        }

        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
        }

        response = requests.post(url, data=json.dumps(message_payload), headers=headers)
        status = "Success" if response.status_code == 200 else "Failed"

        frappe.get_doc({
            "doctype": "FCM Log",
            "title": title,
            "body": body,
            "status": status,
            "device_id": device_id,
            "user": user,
            "response": response.text,
        }).insert(ignore_permissions=True)
        frappe.db.commit()

    except Exception as e:
        frappe.get_doc({
            "doctype": "FCM Log",
            "title": title,
            "body": body,
            "status": "Failed",
            "device_id": device_id,
            "user": user,
            "response": str(e),
        }).insert(ignore_permissions=True)
        frappe.db.commit()
