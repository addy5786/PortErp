package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import db_config.GetConnection;
import model.Cargo;
import model.CargoMovement;
import operations.Cargo_operation;

public class Cargo_Implementor implements Cargo_operation {

    @Override
    public List<String[]> getEmptyContainers() {
        List<String[]> emptyContainers = new ArrayList<>();
        String query = "SELECT container_id, container_type FROM CONTAINER WHERE status = 'Empty' ORDER BY container_id ASC";
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return emptyContainers; 
            
            try (PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                 
                while (rs.next()) {
                    String[] container = new String[2];
                    container[0] = String.valueOf(rs.getInt("container_id"));
                    container[1] = rs.getString("container_type");
                    emptyContainers.add(container);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return emptyContainers;
    }

    @Override
    public List<Cargo> viewAllCargo() {
        List<Cargo> cargoList = new ArrayList<>();
        String query = "SELECT * FROM vw_cargo_base_details";
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return cargoList; 
            
            try (PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                 
                while (rs.next()) {
                    Cargo c = new Cargo();
                    c.setCargoId(rs.getInt("cargo_id"));
                    c.setDescription(rs.getString("cargo_description"));
                    c.setWeight(rs.getDouble("weight"));
                    c.setStatus(rs.getString("cargo_status"));
                    c.setContainerId(rs.getInt("container_id"));
                    c.setContainerType(rs.getString("container_type"));
                    c.setShipId(rs.getInt("ship_id"));
                    c.setShipName(rs.getString("ship_name"));
                    cargoList.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cargoList;
    }

    @Override
    public List<Cargo> searchCargo(String keyword, String containerFilter, String statusFilter) {
        List<Cargo> cargoList = new ArrayList<>();
        StringBuilder queryBuilder = new StringBuilder("SELECT * FROM vw_cargo_base_details WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            String idPattern = keyword.replace("#", "").replace("Cont-", "").trim();
            
            if (idPattern.matches("\\d+")) {
                queryBuilder.append(" AND (CAST(cargo_id AS CHAR) = ? OR CAST(container_id AS CHAR) = ?)");
                params.add(idPattern);
                params.add(idPattern);
            } else {
                queryBuilder.append(" AND (cargo_description LIKE ? OR cargo_status = ? OR ship_name LIKE ?)");
                String searchPattern = "%" + keyword.trim() + "%";
                params.add(searchPattern);
                params.add(keyword.trim());
                params.add(searchPattern);
            }
        }
        
        if (containerFilter != null && !containerFilter.trim().isEmpty()) {
            queryBuilder.append(" AND CAST(container_id AS CHAR) = ?");
            params.add(containerFilter.replace("Cont-", "").trim());
        }
        
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !statusFilter.trim().equalsIgnoreCase("All")) {
            queryBuilder.append(" AND cargo_status = ?");
            params.add(statusFilter.trim());
        }
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return cargoList;
            
            try (PreparedStatement ps = conn.prepareStatement(queryBuilder.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Cargo c = new Cargo();
                        c.setCargoId(rs.getInt("cargo_id"));
                        c.setDescription(rs.getString("cargo_description"));
                        c.setWeight(rs.getDouble("weight"));
                        c.setStatus(rs.getString("cargo_status"));
                        c.setContainerId(rs.getInt("container_id"));
                        c.setContainerType(rs.getString("container_type"));
                        c.setShipId(rs.getInt("ship_id"));
                        c.setShipName(rs.getString("ship_name"));
                        cargoList.add(c);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cargoList;
    }

    @Override
    public Cargo getCargoById(int cargoId) {
        Cargo c = null;
        String query = "{call search_cargo(?)}";
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return null; 
            
            try (CallableStatement cs = conn.prepareCall(query)) {
                cs.setInt(1, cargoId);
                try (ResultSet rs = cs.executeQuery()) {
                    if (rs.next()) {
                        c = new Cargo();
                        c.setCargoId(rs.getInt("cargo_id"));
                        c.setDescription(rs.getString("cargo_description"));
                        c.setWeight(rs.getDouble("weight"));
                        c.setStatus(rs.getString("cargo_status"));
                        c.setContainerId(rs.getInt("container_id"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return c;
    }

    @Override
    public boolean addCargo(Cargo cargo, int currentUserId) {
        String insertCargoQuery = "{call add_cargo(?, ?, ?, ?)}";
        String logMovementQuery = "INSERT INTO CARGO_MOVEMENT (cargo_id, movement_type, movement_date, handled_by) VALUES (LAST_INSERT_ID(), ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 330 MINUTE), ?)";

        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return false; 
            
            conn.setAutoCommit(false); 
            
            try (CallableStatement cs = conn.prepareCall(insertCargoQuery)) {
                cs.setInt(1, cargo.getContainerId());
                cs.setString(2, cargo.getDescription());
                cs.setDouble(3, cargo.getWeight());
                cs.setString(4, cargo.getStatus());
                cs.executeUpdate();
            } catch (SQLException e) {
                conn.rollback();
                if ("45000".equals(e.getSQLState())) {
                    throw new RuntimeException(e.getMessage());
                }
                e.printStackTrace();
                return false;
            }
            
            try (PreparedStatement ps = conn.prepareStatement(logMovementQuery)) {
                String moveType = "Transfer";
                if ("Loaded".equals(cargo.getStatus())) moveType = "Load";
                else if ("Unloaded".equals(cargo.getStatus())) moveType = "Unload";
                
                ps.setString(1, moveType);
                ps.setInt(2, currentUserId);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateCargo(Cargo cargo, int currentUserId) {
        String query = "{call update_cargo(?, ?, ?, ?, ?)}";
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return false; 
             
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET @current_user_id = " + currentUserId);
            }
            
            try (CallableStatement cs = conn.prepareCall(query)) {
                cs.setInt(1, cargo.getCargoId());
                cs.setInt(2, cargo.getContainerId());
                cs.setString(3, cargo.getDescription());
                cs.setDouble(4, cargo.getWeight());
                cs.setString(5, cargo.getStatus());
                
                return cs.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            if ("45000".equals(e.getSQLState())) {
                throw new RuntimeException(e.getMessage());
            }
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteCargo(int cargoId) {
        String query = "{call delete_cargo(?)}";
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return false; 
            
            try (CallableStatement cs = conn.prepareCall(query)) {
                cs.setInt(1, cargoId);
                return cs.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<CargoMovement> viewCargoMovementHistory(int cargoId) {
        List<CargoMovement> history = new ArrayList<>();
        String query = "{call view_cargo_movement_history(?)}";
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return history; 
            
            try (CallableStatement cs = conn.prepareCall(query)) {
                cs.setInt(1, cargoId);
                try (ResultSet rs = cs.executeQuery()) {
                    while (rs.next()) {
                        CargoMovement cm = new CargoMovement();
                        cm.setMovementId(rs.getInt("movement_id"));
                        cm.setMovementType(rs.getString("movement_type"));
                        cm.setMovementDate(rs.getTimestamp("movement_date"));
                        cm.setHandlerName(rs.getString("handler_name"));
                        history.add(cm);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }

    @Override
    public List<CargoMovement> viewAllCargoMovements() {
        List<CargoMovement> history = new ArrayList<>();
        String query = "SELECT movement_id, movement_type, movement_date, handled_by, cargo_id FROM CARGO_MOVEMENT ORDER BY movement_date DESC";
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return history; 
            
            try (PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CargoMovement cm = new CargoMovement();
                    cm.setMovementId(rs.getInt("movement_id"));
                    cm.setMovementType(rs.getString("movement_type"));
                    cm.setMovementDate(rs.getTimestamp("movement_date"));
                    cm.setHandlerName("User " + rs.getString("handled_by") + " (Cargo #" + rs.getInt("cargo_id") + ")");
                    history.add(cm);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }

    @Override
    public List<CargoMovement> searchCargoMovements(String keyword, String typeFilter) {
        List<CargoMovement> history = new ArrayList<>();
        StringBuilder queryBuilder = new StringBuilder("SELECT movement_id, movement_type, movement_date, handled_by, cargo_id FROM CARGO_MOVEMENT WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            String idPattern = keyword.replace("#", "").trim();
            if (idPattern.matches("\\d+")) {
                queryBuilder.append(" AND (CAST(cargo_id AS CHAR) = ? OR CAST(handled_by AS CHAR) = ?)");
                params.add(idPattern);
                params.add(idPattern);
            }
        }
        
        if (typeFilter != null && !typeFilter.trim().isEmpty() && !typeFilter.trim().equalsIgnoreCase("All")) {
            queryBuilder.append(" AND movement_type = ?");
            params.add(typeFilter.trim());
        }
        
        queryBuilder.append(" ORDER BY movement_date DESC");
        
        try (Connection conn = GetConnection.getConnection()) {
            if (conn == null) return history; 
            
            try (PreparedStatement ps = conn.prepareStatement(queryBuilder.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        CargoMovement cm = new CargoMovement();
                        cm.setMovementId(rs.getInt("movement_id"));
                        cm.setMovementType(rs.getString("movement_type"));
                        cm.setMovementDate(rs.getTimestamp("movement_date"));
                        cm.setHandlerName("User " + rs.getString("handled_by") + " (Cargo #" + rs.getInt("cargo_id") + ")");
                        history.add(cm);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }
}