package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import db_config.GetConnection;
import model.Profile;
import operations.Profile_operation;

public class Profile_Implementor implements Profile_operation {

    @Override
    public Profile getProfileDetails(int userId) {
        Profile profile = null;
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL get_profile_details(?)}")) {

            cs.setInt(1, userId);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    profile = new Profile();
                    profile.setUserId(rs.getInt("user_id"));
                    profile.setName(rs.getString("name"));
                    profile.setEmail(rs.getString("email"));
                    profile.setRole(rs.getString("role_name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return profile;
    }

    @Override
    public String updateName(int userId, String name) {
        String message = "NAME UPDATE FAILED";
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL update_name(?, ?)}")) {

            cs.setInt(1, userId);
            cs.setString(2, name);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "ERROR : " + e.getMessage();
        }
        return message;
    }

    @Override
    public String updateEmail(int userId, String email) {
        String message = "EMAIL UPDATE FAILED";
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL update_email(?, ?)}")) {

            cs.setInt(1, userId);
            cs.setString(2, email);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "ERROR : " + e.getMessage();
        }
        return message;
    }

    @Override
    public String changePassword(int userId, String currentPassword, String newPassword) {
        String message = "PASSWORD CHANGE FAILED";
        try (Connection con = GetConnection.getConnection();
             CallableStatement cs = con.prepareCall("{CALL change_password(?, ?, ?)}")) {

            cs.setInt(1, userId);
            cs.setString(2, currentPassword);
            cs.setString(3, newPassword);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    message = rs.getString("MESSAGE");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "ERROR : " + e.getMessage();
        }
        return message;
    }
}