package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import db_config.GetConnection;
import model.DockAllocation;
import operations.DockAllocation_Operations;

public class DockAllocation_Implementor implements DockAllocation_Operations {

    @Override
    public String allocate_dock(DockAllocation dockAllocation) {
        String message = "ALLOCATION FAILED";
        String query = "{call allocate_dock(?, ?, ?, ?)}";

        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall(query)) {

            cs.setInt(1, dockAllocation.getShipId());
            cs.setInt(2, dockAllocation.getDockId());
            cs.setString(3, dockAllocation.getAllocationTime());
            cs.setString(4, dockAllocation.getReleaseTime());

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    @Override
    public String release_dock(DockAllocation dockAllocation) {
        String message = "RELEASE FAILED";
        String query = "{call release_dock(?)}";

        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall(query)) {

            cs.setInt(1, dockAllocation.getAllocationId());

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    @Override
    public String update_dock_allocation(DockAllocation dockAllocation) {
        String message = "UPDATE FAILED";
        String query = "{call update_dock_allocation(?, ?, ?, ?)}";

        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall(query)) {

            cs.setInt(1, dockAllocation.getAllocationId());
            
            if (dockAllocation.getDockId() == 0) {
                cs.setNull(2, java.sql.Types.INTEGER);
            } else {
                cs.setInt(2, dockAllocation.getDockId());
            }
            
            if (dockAllocation.getAllocationTime() == null || dockAllocation.getAllocationTime().isEmpty()) {
                cs.setNull(3, java.sql.Types.TIMESTAMP);
            } else {
                cs.setString(3, dockAllocation.getAllocationTime());
            }
            
            if (dockAllocation.getReleaseTime() == null || dockAllocation.getReleaseTime().isEmpty()) {
                cs.setNull(4, java.sql.Types.TIMESTAMP);
            } else {
                cs.setString(4, dockAllocation.getReleaseTime());
            }

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    @Override
    public List<Map<String, Object>> view_active_allocations() {
        String query = "SELECT * FROM view_active_allocations";
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            return toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> view_allocation_history() {
        String query = "SELECT * FROM view_allocation_history";
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            return toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> view_anchored_ships() {
        String query = "SELECT ship_id, ship_name FROM view_anchored_ships";
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            return toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> view_available_docks() {
        String query = "SELECT dock_id, dock_name FROM view_available_docks";
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            return toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public List<Map<String, Object>> search_dock(String input) {
        String query = "{call Search_Allocation(?)}";
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall(query)) {
            
            cs.setString(1, input);
            try (ResultSet rs = cs.executeQuery()) {
                return toList(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Safely leaves extraction to a private parsing runner
    private List<Map<String, Object>> toList(ResultSet rs) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        int cols = rs.getMetaData().getColumnCount();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            for (int i = 1; i <= cols; i++) {
                row.put(rs.getMetaData().getColumnLabel(i), rs.getObject(i));
            }
            list.add(row);
        }
        return list;
    }
}