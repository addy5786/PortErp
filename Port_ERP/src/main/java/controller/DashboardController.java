package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Dashboard;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");

        // Requesting state metrics directly from the model pass-through layer
        Dashboard dashboard = Dashboard.getDashboardCounts(userId);

        request.setAttribute("dashboard", dashboard);
        request.setAttribute("username", username);
        request.setAttribute("role", role);

        request.setAttribute("myShips", Dashboard.getMyShips(userId));
        request.setAttribute("upcomingDepartures", Dashboard.getUpcomingDepartures(userId));
        request.setAttribute("dockBoard", Dashboard.getDockBoard());
        
        // FIX: Points to the updated structural collection wrapper to avoid name collisions
        request.setAttribute("pendingCargo", Dashboard.getPendingCargoList()); 
        
        request.setAttribute("recentCargo", Dashboard.getRecentlyHandledCargo(userId));
        request.setAttribute("recentActivities", Dashboard.getRecentActivities());

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}