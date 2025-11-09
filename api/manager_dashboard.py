import frappe
from frappe.utils import nowdate


@frappe.whitelist(allow_guest=False)
def get_manager_dashboard_data():
    try:
        today = nowdate()

        # Get current year and month
        current_year = frappe.utils.getdate(today).year
        current_month = frappe.utils.getdate(today).month

        # IP Approved counts - Today
        ip_approved_today = frappe.db.count(
            "IP Approved",
            filters={
                "ipa_date": today
            }
        )

        # IP Approved counts - MTD
        ip_approved_mtd = frappe.db.count(
            "IP Approved",
            filters={
                "ipa_date": ["between", [f"{current_year}-{current_month:02d}-01", today]]
            }
        )

        # IP Decline counts - Today
        ip_decline_today = frappe.db.count(
            "IP Decline",
            filters={
                "login_date": today
            }
        )

        # IP Decline counts - MTD
        ip_decline_mtd = frappe.db.count(
            "IP Decline",
            filters={
                "login_date": ["between", [f"{current_year}-{current_month:02d}-01", today]]
            }
        )

        # Employee-wise data for Today
        today_approved_data = frappe.db.sql("""
            SELECT employee_name, COUNT(*) as count
            FROM `tabIP Approved`
            WHERE ipa_date = %s
            GROUP BY employee_name
        """, (today,), as_dict=True)

        today_decline_data = frappe.db.sql("""
            SELECT employee_name, COUNT(*) as count
            FROM `tabIP Decline`
            WHERE login_date = %s
            GROUP BY employee_name
        """, (today,), as_dict=True)

        # Employee-wise data for MTD
        mtd_approved_data = frappe.db.sql("""
            SELECT employee_name, COUNT(*) as count
            FROM `tabIP Approved`
            WHERE YEAR(ipa_date) = %s AND MONTH(ipa_date) = %s
            GROUP BY employee_name
        """, (current_year, current_month), as_dict=True)

        mtd_decline_data = frappe.db.sql("""
            SELECT employee_name, COUNT(*) as count
            FROM `tabIP Decline`
            WHERE YEAR(login_date) = %s AND MONTH(login_date) = %s
            GROUP BY employee_name
        """, (current_year, current_month), as_dict=True)

        # Process employee data
        def process_employee_data(approved_data, decline_data):
            employee_map = {}

            # Add approved counts
            for item in approved_data:
                emp_name = item.employee_name or "Unknown"
                employee_map[emp_name] = {
                    "employee_name": emp_name,
                    "ip_approved": item.count,
                    "ip_decline": 0,
                    "total": item.count
                }

            # Add decline counts
            for item in decline_data:
                emp_name = item.employee_name or "Unknown"
                if emp_name in employee_map:
                    employee_map[emp_name]["ip_decline"] = item.count
                    employee_map[emp_name]["total"] += item.count
                else:
                    employee_map[emp_name] = {
                        "employee_name": emp_name,
                        "ip_approved": 0,
                        "ip_decline": item.count,
                        "total": item.count
                    }

            return list(employee_map.values())

        today_employees = process_employee_data(today_approved_data, today_decline_data)
        mtd_employees = process_employee_data(mtd_approved_data, mtd_decline_data)

        # Sort MTD employees by IP Approved count (high to low)
        mtd_employees.sort(key=lambda x: x["ip_approved"], reverse=True)

        return {
            "today": {
                "summary": {
                    "ip_approved": ip_approved_today,
                    "ip_decline": ip_decline_today
                },
                "employees": today_employees
            },
            "mtd": {
                "summary": {
                    "ip_approved": ip_approved_mtd,
                    "ip_decline": ip_decline_mtd
                },
                "employees": mtd_employees
            }
        }

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_manager_dashboard_data")
        frappe.throw(f"Failed to fetch manager dashboard data: {e}")
