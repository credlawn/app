import frappe
from frappe.utils import getdate, get_datetime, format_time, add_days
from datetime import datetime

@frappe.whitelist(allow_guest=True)
def get_daily_attendance_summary(user_id, from_date, to_date):
    try:
        if not user_id or not from_date or not to_date:
            frappe.throw("User ID, From Date, and To Date are required.")

        from_date = getdate(from_date)
        to_date = getdate(to_date)

        # Get holiday list for the date range
        holidays = {}
        try:
            holiday_records = frappe.get_all(
                "Holiday List",
                filters={
                    "date": ["between", [from_date, to_date]]
                },
                fields=["date", "holiday_name"]
            )
            for holiday in holiday_records:
                holidays[str(holiday.date)] = holiday.holiday_name
        except Exception as e:
            frappe.log_error(frappe.get_traceback(), "Error fetching holidays")

        # Get raw attendance records
        try:
            raw_attendance_records = frappe.get_all(
                "Attendance Records",
                filters={
                    "user": user_id,
                    "attendance_date": ["between", [from_date, to_date]]
                },
                fields=["attendance_date", "punch_time", "log_type"],
                order_by="attendance_date desc",
                limit_page_length=9999
            )
        except Exception as e:
            frappe.log_error(frappe.get_traceback(), "Error fetching attendance records")
            return []

        # Group punches by date
        daily_punches = {}
        for record in raw_attendance_records:
            date_str = str(record.attendance_date)
            if date_str not in daily_punches:
                daily_punches[date_str] = []
            daily_punches[date_str].append(record)

        summary_list = []
        current_date = from_date
        while current_date <= to_date:
            date_str = str(current_date)

            # Check if it's a holiday
            if date_str in holidays:
                summary_list.append({
                    "date": date_str,
                    "holiday_name": holidays[date_str]
                })
            else:
                # Get punches for the day
                punches_for_day = daily_punches.get(date_str, [])
                in_time = None
                out_time = None

                if punches_for_day:
                    in_punches = [p for p in punches_for_day if p.log_type == "In"]
                    out_punches = [p for p in punches_for_day if p.log_type == "Out"]

                    if in_punches:
                        in_time = format_time(in_punches[0].punch_time)
                    if out_punches:
                        out_time = format_time(out_punches[-1].punch_time)

                summary_list.append({
                    "date": date_str,
                    "inTime": in_time,
                    "outTime": out_time
                })

            current_date = add_days(current_date, 1)

        return summary_list

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_daily_attendance_summary")
        return []
