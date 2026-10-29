package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Container;

@WebServlet("/ContainerController")
public class ContainerController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            request.setAttribute("error", "Access Denied. Please log in first.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return false;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equalsIgnoreCase("Ship Operator") || 
                              role.equalsIgnoreCase("Port Manager") || 
                              role.equalsIgnoreCase("Administrator"))) {
            
            request.setAttribute("message", "FAIL: Access Denied. Your role (" + (role != null ? role : "None") + ") is not authorized to access Container Management.");
            request.getRequestDispatcher("dashboard").forward(request, response);
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthorized(request, response)) return;

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma",        "no-cache");
        response.setDateHeader("Expires",   0);

        String action = request.getParameter("action");
        if (action == null) action = "list";

        String flashMessage = (String) request.getSession().getAttribute("flashMessage");
        if (flashMessage != null) {
            request.setAttribute("message", flashMessage);
            request.getSession().removeAttribute("flashMessage");
        }

        try {
            switch (action) {
                case "delete":
                    int delId = Integer.parseInt(request.getParameter("container_id"));
                    request.getSession().setAttribute("flashMessage", Container.deleteContainer(delId));
                    response.sendRedirect("ContainerController?action=list");
                    return; // Stop processing block execution during redirect paths

                case "details":
                    int detailId = Integer.parseInt(request.getParameter("container_id"));
                    request.setAttribute("details",             Container.viewContainerDetails(detailId));
                    request.setAttribute("selectedContainerId", detailId);
                    request.setAttribute("containers",          Container.viewContainers());
                    break;

                case "search":
                    String searchInput = request.getParameter("searchInput");
                    if (searchInput != null && !searchInput.trim().isEmpty()) {
                        request.setAttribute("containers",  Container.filterContainer(searchInput.trim()));
                        request.setAttribute("searchInput", searchInput.trim());
                    } else {
                        request.setAttribute("containers", Container.viewContainers());
                    }
                    break;

                default: // list
                    request.setAttribute("containers", Container.viewContainers());
                    break;
            }
            
            // CRITICAL SYSTEM FIX: Always populate dynamic list right before rendering the view dispatcher
            List<String[]> dockedShips = Container.getDockedShips();
            request.setAttribute("dockedShipsList", dockedShips);
            request.getRequestDispatcher("containermanagement.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("flashMessage", "Error: " + e.getMessage());
            response.sendRedirect("ContainerController?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthorized(request, response)) return;

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                Container c = new Container();
                c.setContainer_type(request.getParameter("container_type"));
                c.setStatus(request.getParameter("status"));
                c.setShip_id(Integer.parseInt(request.getParameter("ship_id")));
                request.getSession().setAttribute("flashMessage", c.addContainer(c));
                response.sendRedirect("ContainerController?action=list");

            } else if ("update".equals(action)) {
                Container c = new Container();
                c.setContainer_id(Integer.parseInt(request.getParameter("container_id")));
                c.setContainer_type(request.getParameter("container_type"));
                c.setStatus(request.getParameter("status"));
                c.setShip_id(Integer.parseInt(request.getParameter("ship_id")));
                request.getSession().setAttribute("flashMessage", c.updateContainer(c));
                response.sendRedirect("ContainerController?action=list");

            } else {
                response.sendRedirect("ContainerController?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("flashMessage", "Error: " + e.getMessage());
            response.sendRedirect("ContainerController?action=list");
        }
    }
}