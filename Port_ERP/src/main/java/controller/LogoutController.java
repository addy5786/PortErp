package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Logout;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            Integer userId = (Integer) session.getAttribute("user_id"); 
            
            if (userId != null) {
                Logout logoutModel = new Logout(userId);
                logoutModel.executeLogout();
            }
            session.invalidate(); 
        }
        
        // Clean redirection to root container path
        response.sendRedirect("login.jsp");
    }
}