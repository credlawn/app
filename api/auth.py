import frappe
from frappe.core.doctype.user.user import generate_keys

@frappe.whitelist(methods=["GET"])
def get_api_keys():
    """Get API keys and profile data in one call"""
    user = frappe.session.user
    if user == "Guest":
        frappe.throw("Login required", frappe.PermissionError)

    user_doc = frappe.get_doc("User", user)

    if not user_doc.api_key or not user_doc.api_secret:
        frappe.throw("API keys not found for this user")

    # Fetch and validate profile data
    profile_data = frappe.get_list(
        "Employee",
        filters={"email": user_doc.email},
        fields=[
            "name", "employee_name", "joining_date", "employee_code",
            "date_of_birth", "gender", "department", "designation",
            "mobile_no", "email", "age", "tenure", "role"
        ],
        limit_page_length=1
    )

    return {
        "api_key": user_doc.api_key,
        "api_secret": user_doc.get_password("api_secret"),
        "profile": profile_data[0] if profile_data else {}
    }
