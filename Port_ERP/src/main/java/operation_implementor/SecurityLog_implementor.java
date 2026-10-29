package operation_implementor;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import db_config.GetConnection;
import model.SecurityLog;
import operations.SecurityLog_operation;

public class SecurityLog_implementor implements SecurityLog_operation {

    @Override
    public void viewAllLogs() {}

    @Override
    public void viewActiveLogs() {}

    @Override
    public void viewCompletedLogs() {}

    @Override
    public void searchSecurity(String keyword) {}

    @Override
    public List<SecurityLog> searchLogs(String keyword, String fromDate, String toDate, String role) {
        List<SecurityLog> logs = new ArrayList<>();
        String query = "{CALL search_security_logs(?, ?, ?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(query)) {

            // Parameter 1: Keyword Search
            if (keyword != null && !keyword.trim().isEmpty()) {
                cs.setString(1, keyword.trim());
            } else {
                cs.setNull(1, java.sql.Types.VARCHAR);
            }

            // Parameter 2: Date From
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                cs.setString(2, fromDate.trim());
            } else {
                cs.setNull(2, java.sql.Types.VARCHAR);
            }

            // Parameter 3: Date To
            if (toDate != null && !toDate.trim().isEmpty()) {
                cs.setString(3, toDate.trim());
            } else {
                cs.setNull(3, java.sql.Types.VARCHAR);
            }

            // Parameter 4: System Role Filter
            if (role != null && !role.trim().isEmpty()) {
                cs.setString(4, role.trim());
            } else {
                cs.setNull(4, java.sql.Types.VARCHAR);
            }

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    SecurityLog log = new SecurityLog();
                    log.setLog_id(rs.getInt("log_id"));
                    log.setName(rs.getString("name"));
                    log.setRole_name(rs.getString("role_name"));
                    
                    java.sql.Timestamp entry = rs.getTimestamp("entry_time");
                    if (entry != null) {
                        log.setEntry_time(entry.toLocalDateTime());
                    }
                    
                    java.sql.Timestamp exit = rs.getTimestamp("exit_time");
                    if (exit != null) {
                        log.setExit_time(exit.toLocalDateTime());
                    }
                    
                    logs.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return logs;
    }
}