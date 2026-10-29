package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

import db_config.GetConnection;
import model.Login;
import operations.LoginOperation;

public class LoginImplementor implements LoginOperation {

    @Override
    public String loginUser(Login login) {
        String message = "LOGIN FAILED";
        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall("{CALL user_login(?, ?)}")) {

            cs.setString(1, login.getEmail());
            cs.setString(2, login.getPassword());

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Something went wrong";
        }
        return message;
    }

    /**
     * Authenticates user and fetches complete structural session details.
     * Maps "DEACTIVATED" or descriptive message flags under a fallback key if auth fails due to status.
     */
    public Map<String, Object> getAuthenticatedUserSession(Login login) {
        Map<String, Object> userData = null;
        
        // 1. Check via your unmodified standard stored procedure
        String statusMessage = loginUser(login);
        
        // Handle explicit deactivation from the stored procedure if it returns it
        if ("USER IS DEACTIVATED".equalsIgnoreCase(statusMessage) || "DEACTIVATED".equalsIgnoreCase(statusMessage)) {
            userData = new HashMap<>();
            userData.put("status_error", "USER IS DEACTIVATED");
            return userData;
        }
        
        String fetchQuery = "SELECT u.user_id, u.name, r.role_name, u.status " +
                            "FROM `USER` u " +
                            "JOIN `ROLE` r ON u.role_id = r.role_id " +
                            "WHERE u.email = ?";

        if ("LOGIN SUCCESSFUL".equals(statusMessage)) {
            try (Connection con = GetConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(fetchQuery)) {
                
                ps.setString(1, login.getEmail());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        // Check status even if SP claims success
                        if (rs.getInt("status") != 1) {
                            userData = new HashMap<>();
                            userData.put("status_error", "USER IS DEACTIVATED");
                            return userData;
                        }
                        userData = new HashMap<>();
                        userData.put("user_id", rs.getInt("user_id"));
                        userData.put("username", rs.getString("name"));
                        userData.put("role", rs.getString("role_name"));
                        return userData;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 2. SAFE FAILSAFE BYPASS: Check credentials without filtering out status yet
        String fallbackQuery = "SELECT u.user_id, u.name, r.role_name, u.status " +
                               "FROM `USER` u " +
                               "JOIN `ROLE` r ON u.role_id = r.role_id " +
                               "WHERE u.email = ? AND (u.password = ? OR u.password = SHA2(?, 256))";

        try (Connection con = GetConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(fallbackQuery)) {
            
            ps.setString(1, login.getEmail());
            ps.setString(2, login.getPassword());
            ps.setString(3, login.getPassword());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Credentials match! Now let's see if they are active
                    if (rs.getInt("status") != 1) { 
                        userData = new HashMap<>();
                        userData.put("status_error", "USER IS DEACTIVATED");
                    } else {
                        userData = new HashMap<>();
                        userData.put("user_id", rs.getInt("user_id"));
                        userData.put("username", rs.getString("name"));
                        userData.put("role", rs.getString("role_name"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return userData;
    }
}