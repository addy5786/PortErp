package model;

import java.util.ArrayList;
import operation_implementor.User_implementor;

public class User {

    private int adminRoleId;
    private int userId;
    private String name;
    private String email;
    private String password;
    private int roleId;
    private String roleName;
    private String status;

    // Getters and Setters

    public int getAdminRoleId() {
        return adminRoleId;
    }

    public void setAdminRoleId(int v) {
        this.adminRoleId = v;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int v) {
        this.userId = v;
    }

    public String getName() {
        return name;
    }

    public void setName(String v) {
        this.name = v;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String v) {
        this.email = v;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String v) {
        this.password = v;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int v) {
        this.roleId = v;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String v) {
        this.roleName = v;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String v) {
        this.status = v;
    }

    // Implementor Object

    private User_implementor getImplementor() {
        return new User_implementor();
    }

    // Methods

    public void add_user() throws Exception {
        getImplementor().addUser(this);
    }

    public void update_user_name() throws Exception {
        getImplementor().updateUserName(this);
    }

    public void update_user_email() throws Exception {
        getImplementor().updateUserEmail(this);
    }

    public void update_user_role() throws Exception {
        getImplementor().updateUserRole(this);
    }

    public void update_user_password() throws Exception {
        getImplementor().updateUserPassword(this);
    }

    public void activate_user() throws Exception {
        getImplementor().activateUser(this);
    }

    public void deactivate_user() throws Exception {
        getImplementor().deactivateUser(this);
    }

    public ArrayList<User> get_all_users() throws Exception {
        return getImplementor().getAllUsers();
    }
}