package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;

import db_config.GetConnection;
import model.Logout;
import operations.LogoutOperation;

public class LogoutImplementor implements LogoutOperation {

    @Override
    public void logoutUser(Logout logout) {

        try (Connection connection = GetConnection.getConnection();
             CallableStatement cs = connection.prepareCall("{CALL user_logout(?)}")) {

            cs.setInt(1, logout.getUserId());
            cs.execute();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}