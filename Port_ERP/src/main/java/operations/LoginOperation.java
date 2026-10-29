package operations;

import model.Login;

/**
 * Interface representing the login business operations.
 * This defines the contract that any login implementation must fulfill.
 */
public interface LoginOperation {
    
    /**
     * Authenticates a user based on their login credentials.
     * * @param login The login model containing the user's email and password.
     * @return A string message indicating the result of the login attempt.
     */
    String loginUser(Login login);
}