package model;

import java.io.Serializable;
import operation_implementor.Profile_Implementor;
import operations.Profile_operation;

public class Profile implements Serializable {

    private static final long serialVersionUID = 1L;
    
    private int userId;
    private String name;
    private String email;
    private String role;

    private static final Profile_operation profileOps = new Profile_Implementor();

    public Profile() {}

    // Operational Methods linked directly to Abstract Contract Architecture
    public static Profile getProfileDetails(int userId) {
        return profileOps.getProfileDetails(userId);
    }

    public String updateName(String newName) {
        return profileOps.updateName(this.userId, newName);
    }

    public String updateEmail(String newEmail) {
        return profileOps.updateEmail(this.userId, newEmail);
    }

    public static String changePassword(int userId, String currentPassword, String newPassword) {
        return profileOps.changePassword(userId, currentPassword, newPassword);
    }

    // Accessors and Mutators
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}