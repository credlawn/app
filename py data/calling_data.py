import frappe

@frappe.whitelist(allow_guest=False)
def get_employee_leads(user_id):
    """
    Fetches leads for a specific employee with prioritization for 'CNR' and 'New Lead' statuses.
    """
    try:
        if not user_id:
            frappe.throw("User ID is required.")

        fields = [
            "customer_name",
            "mobile_no",
            "lead_status",
            "employee_name"
        ]

        # 1. Fetch 'CNR' leads up to 40
        cnr_leads_filters = {
            "email": user_id,
            "lead_status": "CNR",
            "data_status": "Allocated"
        }
        cnr_leads = frappe.get_all(
            "Calling Data",
            filters=cnr_leads_filters,
            fields=fields,
            order_by="creation asc",
            limit_page_length=40
        )

        # 2. Fetch 'New Lead' leads if 'CNR' leads are less than 40
        new_leads = []
        remaining_limit = 40 - len(cnr_leads)
        if remaining_limit > 0:
            new_leads_filters = {
                "email": user_id,
                "lead_status": "New Lead",
                "data_status": "Allocated"
            }
            new_leads = frappe.get_all(
                "Calling Data",
                filters=new_leads_filters,
                fields=fields,
                order_by="creation asc",
                limit_page_length=remaining_limit
            )

        # Combine prioritized leads
        prioritized_leads = cnr_leads + new_leads

        # 3. Fetch other leads
        other_leads_filters = {
            "email": user_id,
            "lead_status": ["not in", ["New Lead", "CNR"]],
            "data_status": "Allocated"
        }
        other_leads = frappe.get_all(
            "Calling Data",
            filters=other_leads_filters,
            fields=fields,
            order_by="creation asc"
        )

        # Combine all leads
        all_leads = prioritized_leads + other_leads

        return all_leads

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_employee_leads")
        return []