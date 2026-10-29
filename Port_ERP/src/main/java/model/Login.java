package model;

import java.util.Map;
import operation_implementor.LoginImplementor;

public class Login {
    private String email;
    private String password;

    public Login() {}

    public Login(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    /**
     * Business execution encapsulated directly within the model.
     * Prevents the Controller from needing an explicit dependency on the Implementor.
     */
    public Map<String, Object> authenticate() {
        LoginImplementor implementor = new LoginImplementor();
        return implementor.getAuthenticatedUserSession(this);
    }
}