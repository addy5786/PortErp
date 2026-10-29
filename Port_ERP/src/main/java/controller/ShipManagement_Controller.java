package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ShipManagement;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

@WebServlet("/ShipManagement_Controller")
public class ShipManagement_Controller extends HttpServlet {

    /**
     * Centralized security method to check user authentication and role authorization.
     */
    private boolean isAuthorized(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        
        // 1. Check if user has an active session
        if (session == null || session.getAttribute("user_id") == null) {
            req.setAttribute("error", "Access Denied. Please log in first.");
            req.getRequestDispatcher("login.jsp").forward(req, res);
            return false;
        }

        // 2. Enforce strict role-based access control
        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equalsIgnoreCase("Ship Operator") || 
                              role.equalsIgnoreCase("Port Manager") || 
                              role.equalsIgnoreCase("Administrator"))) {
            
            // Redirect unauthorized users to the dashboard with an error banner message
            req.setAttribute("message", "FAIL: Access Denied. Your role (" + (role != null ? role : "None") + ") is not authorized to access Ship Management.");
            req.getRequestDispatcher("dashboard").forward(req, res);
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Enforce Authorization Check
        if (!isAuthorized(req, res)) return;

        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        ShipManagement sm = new ShipManagement();
        String searchInput = req.getParameter("searchInput");
        List<Map<String, Object>> shipList;

        if (searchInput != null && !searchInput.trim().isEmpty()) {
            searchInput = searchInput.trim();
            shipList    = sm.search_ship(searchInput);
            req.setAttribute("searchInput", searchInput); 
        } else {
            shipList = sm.view_ship_list();
        }

        req.setAttribute("shipList",  shipList);
        req.setAttribute("operators", sm.view_operators());
        loadShipDetails(req, sm, shipList);

        req.getRequestDispatcher("shipManagement.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Enforce Authorization Check
        if (!isAuthorized(req, res)) return;

        String action  = req.getParameter("action");
        String message = null;

        ShipManagement sm   = new ShipManagement();
        ShipManagement ship = new ShipManagement();

        if ("register".equals(action)) {
            ship.setShipName(req.getParameter("shipName"));
            ship.setStatus(req.getParameter("status"));

            // SECURE UPDATE: Enforce backend extraction directly from current HTTP Session context
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("user_id") != null) {
                try {
                    int loggedInUserId = Integer.parseInt(session.getAttribute("user_id").toString());
                    ship.setOperatorId(loggedInUserId);
                } catch (NumberFormatException e) {
                    message = "Invalid or corrupt session context metadata attributes.";
                    reloadAndForward(req, res, sm, message);
                    return;
                }
            } else {
                message = "Session reference expired. Please sign back into your portal profile account.";
                reloadAndForward(req, res, sm, message);
                return;
            }

            try {
                ship.setArrivalDate(Timestamp.valueOf(req.getParameter("arrivalDate").replace("T", " ") + ":00"));
                ship.setDepartureDate(Timestamp.valueOf(req.getParameter("departureDate").replace("T", " ") + ":00"));
            } catch (IllegalArgumentException e) {
                message = "Invalid date format. Please use the date picker.";
                reloadAndForward(req, res, sm, message);
                return;
            }

            message = sm.register_ship(ship);

        } else if ("update".equals(action)) {
            try {
                ship.setShipId(Integer.parseInt(req.getParameter("shipId")));
                ship.setShipName(req.getParameter("shipName"));
                ship.setStatus(req.getParameter("status"));

                String opId = req.getParameter("operatorId");
                ship.setOperatorId((opId != null && !opId.isEmpty()) ? Integer.parseInt(opId) : 0);

                String rawArr = req.getParameter("arrivalDate");
                String rawDep = req.getParameter("departureDate");
                if (rawArr != null && !rawArr.isEmpty())
                    ship.setArrivalDate(Timestamp.valueOf(rawArr.replace("T", " ") + ":00"));
                if (rawDep != null && !rawDep.isEmpty())
                    ship.setDepartureDate(Timestamp.valueOf(rawDep.replace("T", " ") + ":00"));

            } catch (IllegalArgumentException e) {
                message = "Invalid input: " + e.getMessage();
                reloadAndForward(req, res, sm, message);
                return;
            }

            message = sm.update_ship(ship);

        } else if ("delete".equals(action)) {
            try {
                ship.setShipId(Integer.parseInt(req.getParameter("shipId")));
            } catch (NumberFormatException e) {
                message = "Invalid ship ID.";
                reloadAndForward(req, res, sm, message);
                return;
            }

            message = sm.delete_ship(ship);
        }

        reloadAndForward(req, res, sm, message);
    }

    private void reloadAndForward(HttpServletRequest req, HttpServletResponse res, ShipManagement sm, String message)
            throws ServletException, IOException {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        req.setAttribute("message",   message);
        req.setAttribute("operators", sm.view_operators());

        List<Map<String, Object>> shipList = sm.view_ship_list();
        req.setAttribute("shipList", shipList);
        loadShipDetails(req, sm, shipList);

        req.getRequestDispatcher("shipManagement.jsp").forward(req, res);
    }

    private void loadShipDetails(HttpServletRequest req, ShipManagement sm, List<Map<String, Object>> shipList) {
        if (shipList == null || shipList.isEmpty()) return;
        for (Map<String, Object> ship : shipList) {
            int id = Integer.parseInt(String.valueOf(ship.get("ship_id")));
            req.setAttribute("containers_" + id, sm.view_ship_containers(id));
            req.setAttribute("dock_"       + id, sm.view_ship_dock(id));
        }
    }
}