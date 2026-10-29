package operations;

import model.Logout;

/**
 * Interface representing the logout business operations.
 */
public interface LogoutOperation {

    /**
     * Terminates the user session database records.
     * @param logout The logout model containing the user session data.
     */
    void logoutUser(Logout logout);
}