package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.SecurityLog;

@WebServlet("/SecurityLogController")
public class SecurityLogController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Centralized security mechanism checking authentication status and verifying authorized roles.
     */
    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // 1. Verify user authentication status
        if (session == null || session.getAttribute("user_id") == null) {
            request.setAttribute("error", "Access Denied. Please log in first.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return false;
        }

        // 2. Enforce structural role restriction rules (Only Port Manager & Administrator)
        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equalsIgnoreCase("Port Manager") || 
                              role.equalsIgnoreCase("Administrator"))) {
            
            // Re-route unauthorized traffic securely back to the main dashboard with an error banner message
            request.setAttribute("message", "FAIL: Access Denied. Your profile role (" + (role != null ? role : "None") + ") lacks clearance for Security Logs.");
            request.getRequestDispatcher("dashboard").forward(request, response);
            return false;
        }
        return true;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // Validate security permissions profile context
        if (!isAuthorized(request, response)) return;

        String action = request.getParameter("action");

        // CSV EXPORT ACTION (Direct streaming, no JSP file needed)
        if (action != null && action.equalsIgnoreCase("exportCSV")) {
            List<SecurityLog> logs = SecurityLog.searchLogs(null, null, null, null);
            
            response.setContentType("text/csv");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"security_logs.csv\"");
            
            try (PrintWriter writer = response.getWriter()) {
                writer.println("Log ID,User Name,Role,Entry Time,Exit Time,Session Duration");
                
                if (logs != null) {
                    for (SecurityLog log : logs) {
                        String cleanEntry = log.getEntry_time() != null ? log.getEntry_time().toString().replace("T", " ") : "N/A";
                        String cleanExit = log.getExit_time() != null ? log.getExit_time().toString().replace("T", " ") : "-";
                        String duration = log.getExit_time() == null ? "Active Session" : log.getSessionDuration();
                        
                        writer.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                            log.getLog_id(),
                            log.getName() != null ? log.getName().replace("\"", "\"\"") : "",
                            log.getRole_name() != null ? log.getRole_name().replace("\"", "\"\"") : "",
                            cleanEntry,
                            cleanExit,
                            duration
                        );
                    }
                }
                writer.flush();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return; 
        }

        // STANDARD SEARCH / FILTER ACTION
        String keyword = request.getParameter("keyword");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String role = request.getParameter("role");

        List<SecurityLog> logs = SecurityLog.searchLogs(keyword, fromDate, toDate, role);
        request.setAttribute("logs", logs);

        RequestDispatcher rd = request.getRequestDispatcher("securitylog.jsp");
        rd.forward(request, response);
    }
}