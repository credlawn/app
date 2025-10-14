import frappe
import json
from datetime import datetime

@frappe.whitelist(allow_guest=False)
def process_raw_call_logs():
    try:
        raw_call_logs_to_process = frappe.get_all(
            "Raw Call Log",
            filters={"is_processed": ("!=", 1)},
            fields=["name", "user", "raw_log"]
        )

        if not raw_call_logs_to_process:
            return {"message": "No unprocessed Raw Call Log records found."}

        processed_count = 0
        for raw_log_doc in raw_call_logs_to_process:
            raw_log_docname = raw_log_doc.name
            user_id = raw_log_doc.user
            raw_log_json_string = raw_log_doc.raw_log

            if not raw_log_json_string:
                continue

            try:
                call_log_entries = json.loads(raw_log_json_string)
            except json.JSONDecodeError:
                continue

            for entry_json_string in call_log_entries:
                try:
                    entry = json.loads(entry_json_string)
                    timestamp_millis = entry.get("timestamp")
                    if timestamp_millis is None:
                        continue

                    call_datetime = datetime.fromtimestamp(timestamp_millis / 1000)

                    raw_number = entry.get("number")
                    mobile_no = None
                    if raw_number:
                        mobile_no = str(raw_number)[-10:]

                    employee_code = ""
                    employee_name = ""

                    employee_record = frappe.get_all(
                        "Employee",
                        filters={"email": user_id, "employment_status": "Active"},
                        fields=["employee_code", "employee_name"],
                        limit=1
                    )

                    if not employee_record:
                        employee_record = frappe.get_all(
                            "Employee",
                            filters={"email": user_id},
                            fields=["employee_code", "employee_name"],
                            limit=1
                        )
                    
                    if employee_record:
                        employee_code = employee_record[0].get("employee_code", "")
                        employee_name = employee_record[0].get("employee_name", "")

                    existing_spare_data = frappe.get_all(
                        "Spare Data",
                        filters={
                            "mobile_no": mobile_no,
                            "call_date": call_datetime.strftime("%Y-%m-%d"),
                            "call_time": call_datetime.strftime("%H:%M:%S"),
                            "duration": entry.get("duration"),
                            "call_type": entry.get("callType")
                        },
                        limit=1
                    )

                    if existing_spare_data:
                        continue

                    new_spare_data = frappe.new_doc("Spare Data")
                    new_spare_data.user = user_id
                    new_spare_data.call_date = call_datetime.strftime("%Y-%m-%d")
                    new_spare_data.call_time = call_datetime.strftime("%H-%M-%S")
                    new_spare_data.call_type = entry.get("callType")
                    new_spare_data.person_name = entry.get("name")
                    new_spare_data.duration = entry.get("duration")
                    new_spare_data.mobile_no = mobile_no
                    new_spare_data.employee_code = employee_code
                    new_spare_data.employee_name = employee_name
                    new_spare_data.insert(ignore_permissions=True)

                except Exception:
                    pass

            frappe.db.set_value("Raw Call Log", raw_log_docname, "is_processed", 1)
            processed_count += 1
            frappe.db.commit()

        return {"message": f"Successfully processed {processed_count} Raw Call Log records."}

    except Exception:
        frappe.db.rollback()
        return {"error": "An error occurred during processing.", "message": "An error occurred during processing."}
