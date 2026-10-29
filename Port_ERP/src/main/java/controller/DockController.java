package controller;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Dock;

@WebServlet("/DockController")
public class DockController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private boolean isAuthorized(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        
        if (session == null || session.getAttribute("user_id") == null) {
            req.setAttribute("error", "Access Denied. Please log in first.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return false;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equalsIgnoreCase("Dock Manager") || 
                              role.equalsIgnoreCase("Port Manager") || 
                              role.equalsIgnoreCase("Administrator"))) {
            
            req.setAttribute("message", "FAIL: Access Denied. Your profile role (" + (role != null ? role : "None") + ") lacks clearance for Dock Operations.");
            req.getRequestDispatcher("dashboard").forward(req, resp);
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        if (!isAuthorized(req, resp)) return;
        
        Dock dock = new Dock();
        req.setAttribute("dockList", dock.viewDock());
        
        req.getRequestDispatcher("Dock.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAuthorized(req, resp)) return;

        Dock dock = new Dock();
        String add          = req.getParameter("add");
        String update       = req.getParameter("update");
        String delete       = req.getParameter("delete");
        String search       = req.getParameter("search");
        String searchStatus = req.getParameter("searchStatus");

        try {
            // ── ADD DOCK ───────────────────────────────────────────────────
            if (add != null) {
                dock.setDockName(req.getParameter("dockName"));
                dock.setStatus(req.getParameter("status"));
                dock.addDock(dock);
                resp.sendRedirect("DockController?added=true");
            }

            // ── UPDATE (name + status together) ────────────────────────────
            else if (update != null) {
                int dockId = Integer.parseInt(req.getParameter("dockId"));
                String targetStatus = req.getParameter("status");
                
                // SRS FR-56 Compliance Guard: Prevent manual modifications from altering or overriding
                // an actively 'Occupied' allocation state via the standard editing form.
                if ("Occupied".equalsIgnoreCase(targetStatus)) {
                    resp.sendRedirect("DockController?error=true");
                    return;
                }
                
                dock.setDockId(dockId);
                dock.setDockName(req.getParameter("dockName"));
                dock.setStatus(targetStatus);
                dock.updateDockName(dock);
                dock.updateDockStatus(dock);
                resp.sendRedirect("DockController?updated=true");
            }

            // ── DELETE DOCK (blocked for Occupied status) ─────────────────
            else if (delete != null) {
                int dockId = Integer.parseInt(req.getParameter("dockId"));
                String dockStatus = req.getParameter("dockStatus");

                if ("Occupied".equalsIgnoreCase(dockStatus)) {
                    resp.sendRedirect("DockController?deleteBlocked=true");
                } else {
                    try {
                        dock.setDockId(dockId);
                        dock.deleteDock(dock); // Programmatically executes cascading dependency cleanup
                        resp.sendRedirect("DockController?deleted=true");
                    } catch (Exception runtimeEx) {
                        // NFR 7.4 Compliance: Propagate database failures safely using clean parameter redirections
                        resp.sendRedirect("DockController?error=true");
                    }
                }
            }

            // ── SEARCH BY NAME ────────────────────────────────────────────
            else if (search != null) {
                String keyword = req.getParameter("keyword");
                List<Dock> results = dock.searchDockByName(keyword);
                req.setAttribute("dockList",     dock.viewDock());
                req.setAttribute("searchResult", results);
                req.getRequestDispatcher("Dock.jsp").forward(req, resp);
            }

            // ── SEARCH BY STATUS ──────────────────────────────────────────
            else if (searchStatus != null) {
                String status = req.getParameter("status");
                List<Dock> results = dock.searchDockByStatus(status);
                req.setAttribute("dockList",     dock.viewDock());
                req.setAttribute("searchResult", results);
                req.getRequestDispatcher("Dock.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("DockController?error=true");
        }
    }
}