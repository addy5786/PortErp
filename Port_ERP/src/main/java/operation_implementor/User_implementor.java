package operation_implementor;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import db_config.GetConnection;
import model.User;
import operations.User_operation;

public class User_implementor implements User_operation {

    // =========================================
    // ADD USER (Calls Stored Procedure)
    // =========================================
    @Override
    public void addUser(User user) throws Exception {
        // syntax calls: add_user(p_admin_role_id, p_name, p_email, p_password, p_role_id)
        String sql = "{CALL add_user(?, ?, ?, ?, ?)}"; 

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            // Pass the current session user's admin role ID to bypass the check
            cs.setInt(1, user.getAdminRoleId()); 
            cs.setString(2, user.getName());
            cs.setString(3, user.getEmail());
            cs.setString(4, user.getPassword()); // Pass plain text; the DB handles SHA-256
            cs.setInt(5, user.getRoleId());

            cs.execute();
        }
    }

    // =========================================
    // UPDATE USER NAME (Calls Stored Procedure)
    // =========================================
    @Override
    public void updateUserName(User user) throws Exception {
        String sql = "{CALL update_user_name(?, ?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, user.getAdminRoleId());
            cs.setInt(2, user.getUserId());
            cs.setString(3, user.getName());

            cs.execute();
        }
    }

    // =========================================
    // UPDATE USER EMAIL (Calls Stored Procedure)
    // =========================================
    @Override
    public void updateUserEmail(User user) throws Exception {
        String sql = "{CALL update_user_email(?, ?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, user.getAdminRoleId());
            cs.setInt(2, user.getUserId());
            cs.setString(3, user.getEmail());

            cs.execute();
        }
    }

    // =========================================
    // UPDATE USER ROLE (Calls Stored Procedure)
    // =========================================
    @Override
    public void updateUserRole(User user) throws Exception {
        String sql = "{CALL update_user_role(?, ?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, user.getAdminRoleId());
            cs.setInt(2, user.getUserId());
            cs.setInt(3, user.getRoleId());

            cs.execute();
        }
    }

    // =========================================
    // UPDATE PASSWORD (Calls Stored Procedure)
    // =========================================
    @Override
    public void updateUserPassword(User user) throws Exception {
        String sql = "{CALL update_user_password(?, ?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, user.getAdminRoleId());
            cs.setInt(2, user.getUserId());
            cs.setString(3, user.getPassword()); // Pass plain text; the DB handles SHA-256

            cs.execute();
        }
    }

    // =========================================
    // ACTIVATE USER (Calls Stored Procedure)
    // =========================================
    @Override
    public void activateUser(User user) throws Exception {
        String sql = "{CALL activate_user(?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, user.getAdminRoleId());
            cs.setInt(2, user.getUserId());

            cs.execute();
        }
    }

    // =========================================
    // DEACTIVATE USER (Calls Stored Procedure)
    // =========================================
    @Override
    public void deactivateUser(User user) throws Exception {
        String sql = "{CALL deactivate_user(?, ?)}";

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall(sql)) {

            cs.setInt(1, user.getAdminRoleId());
            cs.setInt(2, user.getUserId());

            cs.execute();
        }
    }

    // =========================================
    // GET ALL USERS (Keeps standard read structure)
    // =========================================
    @Override
    public ArrayList<User> getAllUsers() throws Exception {
        ArrayList<User> list = new ArrayList<>();
        
        String sql =
            "SELECT U.user_id, U.name, U.email, " +
            "COALESCE(R.role_name, 'Unknown') AS role_name, " +
            "CASE WHEN U.status = 1 THEN 'ACTIVE' ELSE 'DEACTIVATED' END AS status " +
            "FROM `USER` U " +
            "LEFT JOIN `ROLE` R ON U.role_id = R.role_id";

        try (Connection connection = GetConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setRoleName(rs.getString("role_name"));
                user.setStatus(rs.getString("status"));

                list.add(user);
            }
        }
        return list;
    }
}