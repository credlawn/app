import frappe
from frappe.utils import getdate, get_datetime, now_datetime, format_time, add_days, time_diff_in_seconds
from datetime import datetime, timedelta

@frappe.whitelist(allow_guest=True)
def get_daily_attendance_summary(user_id, from_date, to_date):
    try:
        if not user_id or not from_date or not to_date:
            frappe.throw("User ID, From Date, and To Date are required.")

        from_date = getdate(from_date)
        to_date = getdate(to_date)

        office_start_time = None
        office_end_time = None
        try:
            geofence_config = frappe.get_all(
                "Attendance Geofence",
                filters={"is_active": 1},
                fields=["office_start_time", "office_end_time"],
                limit=1
            )
            if geofence_config:
                office_start_time = get_datetime(f"2000-01-01 {geofence_config[0].office_start_time}").time()
                office_end_time = get_datetime(f"2000-01-01 {geofence_config[0].office_end_time}").time()
        except Exception as e:
            frappe.log_error(frappe.get_traceback(), "Error fetching geofence config")

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
            in_time = "N/A"
            out_time = "N/A"
            status = "Absent"

            punches_for_day = daily_punches.get(date_str, [])

            if punches_for_day:
                in_punches = [p for p in punches_for_day if p.log_type == "In"]
                out_punches = [p for p in punches_for_day if p.log_type == "Out"]

                if in_punches:
                    in_time = format_time(in_punches[0].punch_time)
                if out_punches:
                    out_time = format_time(out_punches[-1].punch_time)

                if in_time != "N/A" and out_time != "N/A":
                    status = "Present"
                    try:
                        current_in_dt = get_datetime(f"{date_str} {in_time}")
                        current_out_dt = get_datetime(f"{date_str} {out_time}")

                        is_late_come = False
                        is_early_left = False

                        if office_start_time:
                            office_start_dt = get_datetime(f"{date_str} {office_start_time}")
                            if current_in_dt > office_start_dt:
                                is_late_come = True

                        if office_end_time:
                            office_end_dt = get_datetime(f"{date_str} {office_end_time}")
                            if current_out_dt < office_end_dt:
                                is_early_left = True

                        if is_late_come and is_early_left:
                            status = "Late Come, Early Left"
                        elif is_late_come:
                            status = "Late Come"
                        elif is_early_left:
                            status = "Early Left"
                    except Exception as e:
                        frappe.log_error(frappe.get_traceback(), f"Time parsing error for {date_str}")

                elif in_time != "N/A" and out_time == "N/A":
                    status = "Incomplete (No Out Punch)"
                elif in_time == "N/A" and out_time != "N/A":
                    status = "Incomplete (No In Punch)"

            summary_list.append({
                "attendance_date": date_str,
                "in_time": in_time,
                "out_time": out_time,
                "status": status
            })

            current_date = add_days(current_date, 1)

        return summary_list

    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Error in get_daily_attendance_summary")
        return []
