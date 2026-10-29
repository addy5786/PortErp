package operations;

import java.util.ArrayList;
import model.User;

public interface User_operation {

    void addUser(User user)            throws Exception;
    void updateUserName(User user)     throws Exception;
    void updateUserEmail(User user)    throws Exception;
    void updateUserRole(User user)     throws Exception;
    void updateUserPassword(User user) throws Exception;
    void activateUser(User user)       throws Exception;
    void deactivateUser(User user)     throws Exception;

    ArrayList<User> getAllUsers()      throws Exception;
}