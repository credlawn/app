import frappe

@frappe.whitelist(allow_guest=False)
def get_pre_approved_leads(user_id, designation):
    """
    Fetches pre-approved leads based on user designation.
    - Branch Managers get all pre-approved leads.
    - Other users get leads assigned to them.
    """
    try:
        if not user_id or not designation:
            frappe.throw("User ID and Designation are required.")

        filters = {
            "data_type": "Pre Approved Leads",
            "lead_status": "New Lead"
        }

        if designation != 'Branch Manager':
            filters["email"] = user_id
            filters["data_status"] = "Allocated"

        fields = [
            "name", 
            "customer_name", 
            "mobile_no", 
            "data_status", 
            "data_type", 
            "employee_name", 
            "email", 
            "remarks", 
            "lead_status", 
            "update_date"
        ]

        leads = frappe.get_all(
            "Calling Data",
            filters=filters,
            fields=fields,
            order_by="creation asc",
            limit_page_length=30
        )

        return leads

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_pre_approved_leads")
        return []

@frappe.whitelist(allow_guest=False)
def get_interested_leads(user_id, designation):
    """
    Fetches interested leads based on user designation.
    """
    try:
        if not user_id or not designation:
            frappe.throw("User ID and Designation are required.")

        filters = {
            "data_type": "Interested Leads",
            "lead_status": "New Lead"
        }

        if designation != 'Branch Manager':
            filters["email"] = user_id
            filters["data_status"] = "Allocated"

        fields = [
            "name", 
            "customer_name", 
            "mobile_no", 
            "data_status", 
            "data_type", 
            "employee_name", 
            "email", 
            "remarks", 
            "lead_status", 
            "update_date"
        ]

        leads = frappe.get_all(
            "Calling Data",
            filters=filters,
            fields=fields,
            order_by="creation asc",
            limit_page_length=40
        )

        return leads

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_interested_leads")
        return []

@frappe.whitelist(allow_guest=False)
def get_normal_leads(user_id, designation):
    """
    Fetches normal leads based on user designation.
    """
    try:
        if not user_id or not designation:
            frappe.throw("User ID and Designation are required.")

        filters = {
            "data_type": "Normal Leads",
            "lead_status": "New Lead"
        }

        if designation != 'Branch Manager':
            filters["email"] = user_id
            filters["data_status"] = "Allocated"

        fields = [
            "name", 
            "customer_name", 
            "mobile_no", 
            "data_status", 
            "data_type", 
            "employee_name", 
            "email", 
            "remarks", 
            "lead_status", 
            "update_date"
        ]

        leads = frappe.get_all(
            "Calling Data",
            filters=filters,
            fields=fields,
            order_by="creation asc",
            limit_page_length=40
        )

        return leads

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_normal_leads")
        return []