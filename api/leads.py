import frappe
from frappe.utils import now_datetime


@frappe.whitelist(allow_guest=False)
def get_employee_leads(user_id):
    if not user_id:
        frappe.throw("User ID is required.")

    return frappe.get_list(
        "Leads",
        filters={
            "user": user_id,
            "allocation_status": "Active"
        },
        fields=[
            "name",
            "allocation_date",
            "user",
            "customer_name",
            "mobile_no",
            "city",
            "employer",
            "segment",
            "decline_reason",
            "product",
            "data_code",
            "lead_status",
            "remarks",
            "arn_no",
            "attempted_calls",
            "connected_calls",
            "total_duration",
            "allocation_status",
            "last_modified_at",
            "follow_up_date",
            "follow_up_time",
            "bank_status",
            "bank_status_date",
            "remove_lead",
        ],
        limit_page_length=9999
    )


@frappe.whitelist(allow_guest=False)
def update_lead_status_and_details(
    frappe_id,
    lead_status,
    remarks,
    arn_no,
    attempted_calls,
    connected_calls,
    total_duration,
    allocation_status,
    follow_up_date,
    follow_up_time,
    last_modified_at
):
    if not frappe_id:
        frappe.throw("Frappe ID is required to update a lead.")

    try:
        frappe.flags.in_import = True
        doc = frappe.get_doc("Leads", frappe_id)

        doc.lead_status = lead_status
        doc.remarks = remarks
        doc.arn_no = arn_no
        doc.attempted_calls = attempted_calls
        doc.connected_calls = connected_calls
        doc.total_duration = total_duration
        doc.allocation_status = allocation_status
        doc.follow_up_date = follow_up_date
        doc.follow_up_time = follow_up_time
        doc.last_modified_at = last_modified_at

        try:
            doc.save(ignore_permissions=True, ignore_version=True)
            frappe.db.commit()
        except frappe.exceptions.TimestampMismatchError:
            pass

        frappe.flags.in_import = False
        return {"status": "success", "message": f"Lead {frappe_id} updated successfully."}
    except Exception as e:
        frappe.flags.in_import = False
        if "TimestampMismatchError" not in str(e):
            frappe.log_error(frappe.get_traceback(), "Error updating lead status and details")
        frappe.throw(f"Failed to update lead {frappe_id}: {e}")


@frappe.whitelist(allow_guest=False)
def mark_lead_inactive_on_server(frappe_id):
    if not frappe_id:
        frappe.throw("Frappe ID is required to mark a lead inactive.")

    try:
        frappe.flags.in_import = True

        doc = frappe.get_doc("Leads", frappe_id)
        doc.allocation_status = "Inactive"
        doc.last_modified_at = now_datetime()

        try:
            doc.save(ignore_permissions=True, ignore_version=True)
            frappe.db.commit()
        except frappe.exceptions.TimestampMismatchError:
            pass

        frappe.flags.in_import = False
        return {"status": "success", "message": f"Lead {frappe_id} marked inactive successfully."}
    except Exception as e:
        frappe.flags.in_import = False
        if "TimestampMismatchError" not in str(e):
            frappe.log_error(frappe.get_traceback(), "Error marking lead inactive on server")
        frappe.throw(f"Failed to mark lead {frappe_id} inactive: {e}")
