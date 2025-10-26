import frappe

@frappe.whitelist(allow_guest=False)
def get_user_fcm_logs(page=1, search_term=None):
    """
    Fetches paginated and searchable FCM Log entries for the currently logged-in user.

    :param page: The page number to fetch (1-indexed).
    :param search_term: An optional term to search for in the title and body.
    """
    try:
        user_id = frappe.session.user
        if not user_id:
            frappe.throw("User not logged in.")

        page_size = 30
        offset = (int(page) - 1) * page_size

        conditions = "WHERE user = %s"
        params = [user_id]

        if search_term:
            conditions += " AND (title LIKE %s OR body LIKE %s)"
            params.extend([f"%{search_term}%", f"%{search_term}%"])

        query = f"""
            SELECT title, body, status, creation
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
