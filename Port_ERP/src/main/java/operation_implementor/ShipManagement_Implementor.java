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
import model.ShipManagement;
import operations.ShipManagement_Operation;

public class ShipManagement_Implementor implements ShipManagement_Operation {

    // -------------------------------------------------------------------------
    // Private helper — converts ResultSet to List<Map> INSIDE implementor only
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // Register ship
    // -------------------------------------------------------------------------
    @Override
    public String register_ship(ShipManagement ship) {
        String message;
        // Try-with-resources safely handles getConnection() throwing SQLException
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{call Register_Ship(?, ?, ?, ?, ?)}")) {
            
            cs.setString(1, ship.getShipName());
            cs.setString(2, ship.getArrivalDate() != null ? ship.getArrivalDate().toString() : null);
            cs.setString(3, ship.getDepartureDate() != null ? ship.getDepartureDate().toString() : null);
            cs.setString(4, ship.getStatus());
            cs.setInt(5, ship.getOperatorId());
            
            cs.executeUpdate();
            message = "SHIP REGISTERED SUCCESSFULLY";
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    // -------------------------------------------------------------------------
    // Update ship
    // -------------------------------------------------------------------------
    @Override
    public String update_ship(ShipManagement ship) {
        String message;
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{call update_ship(?, ?, ?, ?, ?, ?)}")) {
            
            cs.setInt(1, ship.getShipId());
            cs.setString(2, ship.getShipName());
            cs.setString(3, ship.getArrivalDate()   != null ? ship.getArrivalDate().toString()   : null);
            cs.setString(4, ship.getDepartureDate() != null ? ship.getDepartureDate().toString() : null);
            cs.setString(5, ship.getStatus());
            cs.setObject(6, ship.getOperatorId() == 0 ? null : ship.getOperatorId());
            
            cs.executeUpdate();
            message = "SHIP UPDATED SUCCESSFULLY";
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    // -------------------------------------------------------------------------
    // Delete ship
    // -------------------------------------------------------------------------
    @Override
    public String delete_ship(ShipManagement ship) {
        String message;
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{call Delete_Ship(?)}")) {
            
            cs.setInt(1, ship.getShipId());
            cs.executeUpdate();
            message = "SHIP DELETED SUCCESSFULLY";
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    // -------------------------------------------------------------------------
    // Update arrival time
    // -------------------------------------------------------------------------
    @Override
    public String update_arrival_time(ShipManagement ship) {
        String message;
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{call Update_Arrival_Time(?, ?)}")) {
            
            cs.setInt(1, ship.getShipId());
            cs.setString(2, ship.getArrivalDate() != null ? ship.getArrivalDate().toString() : null);
            
            cs.executeUpdate();
            message = "ARRIVAL TIME UPDATED SUCCESSFULLY";
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    // -------------------------------------------------------------------------
    // Update departure time
    // -------------------------------------------------------------------------
    @Override
    public String update_departure_time(ShipManagement ship) {
        String message;
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{call Update_Departure_Time(?, ?)}")) {
            
            cs.setInt(1, ship.getShipId());
            cs.setString(2, ship.getDepartureDate() != null ? ship.getDepartureDate().toString() : null);
            
            cs.executeUpdate();
            message = "DEPARTURE TIME UPDATED SUCCESSFULLY";
        } catch (SQLException e) {
            message = e.getMessage();
        }
        return message;
    }

    // -------------------------------------------------------------------------
    // Search ship — ResultSet converted HERE, never leaves implementor
    // -------------------------------------------------------------------------
    @Override
    public List<Map<String, Object>> search_ship(String input) {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = GetConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{call Search_Ship(?)}")) {
            
            cs.setString(1, input);
            try (ResultSet rs = cs.executeQuery()) {
                list = toList(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // View all ships — ResultSet converted HERE, never leaves implementor
    // -------------------------------------------------------------------------
    @Override
    public List<Map<String, Object>> view_ship_list() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ship_id, ship_name, arrival_date, departure_date, status, operator_id FROM SHIP";
        
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            list = toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // View anchored ships
    // -------------------------------------------------------------------------
    @Override
    public List<Map<String, Object>> view_anchored_ships() {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM view_anchored_ships");
             ResultSet rs = ps.executeQuery()) {
            
            list = toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // View operators dropdown
    // -------------------------------------------------------------------------
    @Override
    public List<Map<String, Object>> view_operators() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT user_id, name FROM USER WHERE role_id = 3 AND status = TRUE";
        
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            list = toList(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // View containers for a specific ship
    // -------------------------------------------------------------------------
    @Override
    public List<Map<String, Object>> view_ship_containers(int shipId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT container_id, container_type, status FROM CONTAINER WHERE ship_id = ?";
        
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shipId);
            try (ResultSet rs = ps.executeQuery()) {
                list = toList(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // View active dock allocation for a specific ship
    // -------------------------------------------------------------------------
    @Override
    public List<Map<String, Object>> view_ship_dock(int shipId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ship_name, dock_name, allocation_time, release_time " +
                     "FROM view_active_allocations " +
                     "WHERE ship_name = (SELECT ship_name FROM SHIP WHERE ship_id = ?)";
        
        try (Connection conn = GetConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, shipId);
            try (ResultSet rs = ps.executeQuery()) {
                list = toList(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}