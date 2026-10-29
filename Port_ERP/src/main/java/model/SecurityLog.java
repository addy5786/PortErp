package model;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import operation_implementor.SecurityLog_implementor;

public class SecurityLog {

    private int log_id;
    private String name;
    private String role_name;
    private LocalDateTime entry_time;
    private LocalDateTime exit_time;

    // =========================
    // GETTERS AND SETTERS
    // =========================

    public int getLog_id() {
        return log_id;
    }

    public void setLog_id(int log_id) {
        this.log_id = log_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRole_name() {
        return role_name;
    }

    public void setRole_name(String role_name) {
        this.role_name = role_name;
    }

    public LocalDateTime getEntry_time() {
        return entry_time;
    }

    public void setEntry_time(LocalDateTime entry_time) {
        this.entry_time = entry_time;
    }

    public LocalDateTime getExit_time() {
        return exit_time;
    }

    public void setExit_time(LocalDateTime exit_time) {
        this.exit_time = exit_time;
    }

    public String getSessionDuration() {
        if (exit_time == null) {
            return "Session Running";
        }
        if (entry_time != null) {
            long minutes = ChronoUnit.MINUTES.between(entry_time, exit_time);
            return minutes + " mins";
        }
        return "";
    }

    // Static bridge method to fetch data
    public static List<SecurityLog> searchLogs(String keyword, String fromDate, String toDate, String role) {
        SecurityLog_implementor obj = new SecurityLog_implementor();
        return obj.searchLogs(keyword, fromDate, toDate, role);
    }
}