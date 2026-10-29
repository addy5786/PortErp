package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.DockAllocation;

import java.io.IOException;

@WebServlet("/DockAllocation_Controller")
public class DockAllocation_Controller extends HttpServlet {

	/**
	 * Centralized structural filter to check authentication and precise role authorizations.
	 */
	private boolean isAuthorized(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		
		// 1. Verify user is authenticated
		if (session == null || session.getAttribute("user_id") == null) {
			req.setAttribute("error", "Access Denied. Please log in first.");
			req.getRequestDispatcher("login.jsp").forward(req, res);
			return false;
		}

		// 2. Validate precise management access tier
		String role = (String) session.getAttribute("role");
		if (role == null || !(role.equalsIgnoreCase("Dock Manager") || 
		                      role.equalsIgnoreCase("Port Manager") || 
		                      role.equalsIgnoreCase("Administrator"))) {
			
			// Unauthorized profiles bounce back to the dashboard context mapping
			req.setAttribute("message", "FAIL: Access Denied. Your profile role (" + (role != null ? role : "None") + ") lacks clearance for Dock Allocations.");
			req.getRequestDispatcher("dashboard").forward(req, res);
			return false;
		}
		return true;
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res)
			throws ServletException, IOException {
		
		if (!isAuthorized(req, res)) return;

		// Consume temporary flash session messages uploaded during POST lifecycle requests
		HttpSession session = req.getSession(false);
		String flashMessage = (String) session.getAttribute("flashMessage");
		if (flashMessage != null) {
			req.setAttribute("message", flashMessage);
			session.removeAttribute("flashMessage"); 
		}

		// Transfer orchestration directly to view layers; list building and data validation execution shifts inline to JSP
		req.getRequestDispatcher("dockAllocation.jsp").forward(req, res);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		if (!isAuthorized(req, res)) return;

		String action = req.getParameter("action");
		String message = null;
		DockAllocation da = new DockAllocation();

		if ("allocate".equals(action)) {
			try {
				da.setShipId(Integer.parseInt(req.getParameter("shipId")));
				da.setDockId(Integer.parseInt(req.getParameter("dockId")));
			} catch (NumberFormatException e) {
				message = "Please select a valid ship and dock before confirming.";
				req.getSession().setAttribute("flashMessage", message);
				res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
				return;
			}

			String rawAlloc = req.getParameter("allocationTime");
			String rawRelease = req.getParameter("releaseTime");

			if (rawAlloc == null || rawAlloc.isEmpty() || rawRelease == null || rawRelease.isEmpty()) {
				message = "Allocation start time and release time are both required.";
				req.getSession().setAttribute("flashMessage", message);
				res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
				return;
			}

			String formattedAlloc = rawAlloc.replace("T", " ");
			String formattedRelease = rawRelease.replace("T", " ");
			da.setAllocationTime(formattedAlloc);
			da.setReleaseTime(formattedRelease);

			if (da.getReleaseTime().compareTo(da.getAllocationTime()) <= 0) {
				message = "Release time must be after allocation time.";
				req.getSession().setAttribute("flashMessage", message);
				res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
				return;
			}

			// 3-hour proximity check: allocation time must be within 3 hours from now
			java.time.LocalDateTime allocationDT = java.time.LocalDateTime.parse(formattedAlloc,
					java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
			java.time.LocalDateTime now = java.time.LocalDateTime.now();
			long hoursUntilAllocation = java.time.temporal.ChronoUnit.HOURS.between(now, allocationDT);

			if (hoursUntilAllocation > 3) {
				message = "Allocation can only be made within 3 hours of the allocation start time.";
				req.getSession().setAttribute("flashMessage", message);
				res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
				return;
			}

			String isFinalized = req.getParameter("finalizedSubmit");
			if (isFinalized == null || !"true".equals(isFinalized)) {
				req.setAttribute("showConfirmation", true);
				req.setAttribute("selectedShipId", da.getShipId());
				req.setAttribute("selectedDockId", da.getDockId());
				req.setAttribute("confirmedAllocTime", rawAlloc);
				req.setAttribute("confirmedReleaseTime", rawRelease);
				req.getRequestDispatcher("dockAllocation.jsp").forward(req, res);
				return;
			}

			message = da.allocate_dock(da);
		} else if ("release".equals(action)) {
			int allocId;
			try {
				allocId = Integer.parseInt(req.getParameter("allocationId"));
				da.setAllocationId(allocId);
			} catch (NumberFormatException e) {
				message = "Invalid allocation ID.";
				req.getSession().setAttribute("flashMessage", message);
				res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
				return;
			}

			String finalizedRelease = req.getParameter("finalizedRelease");
			if (finalizedRelease == null || !"true".equals(finalizedRelease)) {
				req.setAttribute("showReleaseConfirmation", true);
				req.setAttribute("releaseAllocationId", allocId);
				req.setAttribute("releaseShipName", req.getParameter("hiddenShipName"));
				req.setAttribute("releaseDockName", req.getParameter("hiddenDockName"));
				req.getRequestDispatcher("dockAllocation.jsp").forward(req, res);
				return;
			}

			message = da.release_dock(da);
		} else if ("update".equals(action)) {
			try {
				da.setAllocationId(Integer.parseInt(req.getParameter("allocationId")));

				String newDockId = req.getParameter("newDockId");
				da.setDockId((newDockId != null && !newDockId.isEmpty()) ? Integer.parseInt(newDockId) : 0);

				String rawAlloc = req.getParameter("newAllocationTime");
				da.setAllocationTime((rawAlloc != null && !rawAlloc.isEmpty()) ? rawAlloc.replace("T", " ") : null);

				String rawRelease = req.getParameter("newReleaseTime");
				da.setReleaseTime((rawRelease != null && !rawRelease.isEmpty()) ? rawRelease.replace("T", " ") : null);

				if (da.getAllocationTime() != null && da.getReleaseTime() != null) {
					if (da.getReleaseTime().compareTo(da.getAllocationTime()) <= 0) {
						message = "Release time must be after allocation time.";
						req.getSession().setAttribute("flashMessage", message);
						res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
						return;
					}
				}

			} catch (NumberFormatException e) {
				message = "Invalid allocation ID or dock ID.";
				req.getSession().setAttribute("flashMessage", message);
				res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
				return;
			}
			message = da.update_dock_allocation(da);
		}

		// Handle completion response patterns securely via PRG (Post-Redirect-Get) routing configurations
		if (message != null && !message.isEmpty()) {
			req.getSession().setAttribute("flashMessage", message);
			res.sendRedirect(req.getContextPath() + "/DockAllocation_Controller?tab=" + req.getParameter("tab"));
		} else {
			req.getRequestDispatcher("dockAllocation.jsp").forward(req, res);
		}
	}
}