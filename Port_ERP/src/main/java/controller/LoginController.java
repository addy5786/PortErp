package controller;

import java.io.IOException;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Login;

@WebServlet("/LoginController")
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Instantiating the model data
        Login login = new Login(
            request.getParameter("email"),
            request.getParameter("password")
        );

        // 2. Querying authentication entirely through the model
        Map<String, Object> userSessionData = login.authenticate();

        if (userSessionData != null) {
            // Check if the login map returned a definitive account status restriction
            if (userSessionData.containsKey("status_error")) {
                request.setAttribute("error", userSessionData.get("status_error").toString());
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Normal login success path
            HttpSession session = request.getSession(true);
            session.setAttribute("user_id", userSessionData.get("user_id"));
            session.setAttribute("username", userSessionData.get("username"));
            session.setAttribute("role", userSessionData.get("role"));
            session.setAttribute("user_email", login.getEmail());

            response.sendRedirect("dashboard");
        } else {
            // Failsafe catch for entirely incorrect email/password structures
            request.setAttribute("error", "INVALID EMAIL OR PASSWORD");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}