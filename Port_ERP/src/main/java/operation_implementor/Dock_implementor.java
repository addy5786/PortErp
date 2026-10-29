package operation_implementor;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import db_config.GetConnection;
import model.Dock;
import operations.Dock_operation;

public class Dock_implementor implements Dock_operation {

    @Override
    public void addDock(Dock dock) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call ADD_Dock(?,?)}")) {
            cs.setString(1, dock.getDockName());
            cs.setString(2, dock.getStatus());
            cs.execute();
        } catch (Exception e) { 
            e.printStackTrace(); 
            throw new RuntimeException("Error adding dock: " + e.getMessage());
        }
    }

    @Override
    public List<Dock> viewDock() {
        List<Dock> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT dock_id, dock_name, status FROM DOCK");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Dock d = new Dock();
                d.setDockId(rs.getInt("dock_id"));
                d.setDockName(rs.getString("dock_name"));
                d.setStatus(rs.getString("status"));
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    @Override
    public void updateDockName(Dock dock) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call UpdateDockName(?,?)}")) {
            cs.setInt(1, dock.getDockId());
            cs.setString(2, dock.getDockName());
            cs.execute();
        } catch (Exception e) { 
            e.printStackTrace(); 
            throw new RuntimeException("Error updating dock name: " + e.getMessage());
        }
    }

    @Override
    public void updateDockStatus(Dock dock) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call UpdateDockStatus(?,?)}")) {
            cs.setInt(1, dock.getDockId());
            cs.setString(2, dock.getStatus());
            cs.execute();
        } catch (Exception e) { 
            e.printStackTrace(); 
            throw new RuntimeException("Error updating dock status: " + e.getMessage());
        }
    }

    @Override
    public void deleteDock(Dock dock) {
        Connection con = null;
        PreparedStatement psCleanup = null;
        CallableStatement csDelete = null;

        try {
            con = GetConnection.getConnection();
            con.setAutoCommit(false);

            String cleanupSQL = "DELETE FROM DOCK_ALLOCATION WHERE dock_id = ?";
            psCleanup = con.prepareStatement(cleanupSQL);
            psCleanup.setInt(1, dock.getDockId());
            psCleanup.executeUpdate();

            csDelete = con.prepareCall("{call DeleteDock(?)}");
            csDelete.setInt(1, dock.getDockId());
            csDelete.execute();

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException se) { se.printStackTrace(); }
            }
            e.printStackTrace();
            throw new RuntimeException("DB Deletion transactional failure: " + e.getMessage());
        } finally { // Fixed spelling from 'finaly' to 'finally'
            try { if (psCleanup != null) psCleanup.close(); } catch (Exception e) {}
            try { if (csDelete != null) csDelete.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    @Override
    public List<Dock> searchDockByName(String keyword) {
        List<Dock> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT dock_id, dock_name, status FROM DOCK WHERE dock_name LIKE ?")) {
            ps.setString(1, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Dock d = new Dock();
                d.setDockId(rs.getInt("dock_id"));
                d.setDockName(rs.getString("dock_name"));
                d.setStatus(rs.getString("status"));
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    @Override
    public List<Dock> searchDockByStatus(String status) {
        List<Dock> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT dock_id, dock_name, status FROM DOCK WHERE status = ?")) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Dock d = new Dock();
                d.setDockId(rs.getInt("dock_id"));
                d.setDockName(rs.getString("dock_name"));
                d.setStatus(rs.getString("status"));
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    @Override
    public Map<String, Integer> dockStatistics() {
        Map<String, Integer> map = new HashMap<>();
        String query = "SELECT COUNT(*) AS Total_Docks, " +
                       "SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS Available_Docks, " +
                       "SUM(CASE WHEN status = 'Occupied' THEN 1 ELSE 0 END) AS Occupied_Docks, " +
                       "SUM(CASE WHEN status = 'Under Maintenance' THEN 1 ELSE 0 END) AS Maintenance_Docks " +
                       "FROM DOCK";

        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                map.put("total", rs.getInt("Total_Docks"));
                map.put("available", rs.getInt("Available_Docks"));
                map.put("occupied", rs.getInt("Occupied_Docks"));
                map.put("maintenance", rs.getInt("Maintenance_Docks"));
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return map;
    }

    @Override public void viewAvailableDocks() {}
    @Override public void viewOccupiedDocks() {}
    @Override public void viewUnderMaintenanceDocks() {}
}