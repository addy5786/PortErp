package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Profile;

@WebServlet("/profile")
public class ProfileController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user_id") == null) {
            request.setAttribute("error", "Access Denied. Please log in first.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");

        // Fetching data context directly through the updated Profile domain model representation
        Profile profile = Profile.getProfileDetails(userId);

        request.setAttribute("profile", profile);
        request.setAttribute("username", username);
        request.setAttribute("role", role);

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String action = request.getParameter("action");
        String message = "";

        if ("updateName".equals(action)) {
            String name = request.getParameter("name");
            
            // Re-instantiating state identity profile to perform clean execution
            Profile profile = new Profile();
            profile.setUserId(userId);
            message = profile.updateName(name);
            
            if (message != null && message.toUpperCase().contains("SUCCESS")) {
                session.setAttribute("username", name);
            }
        } 
        else if ("updateEmail".equals(action)) {
            String email = request.getParameter("email");
            
            Profile profile = new Profile();
            profile.setUserId(userId);
            message = profile.updateEmail(email);
            
            if (message != null && message.toUpperCase().contains("SUCCESS")) {
                session.setAttribute("user_email", email);
            }
        } 
        else if ("changePassword".equals(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            message = Profile.changePassword(userId, currentPassword, newPassword);
        }

        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect("profile?message=" + encodedMessage);
    }
}