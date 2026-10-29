package operations;

import java.util.List;
import model.SecurityLog;

public interface SecurityLog_operation {
    void viewAllLogs();
    void viewActiveLogs();
    void viewCompletedLogs();
    void searchSecurity(String keyword);
    List<SecurityLog> searchLogs(String keyword, String fromDate, String toDate, String role);
}