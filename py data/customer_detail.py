import frappe

@frappe.whitelist(allow_guest=False)
def get_customer_details(mobile_no):
    """
    Fetches customer details from the 'Data Received' DocType using direct SQL query.
    """
    try:
        if not mobile_no:
            frappe.throw("Mobile number is required.")

        # Use direct SQL query
        customer_data = frappe.db.sql(
            """
            SELECT full_name, seg_id, city, product_desc, checkdefect_desc, employer
            FROM `tabData Received`
            WHERE mob = %s
            LIMIT 1
            """,
            (mobile_no,),
            as_dict=True
        )

        if customer_data:
            customer = customer_data[0]
            # Apply Title Case formatting
            if customer.get("full_name"):
                customer["full_name"] = customer["full_name"].title()
            if customer.get("product_desc"):
                customer["product_desc"] = customer["product_desc"].title()
            if customer.get("employer"):
                customer["employer"] = customer["employer"].title()

            # Apply seg_id transformation
            if customer.get("seg_id"):
                original_seg_id = customer["seg_id"].upper() # Case-insensitive check
                if original_seg_id == "WL" or original_seg_id == "NDB":
                    customer["seg_id"] = "ETB"
                elif original_seg_id == "OPM":
                    customer["seg_id"] = "NTB"

            # Apply checkdefect_desc transformation
            if customer.get("checkdefect_desc"):
                original_checkdefect_desc = customer["checkdefect_desc"].lower() # Case-insensitive check
                if "resi" in original_checkdefect_desc:
                    customer["checkdefect_desc"] = "Resi Negative"
                elif "biz" in original_checkdefect_desc:
                    customer["checkdefect_desc"] = "Biz Negative"
            return customer
        else:
            return {"message": "No customer found with this mobile number.", "status": "not_found"}

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_customer_details")
        return {"error": str(e), "status": "error"}