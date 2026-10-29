package db_config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class GetConnection {
    // Database credentials
    private static final String URL = "jdbc:mysql://localhost:3306/port_erp";
    private static final String USER = "root";
    private static final String PASSWORD = ""; 

    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Updated driver class name specifically for mysql-connector-java-5.x.x
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            
            // Print a success message to the Eclipse Console
            System.out.println("Database connection successful!");
            
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Database Connection Error: " + e.getMessage());
            e.printStackTrace();
        }
        return conn;
    }
}