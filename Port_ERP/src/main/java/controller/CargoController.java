package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Cargo;
import model.CargoMovement;

@WebServlet({"/CargoController", "/cargo_controller", ""})
@WebFilter("/cargo.jsp")
public class CargoController extends HttpServlet implements Filter {
    private static final long serialVersionUID = 1L;

    public void init() {}

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        init();
    }

    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user_id") == null) {
            request.setAttribute("error", "Access Denied. Please log in first.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return false;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !(role.equalsIgnoreCase("Cargo Handler") || 
                              role.equalsIgnoreCase("Port Manager") || 
                              role.equalsIgnoreCase("Administrator"))) {
            
            request.setAttribute("message", "FAIL: Access Denied. Your profile role (" + (role != null ? role : "None") + ") lacks access clearance for Cargo Operations.");
            request.getRequestDispatcher("dashboard").forward(request, response);
            return false;
        }
        return true;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        
        if (!isAuthorized(req, res)) return;
        
        if (req.getAttribute("listCargo") == null) {
            req.getRequestDispatcher("/CargoController").forward(request, response);
        } else {
            chain.doFilter(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!isAuthorized(request, response)) return;
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "delete":
                    deleteCargo(request, response);
                    break;
                case "history":
                    viewMovementHistory(request, response);
                    break;
                case "all_history":
                    viewAllMovementHistory(request, response);
                    break;
                case "list":
                default:
                    listCargo(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        if (!isAuthorized(request, response)) return;
            
        String action = request.getParameter("action");
        
        if ("insert".equals(action)) {
            insertCargo(request, response);
        } else if ("update".equals(action)) {
            updateCargo(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void listCargo(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String containerFilter = request.getParameter("containerFilter");
        String statusFilter = request.getParameter("statusFilter");
        
        List<Cargo> listCargo;
        
        // Dynamic payload binding containing empty container profiles
        List<String[]> emptyContainers = Cargo.getEmptyContainers();
        request.setAttribute("emptyContainersList", emptyContainers);
        
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasContainer = containerFilter != null && !containerFilter.trim().isEmpty();
        boolean hasStatus = statusFilter != null && !statusFilter.trim().isEmpty() && !statusFilter.trim().equalsIgnoreCase("All");
        
        if (hasKeyword || hasContainer || hasStatus) {
            listCargo = Cargo.searchCargo(keyword, containerFilter, statusFilter);
            request.setAttribute("searchKeyword", keyword != null ? keyword.trim() : "");
            request.setAttribute("containerFilter", containerFilter != null ? containerFilter.trim() : "");
            request.setAttribute("statusFilter", statusFilter != null ? statusFilter.trim() : "");
        } else {
            listCargo = Cargo.viewAllCargo();
        }
        
        request.setAttribute("listCargo", listCargo);
        request.getRequestDispatcher("cargo.jsp").forward(request, response);
    }

    private void insertCargo(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        int currentUserId = (Integer) session.getAttribute("user_id");

        Cargo newCargo = new Cargo();
        String containerIdRaw = request.getParameter("containerId");
        newCargo.setContainerId(Integer.parseInt(containerIdRaw));
        newCargo.setDescription(request.getParameter("description"));
        newCargo.setWeight(Double.parseDouble(request.getParameter("weight")));
        newCargo.setStatus(request.getParameter("status"));
        
        try {
            boolean success = newCargo.addCargo(currentUserId);
            if (success) {
                response.sendRedirect("CargoController?action=list&msg=added");
            } else {
                response.sendRedirect("CargoController?action=list&msg=failed");
            }
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("Container does not exist")) {
                response.sendRedirect("CargoController?action=list&msg=invalid_container&badId=" + containerIdRaw);
            } else {
                response.sendRedirect("CargoController?action=list&msg=failed");
            }
        }
    }

    private void updateCargo(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        int currentUserId = (Integer) session.getAttribute("user_id");

        Cargo cargo = new Cargo();
        cargo.setCargoId(Integer.parseInt(request.getParameter("cargoId")));
        String containerIdRaw = request.getParameter("containerId");
        cargo.setContainerId(Integer.parseInt(containerIdRaw));
        cargo.setDescription(request.getParameter("description"));
        cargo.setWeight(Double.parseDouble(request.getParameter("weight")));
        cargo.setStatus(request.getParameter("status"));
        
        try {
            boolean success = cargo.updateCargo(currentUserId);
            if (success) {
                response.sendRedirect("CargoController?action=list&msg=updated");
            } else {
                response.sendRedirect("CargoController?action=list&msg=failed");
            }
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("Container does not exist")) {
                response.sendRedirect("CargoController?action=list&msg=invalid_container&badId=" + containerIdRaw);
            } else {
                response.sendRedirect("CargoController?action=list&msg=failed");
            }
        }
    }

    private void deleteCargo(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Cargo.deleteCargo(id);
        response.sendRedirect("CargoController?action=list&msg=deleted");
    }

    private void viewMovementHistory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int cargoId = Integer.parseInt(request.getParameter("id"));
        List<CargoMovement> history = Cargo.viewCargoMovementHistory(cargoId);
        
        request.setAttribute("movementHistory", history);
        request.setAttribute("cargoId", cargoId);
        request.getRequestDispatcher("cargo_movement.jsp").forward(request, response);
    }

    private void viewAllMovementHistory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("logKeyword");
        String typeFilter = request.getParameter("logTypeFilter");
        
        List<CargoMovement> history;
        
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasTypeFilter = typeFilter != null && !typeFilter.trim().isEmpty() && !typeFilter.trim().equalsIgnoreCase("All");
        
        if (hasKeyword || hasTypeFilter) {
            history = Cargo.searchCargoMovements(keyword, typeFilter);
            request.setAttribute("logKeyword", keyword != null ? keyword.trim() : "");
            request.setAttribute("logTypeFilter", typeFilter != null ? typeFilter.trim() : "");
        } else {
            history = Cargo.viewAllCargoMovements();
        }
        
        request.setAttribute("movementHistory", history);
        request.setAttribute("cargoId", null); 
        request.getRequestDispatcher("cargo_movement.jsp").forward(request, response);
    }
}