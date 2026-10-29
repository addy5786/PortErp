package model;

import operation_implementor.LogoutImplementor;
import operations.LogoutOperation;

public class Logout {

    private int userId;

    // Default constructor
    public Logout() {}

    // Parameterized constructor
    public Logout(int userId) {
        this.userId = userId;
    }

    // Getter and Setter
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    /**
     * Active Record Executer: Handles linking the model data to its data layer implementation.
     */
    public void executeLogout() {
        try {
            LogoutOperation logoutOps = new LogoutImplementor();
            logoutOps.logoutUser(this); // Passes this specific model instance
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}