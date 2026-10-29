package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/UserController")
public class UserController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Validate session authentication state first
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        int adminRoleId = getAdminRoleId(req);

        String insert     = req.getParameter("insert");
        String update     = req.getParameter("update");
        String activate   = req.getParameter("activate");
        String deactivate = req.getParameter("deactivate");

        String absoluteSuccessMsg = "";

        try {
            if (insert != null) {
                String name     = req.getParameter("name");
                String email    = req.getParameter("email");
                String password = req.getParameter("password1");
                String roleIdStr = req.getParameter("roleId");

                if (isBlank(name) || isBlank(email) || isBlank(password) || isBlank(roleIdStr)) {
                    setError(req, "All fields are required.");
                    resp.sendRedirect(req.getContextPath() + "/UserController");
                    return;
                }

                User user = new User();
                user.setAdminRoleId(adminRoleId);
                user.setName(name.trim());
                user.setEmail(email.trim().toLowerCase());
                user.setPassword(password);
                user.setRoleId(Integer.parseInt(roleIdStr));

                user.add_user();
                absoluteSuccessMsg = "User account has been created successfully!";

            } else if (update != null) {
                String userIdStr = req.getParameter("userId");
                String name      = req.getParameter("name");
                String email     = req.getParameter("email");
                String roleIdStr = req.getParameter("roleId");

                if (isBlank(userIdStr) || isBlank(name) || isBlank(email) || isBlank(roleIdStr)) {
                    setError(req, "All fields are required.");
                    resp.sendRedirect(req.getContextPath() + "/UserController");
                    return;
                }

                User user = new User();
                user.setAdminRoleId(adminRoleId);
                user.setUserId(Integer.parseInt(userIdStr));
                user.setName(name.trim());
                user.setEmail(email.trim().toLowerCase());
                user.setRoleId(Integer.parseInt(roleIdStr));

                user.update_user_name();
                user.update_user_email();
                user.update_user_role();
                absoluteSuccessMsg = "Modifications is done safely.";

            } else if (activate != null) {
                String userIdStr = req.getParameter("userId");
                if (isBlank(userIdStr)) {
                    setError(req, "User ID is missing.");
                    resp.sendRedirect(req.getContextPath() + "/UserController");
                    return;
                }

                User user = new User();
                user.setAdminRoleId(adminRoleId);
                user.setUserId(Integer.parseInt(userIdStr));
                user.activate_user();
                absoluteSuccessMsg = "User profile activated successfully.";

            } else if (deactivate != null) {
                String userIdStr = req.getParameter("userId");
                if (isBlank(userIdStr)) {
                    setError(req, "User ID is missing.");
                    resp.sendRedirect(req.getContextPath() + "/UserController");
                    return;
                }

                User user = new User();
                user.setAdminRoleId(adminRoleId);
                user.setUserId(Integer.parseInt(userIdStr));
                user.deactivate_user();
                absoluteSuccessMsg = "User profile deactivated successfully.";
            }

            String encodedMsg = URLEncoder.encode(absoluteSuccessMsg, StandardCharsets.UTF_8.toString());
            resp.sendRedirect(req.getContextPath() + "/UserController?toastMsg=" + encodedMsg);

        } catch (NumberFormatException e) {
            setError(req, "Invalid numeric input: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/UserController");

        } catch (Exception e) {
            e.printStackTrace();
            setError(req, "Operation failed: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/UserController");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Intercept unauthorized requests lacking structural session identities
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // Forward valid core identities to our presentation pipeline
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        
        req.setAttribute("username", username);
        req.setAttribute("role", role);

        loadUsers(req, resp);
    }

    private void loadUsers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String jspPath = "usermanage.jsp"; 
        try {
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("errorMsg") != null) {
                req.setAttribute("errorMsg", session.getAttribute("errorMsg"));
                session.removeAttribute("errorMsg");
            }

            User model = new User();
            ArrayList<User> userList = model.get_all_users();
            req.setAttribute("userList", userList != null ? userList : new ArrayList<User>());
            req.getRequestDispatcher(jspPath).forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "Could not load data records: " + e.getMessage());
            req.setAttribute("userList", new ArrayList<User>());
            req.getRequestDispatcher(jspPath).forward(req, resp);
        }
    }

    private void setError(HttpServletRequest req, String message) {
        req.getSession(true).setAttribute("errorMsg", message);
    }

    private int getAdminRoleId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            Object val = session.getAttribute("adminRoleId");
            if (val instanceof Integer) {
                return (Integer) val;
            }
        }
        return 1;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }  
}