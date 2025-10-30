import frappe

@frappe.whitelist(allow_guest=False)
def get_employee_leads(user_id):
    """
    Fetches leads allocated to a specific user from the 'Leads' DocType.
    """
    if not user_id:
        frappe.throw("User ID is required.")

    # Fetch leads where the 'user' field matches the provided user_id
    # and 'allocation_status' is 'Active' (or whatever your default is)
    leads = frappe.get_list(
        "Leads",
        filters={
            "user": user_id,
            "allocation_status": "Active" # Assuming 'Active' is the default for assigned leads
        },
        fields=[
            "name", # Frappe's unique ID
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
            # Include local-only fields if they are also on the Frappe DocType
            "lead_status",
            "remarks",
            "arn_no",
            "attempted_calls",
            "connected_calls",
            "total_duration",
            "allocation_status",
            "last_synced_at", # Assuming this is also on Frappe for server-side tracking
            "follow_up_date", # New field
            "follow_up_time", # New field
        ],
        limit_page_length=9999 # Fetch all for the user
    )
    return leads

@frappe.whitelist(allow_guest=False)
def update_lead_status_and_details(frappe_id, lead_status, remarks, arn_no, attempted_calls, connected_calls, total_duration, allocation_status, last_synced_at, follow_up_date, follow_up_time):
    """
    Updates a specific lead's status and other details in the 'Leads' DocType.
    This is for syncing changes from the mobile app to the server.
    """
    if not frappe_id:
        frappe.throw("Frappe ID is required to update a lead.")

    try:
        doc = frappe.get_doc("Leads", frappe_id)

        # Update fields that are managed by the mobile app
        doc.lead_status = lead_status
        doc.remarks = remarks
        doc.arn_no = arn_no
        doc.attempted_calls = attempted_calls
        doc.connected_calls = connected_calls
        doc.total_duration = total_duration
        doc.allocation_status = allocation_status # 'Active' or 'Inactive'
        doc.last_synced_at = frappe.utils.get_datetime(last_synced_at) # Convert timestamp to datetime
        doc.follow_up_date = follow_up_date
        doc.follow_up_time = follow_up_time

        doc.save()
        frappe.db.commit()
        return {"status": "success", "message": f"Lead {frappe_id} updated successfully."}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error updating lead status and details")
        frappe.throw(f"Failed to update lead {frappe_id}: {e}")

@frappe.whitelist(allow_guest=False)
def mark_lead_inactive_on_server(frappe_id):
    """
    Marks a lead as 'Inactive' on the server.
    This is used when a lead is no longer assigned to a user on the mobile app.
    """
    if not frappe_id:
        frappe.throw("Frappe ID is required to mark a lead inactive.")

    try:
        doc = frappe.get_doc("Leads", frappe_id)
        doc.allocation_status = "Inactive"
        doc.save()
        frappe.db.commit()
        return {"status": "success", "message": f"Lead {frappe_id} marked inactive successfully."}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error marking lead inactive on server")
        frappe.throw(f"Failed to mark lead {frappe_id} inactive: {e}")
