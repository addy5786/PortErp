package operation_implementor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import db_config.GetConnection;
import model.Dashboard;
import operations.Dashboard_operation;

public class Dashboard_Implementor implements Dashboard_operation {

    private int getCount(String query) {
        int count = 0;
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if(rs.next()) {
                count = rs.getInt(1);
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    @Override
    public Dashboard getDashboardCounts(int userId) {
        Dashboard d = new Dashboard();

        d.setTotalUsers(getCount("SELECT COUNT(*) FROM `USER`"));
        d.setTotalShips(getCount("SELECT COUNT(*) FROM SHIP"));
        d.setTotalDocks(getCount("SELECT COUNT(*) FROM DOCK"));
        d.setActiveDocks(getCount("SELECT COUNT(*) FROM DOCK WHERE status='Occupied'"));
        d.setAvailableDocks(getCount("SELECT COUNT(*) FROM DOCK WHERE status='Available'"));
        d.setTotalContainers(getCount("SELECT COUNT(*) FROM CONTAINER"));
        d.setTotalCargo(getCount("SELECT COUNT(*) FROM CARGO"));

        d.setAnchoredShips(getCount("SELECT COUNT(*) FROM SHIP WHERE status='Anchored'"));
        d.setDockedShips(getCount("SELECT COUNT(*) FROM SHIP WHERE status='Docked'"));
        d.setDepartedShips(getCount("SELECT COUNT(*) FROM SHIP WHERE status='Departed'"));

        d.setOccupiedDocks(getCount("SELECT COUNT(*) FROM DOCK WHERE status='Occupied'"));
        d.setMaintenanceDocks(getCount("SELECT COUNT(*) FROM DOCK WHERE status='Under Maintenance'"));

        d.setPendingCargoCount(getCount("SELECT COUNT(*) FROM CARGO WHERE status='In Transit'")); // Updated setter
        d.setLoadedCargo(getCount("SELECT COUNT(*) FROM CARGO WHERE status='Loaded'"));
        d.setUnloadedCargo(getCount("SELECT COUNT(*) FROM CARGO WHERE status='Unloaded'"));

        return d;
    }

    private List<Map<String, Object>> getList(String query, Object... params) {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {

            for(int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                int columnCount = rs.getMetaData().getColumnCount();
                while(rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    for(int i = 1; i <= columnCount; i++) {
                        row.put(rs.getMetaData().getColumnLabel(i), rs.getObject(i));
                    }
                    list.add(row);
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Map<String, Object>> getMyShips(int userId) {
        return getList("SELECT ship_name, arrival_date, departure_date, status FROM SHIP WHERE operator_id=?", userId);
    }

    @Override
    public List<Map<String, Object>> getUpcomingDepartures(int userId) {
        return getList("SELECT ship_name, departure_date, status FROM SHIP WHERE operator_id=? ORDER BY departure_date ASC", userId);
    }

    @Override
    public List<Map<String, Object>> getDockBoard() {
        return getList("SELECT dock_name, status FROM DOCK");
    }

    @Override
    public List<Map<String, Object>> getPendingCargoList() { // Updated name
        return getList("SELECT cargo_id, description, container_id, status FROM CARGO WHERE status='In Transit'");
    }

    @Override
    public List<Map<String, Object>> getRecentlyHandledCargo(int userId) {
        return getList("SELECT cargo_id, movement_type, movement_date FROM CARGO_MOVEMENT WHERE handled_by=? ORDER BY movement_date DESC", userId);
    }

    @Override
    public List<Map<String, Object>> getRecentActivities() {
        String query = "SELECT * FROM (" +
                       "  SELECT CONCAT('Vessel [', ship_name, '] marked as ', status) AS activity_details, arrival_date AS activity_date FROM SHIP " +
                       "  UNION ALL " +
                       "  SELECT CONCAT('Cargo modification registered for item details: ', description), NOW() FROM CARGO " +
                       ") AS timeline ORDER BY activity_date DESC LIMIT 5";
        return getList(query);
    }
}