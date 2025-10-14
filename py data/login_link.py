import frappe

@frappe.whitelist(allow_guest=False)
def get_login_links():
    """
    Fetches login links from the 'Bank Links' DocType, sorted by user-defined priority.
    """
    try:
        domain = "https://cipl.me" # Declared domain

        bank_links = frappe.get_all(
            "Bank Links",
            filters={
                "link_for": "Team",
                "default_link": "Yes"
            },
            fields=[
                "link_type",
                "source"
            ]
        )

        # Define the custom order
        custom_order = ["Tata", "Normal", "Swiggy", "Marriott"]

        # Sort bank_links based on custom_order
        # Items not in custom_order will appear after the prioritized items
        bank_links.sort(key=lambda x: custom_order.index(x.get('link_type')) if x.get('link_type') in custom_order else len(custom_order))

        result = []
        for link_data in bank_links:
            link_type = link_data.get("link_type")
            source = link_data.get("source")
            if link_type and source:
                full_link = f"{domain}/{source}"
                result.append({"link_type": link_type, "link": full_link})
        
        return result

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_login_links")
        return {"error": str(e), "status": "error"}