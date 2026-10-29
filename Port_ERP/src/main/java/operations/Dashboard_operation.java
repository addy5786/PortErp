package operations;

import java.util.List;
import java.util.Map;
import model.Dashboard;

public interface Dashboard_operation {
    Dashboard getDashboardCounts(int userId);
    List<Map<String, Object>> getMyShips(int userId);
    List<Map<String, Object>> getUpcomingDepartures(int userId);
    List<Map<String, Object>> getDockBoard();
    List<Map<String, Object>> getPendingCargoList(); // Renamed here
    List<Map<String, Object>> getRecentlyHandledCargo(int userId);
    List<Map<String, Object>> getRecentActivities();
}