package operations;

import model.Profile;

public interface Profile_operation {
    Profile getProfileDetails(int userId);
    String updateName(int userId, String name);
    String updateEmail(int userId, String email);
    String changePassword(int userId, String currentPassword, String newPassword);
}