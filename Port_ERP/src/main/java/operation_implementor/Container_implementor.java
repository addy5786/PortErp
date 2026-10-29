package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import db_config.GetConnection;
import model.Container;
import operations.Container_operation;

public class Container_implementor implements Container_operation {

    @Override
    public List<String[]> getDockedShips() {
        List<String[]> shipList = new ArrayList<>();
        // SYSTEM FIX: Changed column 'name' to 'ship_name' to match database table SHIP declaration
        String query = "SELECT ship_id, ship_name FROM SHIP WHERE UPPER(TRIM(status)) = 'DOCKED' ORDER BY ship_name ASC";
        
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                String[] ship = new String[2];
                ship[0] = String.valueOf(rs.getInt("ship_id"));
                ship[1] = rs.getString("ship_name"); // SYSTEM FIX: Target exact column name
                shipList.add(ship);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return shipList;
    }

    @Override
    public String addContainer(Container c) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL add_container(?, ?, ?)}")) {
            cs.setString(1, c.getContainer_type());
            cs.setString(2, c.getStatus());
            cs.setInt(3, c.getShip_id());
            cs.execute();
            return "CONTAINER ADDED SUCCESSFULLY";
        } catch (Exception e) {
            e.printStackTrace();
            return e.getMessage();
        }
    }

    @Override
    public List<Container> viewContainers() {
        List<Container> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM view_containers");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Container c = new Container();
                c.setContainer_id(rs.getInt("container_id"));
                c.setContainer_type(rs.getString("container_type"));
                c.setStatus(rs.getString("status"));
                c.setShip_id(rs.getInt("ship_id"));
                c.setShip_name(rs.getString("ship_name"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public String updateContainer(Container c) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL update_container(?, ?, ?, ?)}")) {
            cs.setInt(1, c.getContainer_id());
            cs.setString(2, c.getContainer_type());
            cs.setString(3, c.getStatus());
            cs.setInt(4, c.getShip_id());
            cs.execute();
            return "CONTAINER UPDATED SUCCESSFULLY";
        } catch (Exception e) {
            e.printStackTrace();
            return e.getMessage();
        }
    }

    @Override
    public String deleteContainer(int container_id) {
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL delete_container(?)}")) {
            cs.setInt(1, container_id);
            cs.execute();
            return "CONTAINER DELETED SUCCESSFULLY";
        } catch (Exception e) {
            e.printStackTrace();
            return e.getMessage();
        }
    }

    @Override
    public List<Container> filterContainer(String input) {
        List<Container> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL filter_container(?)}")) {
            cs.setString(1, input);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Container c = new Container();
                    c.setContainer_id(rs.getInt("container_id"));
                    c.setContainer_type(rs.getString("container_type"));
                    c.setStatus(rs.getString("status"));
                    c.setShip_name(rs.getString("ship_name"));
                    // SYSTEM FIX: Omitted rs.getShort("ship_id") because procedure 'filter_container' 
                    // only selects container_id, container_type, status, and ship_name.
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Container> viewContainerDetails(int container_id) {
        List<Container> list = new ArrayList<>();
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL view_container_details(?)}")) {
            cs.setInt(1, container_id);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Container c = new Container();
                    c.setContainer_id(rs.getInt("container_id"));
                    c.setContainer_type(rs.getString("container_type"));
                    c.setStatus(rs.getString("status"));
                    c.setCargo_id(rs.getInt("cargo_id"));
                    c.setDescription(rs.getString("description"));
                    c.setWeight(rs.getDouble("weight"));
                    c.setCargoStatus(rs.getString("cargo_status"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}