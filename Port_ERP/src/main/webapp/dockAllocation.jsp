<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="model.DockAllocation"%>
<%
// Block template parsing instantly if user tries to bypass controller context maps
if (session == null || session.getAttribute("user_id") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

// Safely extract user role to avoid NullPointerExceptions
String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "";

// Fallback Tab Target Processing Logic (Replaces functionality decoupled from controller helper)
String activeTab = request.getAttribute("activeTab") != null ? (String) request.getAttribute("activeTab") : request.getParameter("tab");
if (activeTab == null || activeTab.isEmpty()) {
	activeTab = "active";
}
request.setAttribute("activeTab", activeTab);

DockAllocation da = new DockAllocation();

// Ensure fundamental database entity validation sets are bound securely
if (request.getAttribute("ships") == null) {
	request.setAttribute("ships", da.view_anchored_ships());
}
if (request.getAttribute("docks") == null) {
	request.setAttribute("docks", da.view_available_docks());
}

// Fetch source record models lazily inside view lifecycle bounds
List<Map<String, Object>> activeAllocations = (List<Map<String, Object>>) request.getAttribute("activeAllocations");
if (activeAllocations == null) {
	activeAllocations = da.view_active_allocations();
}

List<Map<String, Object>> historyAllocations = (List<Map<String, Object>>) request.getAttribute("historyAllocations");
if (historyAllocations == null) {
	historyAllocations = da.view_allocation_history();
}

// Resolve query search context criteria securely via Stream parsing engines directly inside view context mapping
String searchInput = (String) request.getAttribute("searchInput");
if (searchInput == null) {
	searchInput = request.getParameter("searchInput");
}

if (searchInput != null && !searchInput.trim().isEmpty()) {
	String keyword = searchInput.trim().toLowerCase();
	if ("active".equals(activeTab)) {
		activeAllocations = activeAllocations.stream().filter(row -> {
			String allocId = row.get("allocation_id") != null ? String.valueOf(row.get("allocation_id")).toLowerCase() : "";
			String shipName = row.get("ship_name") != null ? String.valueOf(row.get("ship_name")).toLowerCase() : "";
			String dockName = row.get("dock_name") != null ? String.valueOf(row.get("dock_name")).toLowerCase() : "";
			return allocId.contains(keyword) || shipName.contains(keyword) || dockName.contains(keyword);
		}).collect(java.util.stream.Collectors.toList());
	} else if ("history".equals(activeTab)) {
		historyAllocations = historyAllocations.stream().filter(row -> {
			String allocId = row.get("allocation_id") != null ? String.valueOf(row.get("allocation_id")).toLowerCase() : "";
			String shipName = row.get("ship_name") != null ? String.valueOf(row.get("ship_name")).toLowerCase() : "";
			String dockName = row.get("dock_name") != null ? String.valueOf(row.get("dock_name")).toLowerCase() : "";
			return allocId.contains(keyword) || shipName.contains(keyword) || dockName.contains(keyword);
		}).collect(java.util.stream.Collectors.toList());
	}
	request.setAttribute("searchInput", searchInput.trim());
}

// Save values down into page request scopes to safely satisfy downstream component mappings
request.setAttribute("activeAllocations", activeAllocations);
request.setAttribute("historyAllocations", historyAllocations);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dock Allocation | Port Management System</title>
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://unpkg.com/lucide@latest"></script>
<style>
.bg-port-sidebar { background-color: #20242D; } 
.bg-port-active { background-color: #FFEAD8; } 
.text-port-active { color: #FFEAD8; }
.bg-port-accent { background-color: #334155; } 

.nav-link {
	display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem; border-radius: 0.5rem;
	transition-property: all; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
	transition-duration: 150ms; font-size: 0.875rem; justify-content: flex-start;
}
.nav-link-inactive { color: #E2E8F0; }
.nav-link-inactive:hover { background-color: rgba(255, 255, 255, 0.06); color: #FFFFFF; }
.nav-icon-inactive { color: #94A3B8; width: 1rem; height: 1rem; flex-shrink: 0; }
.nav-link-inactive:hover .nav-icon-inactive { color: #FFEAD8; }

.form-step-card { padding: 1.25rem; border: 1px solid #E2E8F0; border-radius: 0.5rem; background-color: #F8FAFC; display: flex; flex-direction: column; gap: 0.75rem; }
.form-input-field { width: 100%; padding: 0.625rem 0.75rem; background-color: #ffffff; border: 1px solid #CBD5E1; border-radius: 0.375rem; font-size: 0.875rem; transition: all 0.2s; }
.form-input-field:focus { outline: 2px solid transparent; outline-offset: 2px; box-shadow: 0 0 0 2px #475569; border-color: #475569; }

#sidebar { transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
.sidebar-text { transition: opacity 0.2s ease, max-width 0.2s ease; max-width: 200px; opacity: 1; }
.sidebar-collapsed .sidebar-text { max-width: 0; opacity: 0; overflow: hidden; display: none; }
.sidebar-collapsed .header-wrapper { justify-content: center; padding-left: 0; padding-right: 0; }
.sidebar-collapsed { cursor: ew-resize; }
.sidebar-collapsed * { cursor: ew-resize !important; }
.sidebar-collapsed .toggle-btn-sidebar { opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; }
.toggle-btn-sidebar { transition: opacity 0.2s ease, visibility 0.2s ease; opacity: 1; visibility: visible; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

@keyframes instantHide {
	0% { opacity: 1; visibility: visible; transform: scale(1); }
	85% { opacity: 1; visibility: visible; transform: scale(1); }
	100% { opacity: 0; visibility: hidden; transform: scale(0.95); display: none; height: 0; width: 0; padding: 0; margin: 0; border: none; }
}
.clear-message-instantly { animation: instantHide 5s steps(1, end) forwards; }
</style>
</head>
<body class="bg-slate-50 text-slate-800 font-sans flex h-screen overflow-hidden">

	<%-- SIDEBAR --%>
	<aside id="sidebar" onclick="handleSidebarClick(event)"
		class="w-64 bg-port-sidebar text-white flex flex-col justify-between hidden md:flex h-screen sticky top-0 flex-shrink-0 transition-all duration-300 shadow-xl z-20">
		<div class="flex flex-col overflow-y-auto flex-1 no-scrollbar relative">
			<div class="header-wrapper p-5 flex items-center justify-between border-b border-slate-700/60 sticky top-0 bg-port-sidebar z-10 transition-all duration-300">
				<div class="flex items-center gap-3 min-w-0">
					<div class="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center flex-shrink-0 border border-slate-700 mx-auto">
						<i data-lucide="anchor" class="text-slate-300 w-5 h-5 flex-shrink-0"></i>
					</div>
					<div class="sidebar-text">
						<span class="font-bold text-sm tracking-wider block whitespace-nowrap text-slate-200">Port ERP</span> 
                        <span class="text-[10px] text-slate-400 block -mt-0.5 whitespace-nowrap uppercase tracking-widest">Management</span>
					</div>
				</div>
				<button id="toggleBtn" onclick="toggleSidebar(event)"
					class="toggle-btn-sidebar text-slate-400 hover:text-white p-1 rounded hover:bg-white/5 transition hidden md:block flex-shrink-0">
					<i id="collapseIcon" data-lucide="chevron-left" class="w-4 h-4"></i>
				</button>
			</div>

			<nav class="p-4 space-y-1.5 flex-1">
				<a href="dashboard" class="nav-link nav-link-inactive" title="Dashboard"> 
                    <i data-lucide="layout-dashboard" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">Dashboard</span>
				</a> 

				<% if (userRole.equalsIgnoreCase("Administrator")) { %>
                <a href="UserController" class="nav-link nav-link-inactive" title="User Management"> 
                    <i data-lucide="users" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">User Management</span>
				</a> 
				<% } %>

				<% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
                <a href="ShipManagement_Controller" class="nav-link nav-link-inactive" title="Ship Management"> 
                    <i data-lucide="ship" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">Ship Management</span>
				</a> 
				<% } %>

				<a href="DockController" class="nav-link nav-link-inactive" title="Dock Management"> 
                    <i data-lucide="layers" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">Dock Management</span>
				</a> 

				<a href="dockAllocation.jsp" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="Dock Allocation"> 
                    <i data-lucide="git-pull-request" class="w-4 h-4 text-slate-900 flex-shrink-0"></i> 
                    <span class="sidebar-text whitespace-nowrap">Dock Allocation</span>
				</a> 

				<% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
                <a href="ContainerController" class="nav-link nav-link-inactive" title="Container Management">
					<i data-lucide="box" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">Container Management</span>
				</a> 
                <a href="CargoController?action=list" class="nav-link nav-link-inactive" title="Cargo Management"> 
                    <i data-lucide="package" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">Cargo Management</span>
				</a> 
                <a href="CargoController?action=all_history" class="nav-link nav-link-inactive" title="Cargo Logs">
                    <i data-lucide="clipboard-list" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Logs</span>
                </a>
                <a href="securitylog.jsp" class="nav-link nav-link-inactive" title="Security Log">
                    <i data-lucide="shield-alert" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Security Log</span>
                </a>
				<% } %>

				<a href="profile.jsp" class="nav-link nav-link-inactive" title="Profile / Settings"> 
                    <i data-lucide="user-cog" class="nav-icon-inactive"></i> 
                    <span class="sidebar-text whitespace-nowrap">Profile / Settings</span>
				</a>
			</nav>
		</div>

		<div class="p-4 border-t border-slate-700/60 text-xs text-slate-400 flex items-center justify-center gap-2 bg-black/20 overflow-hidden flex-shrink-0">
			<i data-lucide="shield-check" class="w-4 h-4 text-slate-400 flex-shrink-0"></i> 
            <span class="sidebar-text whitespace-nowrap">Role: <strong class="text-slate-300"><%= !userRole.equals("") ? userRole : "No Active Role" %></strong></span>
		</div>
	</aside>

	<div id="sidebarOverlay" onclick="toggleMobileSidebar()" class="fixed inset-0 bg-black/40 z-30 hidden md:hidden transition-opacity"></div>

	<div class="flex-1 flex flex-col min-w-0 h-screen overflow-y-auto">

		<%-- HEADER --%>
		<header class="h-16 bg-white border-b border-slate-200 flex items-center px-6 sticky top-0 z-10 shadow-sm flex-shrink-0">
			<div class="flex items-center gap-4">
				<button onclick="toggleMobileSidebar()" class="md:hidden text-slate-600 hover:text-slate-900 p-1 rounded hover:bg-slate-100">
					<i data-lucide="menu" class="w-5 h-5"></i>
				</button>
				<h1 class="text-lg font-bold text-slate-700 tracking-tight whitespace-nowrap flex items-center gap-2">
                    <i data-lucide="git-pull-request" class="w-5 h-5 text-slate-600"></i> Dock Allocation System
                </h1>
			</div>

			<div class="flex items-center gap-6 ml-auto">
				<div class="flex items-center gap-2 text-sm text-slate-600">
					<i data-lucide="user-circle" class="w-5 h-5 text-slate-500"></i> 
					<span>Welcome, <strong class="text-slate-800"><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong></span>
				</div>
				<a href="logout" onclick="return confirmLogout(event);" class="bg-port-accent hover:bg-slate-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors">Logout</a>
			</div>

			<%
			String msg = (String) request.getAttribute("message");
			if (msg != null && !msg.isEmpty()) {
				boolean isTargetMessage = msg.contains("Release time must be after allocation time")
				|| msg.contains("Dock already allocated for this time window")
				|| msg.toUpperCase().contains("DOCK ALLOCATED SUCCESSFULLY")
				|| msg.toUpperCase().contains("RELEASED SUCCESSFULLY") || msg.toUpperCase().contains("RELEASE FAILED")
				|| msg.toUpperCase().contains("ALLOCATION UPDATED SUCCESSFULLY")
				|| msg.toUpperCase().contains("ALLOCATION CAN ONLY BE MADE");
				if (isTargetMessage) {
					boolean isSuccess = msg.toUpperCase().contains("SUCCESS");
					String bannerClass = isSuccess ? "bg-emerald-50 border-2 border-emerald-300 text-emerald-900 " : "bg-red-50 border-2 border-red-300 text-red-900 ";
					String iconName = isSuccess ? "check-circle" : "alert-circle";
			%>
			<div class="absolute inset-x-0 top-16 flex items-center justify-center pointer-events-none z-50 pt-3">
				<div class="<%=bannerClass%> pointer-events-auto rounded-xl px-6 py-3.5 flex items-center gap-3.5 text-base font-bold shadow-xl max-w-md w-full border-l-8 clear-message-instantly transition-all duration-300 mx-4">
					<i data-lucide="<%=iconName%>" class="w-6 h-6 flex-shrink-0"></i> <span class="leading-snug"><%=msg%></span>
				</div>
			</div>
			<%
			}
			}
			%>
		</header>

		<%-- ALLOCATION CONFIRMATION MODAL --%>
		<%
		Boolean showConfirmation = (Boolean) request.getAttribute("showConfirmation");
		if (showConfirmation != null && showConfirmation) {
			int confirmShipId = (Integer) request.getAttribute("selectedShipId");
			int confirmDockId = (Integer) request.getAttribute("selectedDockId");
			String displayShipName = "Unknown Ship Target";
			String displayDockName = "Unknown Dock Target";
		%>
		<div class="fixed inset-0 bg-slate-900/40 backdrop-blur-xs z-50 flex items-center justify-center p-4">
			<div class="bg-white rounded-xl shadow-2xl border border-slate-200 max-w-lg w-full overflow-hidden">
				<div class="bg-port-sidebar px-6 py-4 text-white flex items-center gap-3">
					<i data-lucide="shield-alert" class="w-5 h-5 text-slate-400"></i>
					<h3 class="font-bold text-base">Verify Allocation Parameters</h3>
				</div>
				<div class="p-6 space-y-4 text-sm text-slate-600">
					<p class="text-xs text-slate-400">Please review the configuration fields carefully before writing data logs.</p>
					<div class="grid grid-cols-3 gap-2 py-2 border-y border-slate-100">
						<span class="font-semibold text-slate-500">Ship:</span> 
						<span class="col-span-2 text-slate-900 font-medium font-mono"> 
						<%
						List<Map<String, Object>> sList = (List<Map<String, Object>>) request.getAttribute("ships");
						if (sList != null) {
							for (Map<String, Object> s : sList) {
								if (Integer.parseInt(String.valueOf(s.get("ship_id"))) == confirmShipId) {
									displayShipName = String.valueOf(s.get("ship_name"));
									break;
								}
							}
						}
						%> <%=displayShipName%> (ID: <%=confirmShipId%>)
						</span> 
						
						<span class="font-semibold text-slate-500">Dock:</span> 
						<span class="col-span-2 text-slate-900 font-medium font-mono"> 
						<%
						List<Map<String, Object>> dList = (List<Map<String, Object>>) request.getAttribute("docks");
						if (dList != null) {
							for (Map<String, Object> d : dList) {
								if (Integer.parseInt(String.valueOf(d.get("dock_id"))) == confirmDockId) {
									displayDockName = String.valueOf(d.get("dock_name"));
									break;
								}
							}
						}
						%> <%=displayDockName%> (ID: <%=confirmDockId%>)
						</span> 
						
						<span class="font-semibold text-slate-500">Allocation Time:</span> <span class="col-span-2 text-slate-900 font-medium"><%=request.getAttribute("confirmedAllocTime")%></span>
						<span class="font-semibold text-slate-500">Release Time:</span> <span class="col-span-2 text-slate-900 font-medium"><%=request.getAttribute("confirmedReleaseTime")%></span>
					</div>
				</div>
				<div class="bg-slate-50 px-6 py-4 flex items-center justify-end gap-3 border-t border-slate-100">
					<a href="<%=request.getContextPath()%>/DockAllocation_Controller?tab=<%=activeTab%>" class="px-4 py-2 border border-slate-200 text-slate-600 hover:bg-slate-100 transition rounded-lg text-xs font-semibold">Cancel</a>
					<form action="<%=request.getContextPath()%>/DockAllocation_Controller" method="post">
						<input type="hidden" name="tab" value="<%=activeTab%>" />
						<input type="hidden" name="finalizedSubmit" value="true" /> 
                        <input type="hidden" name="action" value="allocate" /> 
                        <input type="hidden" name="shipId" value="<%=confirmShipId%>" /> 
                        <input type="hidden" name="dockId" value="<%=confirmDockId%>" /> 
                        <input type="hidden" name="allocationTime" value="<%=request.getAttribute("confirmedAllocTime")%>" /> 
                        <input type="hidden" name="releaseTime" value="<%=request.getAttribute("confirmedReleaseTime")%>" />
						<button type="submit" class="bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg text-xs font-semibold shadow-sm transition">Finalize & Submit</button>
					</form>
				</div>
			</div>
		</div>
		<%
		}
		%>

		<%-- RELEASE CONFIRMATION MODAL --%>
		<%
		Boolean showReleaseConfirmation = (Boolean) request.getAttribute("showReleaseConfirmation");
		if (showReleaseConfirmation != null && showReleaseConfirmation) {
			int releaseAllocId = (Integer) request.getAttribute("releaseAllocationId");
			String relShipName = (String) request.getAttribute("releaseShipName");
			String relDockName = (String) request.getAttribute("releaseDockName");
			if (relShipName == null || relDockName == null) {
				List<Map<String, Object>> fallbackList = (List<Map<String, Object>>) request.getAttribute("activeAllocations");
				if (fallbackList != null) {
			for (Map<String, Object> activeRow : fallbackList) {
				if (Integer.parseInt(String.valueOf(activeRow.get("allocation_id"))) == releaseAllocId) {
					relShipName = String.valueOf(activeRow.get("ship_name"));
					relDockName = String.valueOf(activeRow.get("dock_name"));
					break;
				}
			}
				}
			}
		%>
		<div class="fixed inset-0 bg-slate-900/40 backdrop-blur-xs z-50 flex items-center justify-center p-4">
			<div class="bg-white rounded-xl shadow-2xl border border-slate-200 max-w-lg w-full overflow-hidden">
				<div class="bg-port-sidebar px-6 py-4 text-white flex items-center gap-3">
					<i data-lucide="shield-alert" class="w-5 h-5 text-slate-400"></i>
					<h3 class="font-bold text-base">Confirm Operational Release</h3>
				</div>
				<div class="p-6 space-y-4 text-sm text-slate-600">
					<p class="text-sm text-slate-700 font-medium">Are you sure you want to release the following dock allocation slot?</p>
					<div class="grid grid-cols-3 gap-2 py-3 border-y border-slate-100 bg-slate-50/50 p-3 rounded-lg">
						<span class="font-semibold text-slate-500">Allocation ID:</span> <span class="col-span-2 text-slate-900 font-mono font-bold"><%=releaseAllocId%></span>
						<span class="font-semibold text-slate-500">Ship Name:</span> <span class="col-span-2 text-slate-900 font-medium"><%=relShipName%></span>
						<span class="font-semibold text-slate-500">Assigned Dock:</span> <span class="col-span-2 text-slate-900 font-medium font-mono text-xs"><%=relDockName%></span>
					</div>
					<p class="text-xs text-slate-400 flex items-center gap-1">
						<i data-lucide="info" class="w-3.5 h-3.5 text-slate-500"></i> This will clear real-time positioning metrics and mark the space as available.
					</p>
				</div>
				<div class="bg-slate-50 px-6 py-4 flex items-center justify-end gap-3 border-t border-slate-100">
					<a href="<%=request.getContextPath()%>/DockAllocation_Controller?tab=<%=activeTab%>" class="px-4 py-2 border border-slate-200 text-slate-600 hover:bg-slate-100 transition rounded-lg text-xs font-semibold">Abort Action</a>
					<form action="<%=request.getContextPath()%>/DockAllocation_Controller" method="post">
						<input type="hidden" name="tab" value="<%=activeTab%>" />
						<input type="hidden" name="action" value="release" /> 
                        <input type="hidden" name="finalizedRelease" value="true" /> 
                        <input type="hidden" name="allocationId" value="<%=releaseAllocId%>" />
						<button type="submit" class="bg-port-sidebar hover:bg-slate-800 text-white px-4 py-2 rounded-lg text-xs font-semibold shadow-sm transition flex items-center gap-1.5">
							<i data-lucide="check-circle" class="w-3.5 h-3.5"></i> Confirm Release
						</button>
					</form>
				</div>
			</div>
		</div>
		<%
		}
		%>

		<main class="p-6 max-w-7xl w-full mx-auto space-y-6 flex-1">

			<div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8]">
				<h2 class="text-2xl font-bold tracking-tight">Berth & Dock Assignment</h2>
				<p class="text-slate-300 text-sm mt-1">Schedule allocations and manage real-time vessel positioning efficiently.</p>
			</div>

			<%-- REQUEST FORM --%>
			<section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden" aria-label="Dock Allocation Wizard">
				<div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4">
					<span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Operational Tool</span>
					<h3 class="text-lg font-bold text-slate-700">New Allocation Request</h3>
				</div>
				<form action="<%=request.getContextPath()%>/DockAllocation_Controller" method="post" class="p-6 space-y-8" id="allocationForm">
					<input type="hidden" name="action" value="allocate" />
					<input type="hidden" name="tab" value="<%=activeTab%>" />
					<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">

						<div class="form-step-card">
							<div class="flex items-center gap-2 text-slate-700 font-semibold text-sm">
								<span class="w-5 h-5 rounded-full bg-port-sidebar text-white flex items-center justify-center text-xs">1</span>
								Select Ship
							</div>
							<select name="shipId" id="shipId" required class="form-input-field">
								<option value="">-- Select Ship --</option>
								<%
								List<Map<String, Object>> shipList = (List<Map<String, Object>>) request.getAttribute("ships");
								if (shipList != null) {
									for (Map<String, Object> ship : shipList) {
								%>
								<option value="<%=ship.get("ship_id")%>"><%=ship.get("ship_name")%></option>
								<%
								}
								}
								%>
							</select>
							<p class="text-xs text-slate-400 flex items-center gap-1">
								<i data-lucide="info" class="w-3 h-3 text-slate-500"></i> Only Anchored vessels.
							</p>
						</div>

						<div class="form-step-card">
							<div class="flex items-center gap-2 text-slate-700 font-semibold text-sm">
								<span class="w-5 h-5 rounded-full bg-port-sidebar text-white flex items-center justify-center text-xs">2</span>
								Select Available Dock
							</div>
							<select name="dockId" id="dockId" required class="form-input-field">
								<option value="">-- Select Dock --</option>
								<%
								List<Map<String, Object>> dockList = (List<Map<String, Object>>) request.getAttribute("docks");
								if (dockList != null) {
									for (Map<String, Object> dock : dockList) {
								%>
								<option value="<%=dock.get("dock_id")%>"><%=dock.get("dock_name")%></option>
								<%
								}
								}
								%>
							</select>
							<p class="text-xs text-slate-400 flex items-center gap-1">
								<i data-lucide="info" class="w-3 h-3 text-slate-500"></i> Only Available Docks.
							</p>
						</div>

						<div class="form-step-card md:col-span-2 lg:col-span-2">
							<div class="flex items-center gap-2 text-slate-700 font-semibold text-sm mb-2">
								<span class="w-5 h-5 rounded-full bg-port-sidebar text-white flex items-center justify-center text-xs">3</span>
								Allocation Time Window
							</div>
							<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 w-full">
								<div>
									<label for="allocationTime" class="block text-xs font-medium text-slate-500 mb-1">Allocation Start</label> 
                                    <input type="datetime-local" id="allocationTime" name="allocationTime" required class="form-input-field" />
								</div>
								<div>
									<label for="releaseTime" class="block text-xs font-medium text-slate-500 mb-1">Release Time</label> 
                                    <input type="datetime-local" id="releaseTime" name="releaseTime" required class="form-input-field" />
								</div>
							</div>
							<div class="mt-2 flex items-start gap-1.5 text-slate-300 bg-[#334155] border border-slate-400/30 rounded-md p-2 text-[11px] leading-relaxed">
								<i data-lucide="clock" class="w-3.5 h-3.5 mt-0.5 flex-shrink-0 text-[#FFEAD8]"></i> 
                                <span><strong class="text-[#FFEAD8]">Note:</strong> Allocations can only be requested up to 3 hours in advance of the allocation start time.</span>
							</div>
						</div>
					</div>
					<div class="pt-4 border-t border-slate-100 flex items-center justify-between flex-wrap gap-4 bg-slate-50/50 -mx-6 -mb-6 p-6">
						<div class="flex items-center gap-2 text-slate-500 text-sm">
							<i data-lucide="check-square" class="w-4 h-4 text-emerald-500"></i>
							<span>Verify details above before verifying confirmation.</span>
						</div>
						<button type="submit" class="bg-port-accent hover:bg-slate-600 text-white px-6 py-2.5 rounded-lg font-medium text-sm shadow-sm hover:shadow transition-all duration-200 flex items-center gap-2 transform hover:-translate-y-0.5">
							<i data-lucide="plus-circle" class="w-4 h-4 text-slate-300"></i> Confirm Allocation
						</button>
					</div>
				</form>
			</section>

			<%-- SCHEDULE & ALLOCATIONS TABBED REGISTRY SECTION --%>
			<section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden" aria-label="Schedule and Allocations">
				
				<div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
					<div>
						<span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Registry</span>
						<h3 class="text-lg font-bold text-slate-700">Schedule & Allocations</h3>
					</div>
					<form action="<%=request.getContextPath()%>/DockAllocation_Controller" method="get" class="flex items-center gap-2 w-full sm:w-auto">
						<input type="hidden" name="tab" value="<%=activeTab%>" />
						<div class="relative flex-1 sm:w-72">
							<i data-lucide="search" class="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none"></i>
							<input type="text" name="searchInput" id="searchInput"
								value="<%=request.getAttribute("searchInput") != null ? request.getAttribute("searchInput") : ""%>"
								placeholder="Search by allocation ID, ship, or dock..."
								class="w-full pl-9 pr-3 py-2 border border-slate-300 rounded-md text-xs bg-white focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition" />
						</div>
						<button type="submit" class="bg-port-accent hover:bg-slate-600 text-white px-3 py-2 text-xs rounded-lg font-semibold flex items-center gap-1 flex-shrink-0 transition">
							<i data-lucide="search" class="w-3 h-3"></i> Search
						</button>
						<a href="<%=request.getContextPath()%>/DockAllocation_Controller?tab=<%=activeTab%>" class="px-3 py-2 border border-slate-300 rounded-lg text-xs text-slate-600 hover:bg-slate-50 transition flex-shrink-0 flex items-center gap-1">
							<i data-lucide="x" class="w-3.5 h-3.5"></i> Reset
						</a>
					</form>
				</div>

				<%-- TABS NAVIGATION --%>
				<div class="flex items-center gap-6 px-6 border-b border-slate-200 bg-slate-50/30">
					<a href="?tab=active" class="py-3 text-sm font-medium transition-colors <%= "active".equals(activeTab) ? "border-b-2 border-slate-800 text-slate-900 font-bold" : "text-slate-500 hover:text-slate-700 border-b-2 border-transparent" %>">Active</a>
					<a href="?tab=history" class="py-3 text-sm font-medium transition-colors <%= "history".equals(activeTab) ? "border-b-2 border-slate-800 text-slate-900 font-bold" : "text-slate-500 hover:text-slate-700 border-b-2 border-transparent" %>">History</a>
				</div>

				<%
				String searchInputStr = (String) request.getAttribute("searchInput");
				List<Map<String, Object>> active = (List<Map<String, Object>>) request.getAttribute("activeAllocations");
				List<Map<String, Object>> history = (List<Map<String, Object>>) request.getAttribute("historyAllocations");
				
				if (searchInputStr != null && !searchInputStr.isEmpty()) {
					int resultSize = "active".equals(activeTab) ? (active != null ? active.size() : 0) : (history != null ? history.size() : 0);
				%>
				<div class="px-6 py-2.5 bg-blue-50 border-b border-blue-100 flex items-center gap-2 text-xs text-blue-700 font-semibold">
					<i data-lucide="filter" class="w-3.5 h-3.5"></i>
					Showing <%= resultSize %> result<%= resultSize != 1 ? "s" : "" %> for &ldquo;<%= searchInputStr %>&rdquo; in <%= activeTab %> allocations
				</div>
				<% } %>

				<div class="overflow-x-auto">
					<table class="w-full text-left border-collapse">
						<thead>
							<tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
								<th class="px-6 py-3.5">Allocation ID</th>
								<th class="px-6 py-3.5">Ship Name</th>
								<th class="px-6 py-3.5">Assigned Dock</th>
								<th class="px-6 py-3.5">Allocated From</th>
								<th class="px-6 py-3.5">Expected Release</th>
								<% if ("active".equals(activeTab)) { %>
									<th class="px-6 py-3.5">Update</th>
									<th class="px-6 py-3.5 text-right">Release</th>
								<% } %>
							</tr>
						</thead>
						<tbody class="divide-y divide-slate-100 text-sm text-slate-600">
							
							<%-- RENDER LOGIC SWITCH FOR TABS --%>
							<%
							if ("active".equals(activeTab)) {
								if (active != null && !active.isEmpty()) {
									for (Map<String, Object> row : active) {
										String allocId = String.valueOf(row.get("allocation_id"));
							%>
							<tr class="hover:bg-slate-50/50 transition duration-150">
								<td class="px-6 py-4 font-mono text-xs text-slate-400">#<%=allocId%></td>
								<td class="px-6 py-4 font-medium text-slate-900">
									<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-800 border border-slate-200">
										<span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span> <%=row.get("ship_name")%>
									</span>
								</td>
								<td class="px-6 py-4 font-mono text-xs"><%=row.get("dock_name")%></td>
								<td class="px-6 py-4 text-slate-500 text-xs"><%=row.get("allocation_time")%></td>
								<td class="px-6 py-4 text-slate-500 text-xs"><%=row.get("release_time")%></td>

								<td class="px-6 py-4">
									<button type="button" onclick="toggleUpdateForm('updateRow-<%=allocId%>')" class="inline-flex items-center gap-1 px-3 py-1.5 border border-slate-200 hover:border-slate-400 text-xs font-medium text-slate-700 bg-white hover:bg-slate-50 rounded-md transition duration-150">
										<i data-lucide="pencil" class="w-3.5 h-3.5 text-slate-400"></i> Edit
									</button>
								</td>

								<td class="px-6 py-4 text-right">
									<form action="<%=request.getContextPath()%>/DockAllocation_Controller" method="post" class="inline">
										<input type="hidden" name="tab" value="<%=activeTab%>" />
										<input type="hidden" name="action" value="release" /> 
                                        <input type="hidden" name="allocationId" value="<%=allocId%>" /> 
                                        <input type="hidden" name="hiddenShipName" value="<%=row.get("ship_name")%>" /> 
                                        <input type="hidden" name="hiddenDockName" value="<%=row.get("dock_name")%>" />
										<button type="submit" class="inline-flex items-center gap-1 px-3 py-1.5 border border-red-200 hover:border-red-300 text-xs font-medium text-red-600 bg-red-50/30 hover:bg-red-50 rounded-md transition duration-150">
											<i data-lucide="log-out" class="w-3.5 h-3.5"></i> Release
										</button>
									</form>
								</td>
							</tr>

							<tr id="updateRow-<%=allocId%>" class="hidden bg-slate-50/50 border-b border-slate-200">
								<td colspan="7" class="px-6 py-5">
									<form action="<%=request.getContextPath()%>/DockAllocation_Controller" method="post">
										<input type="hidden" name="tab" value="<%=activeTab%>" />
										<input type="hidden" name="action" value="update" /> 
                                        <input type="hidden" name="allocationId" value="<%=allocId%>" />
										<div class="flex flex-wrap gap-4 items-end">

											<div class="space-y-1">
												<label class="block text-xs font-medium text-slate-500">Reassign Dock</label> 
                                                <select name="newDockId" class="px-3 py-2 bg-white border border-slate-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-slate-500">
													<option value="">-- Keep Current --</option>
													<%
													List<Map<String, Object>> updateDockList = (List<Map<String, Object>>) request.getAttribute("docks");
													if (updateDockList != null) {
														for (Map<String, Object> ud : updateDockList) {
													%>
													<option value="<%=ud.get("dock_id")%>"><%=ud.get("dock_name")%></option>
													<%
													}
													}
													%>
												</select>
											</div>

											<div class="space-y-1">
												<label class="block text-xs font-medium text-slate-500">New Allocation Start</label> 
                                                <input type="datetime-local" name="newAllocationTime" class="px-3 py-2 bg-white border border-slate-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-slate-500" />
											</div>

											<div class="space-y-1">
												<label class="block text-xs font-medium text-slate-500">New Release Time</label> 
                                                <input type="datetime-local" name="newReleaseTime" class="px-3 py-2 bg-white border border-slate-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-slate-500" />
											</div>

											<div class="flex gap-2">
												<button type="submit" class="bg-port-sidebar hover:bg-slate-800 text-white px-4 py-2 rounded-lg text-xs font-medium flex items-center gap-1 transition">
													<i data-lucide="save" class="w-3.5 h-3.5 text-slate-400"></i> Save
												</button>
												<button type="button" onclick="toggleUpdateForm('updateRow-<%=allocId%>')" class="px-4 py-2 border border-slate-300 rounded-lg text-xs text-slate-600 hover:bg-slate-100 transition">Cancel</button>
											</div>
										</div>
									</form>
								</td>
							</tr>
							<%
									}
								} else {
							%>
							<tr>
								<td colspan="7" class="px-6 py-16 text-center text-slate-400">
									<div class="flex flex-col items-center justify-center space-y-3 max-w-sm mx-auto">
										<div class="w-14 h-14 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 border border-slate-100">
											<i data-lucide="container" class="w-7 h-7"></i>
										</div>
										<h4 class="font-bold text-slate-700 text-base">No active allocations found</h4>
										<p class="text-xs text-slate-400 leading-relaxed">
											<%= (searchInputStr != null && !searchInputStr.isEmpty())
												? "No allocations matched \"" + searchInputStr + "\"."
												: "No live physical dock occupancy fields are registered." %>
										</p>
									</div>
								</td>
							</tr>
							<%
								}
							} else if ("history".equals(activeTab)) {
								// HISTORY TAB RENDERING
								if (history != null && !history.isEmpty()) {
									for (Map<String, Object> row : history) {
										String allocId = String.valueOf(row.get("allocation_id"));
							%>
							<tr class="hover:bg-slate-50/50 transition duration-150">
								<td class="px-6 py-4 font-mono text-xs text-slate-400">#<%=allocId%></td>
								<td class="px-6 py-4 font-medium text-slate-900">
									<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-800 border border-slate-200">
										<span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span> <%=row.get("ship_name")%>
									</span>
								</td>
								<td class="px-6 py-4 font-mono text-xs"><%=row.get("dock_name")%></td>
								<td class="px-6 py-4 text-slate-500 text-xs"><%=row.get("allocation_time")%></td>
								<td class="px-6 py-4 text-slate-500 text-xs"><%=row.get("release_time")%></td>
							</tr>
							<%
									}
								} else {
							%>
							<tr>
								<td colspan="5" class="px-6 py-16 text-center text-slate-400">
									<div class="flex flex-col items-center justify-center space-y-3 max-w-sm mx-auto">
										<div class="w-14 h-14 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 border border-slate-100">
											<i data-lucide="archive" class="w-7 h-7"></i>
										</div>
										<h4 class="font-bold text-slate-700 text-base">No history records found</h4>
										<p class="text-xs text-slate-400 leading-relaxed">
											<%= (searchInputStr != null && !searchInputStr.isEmpty())
												? "No historical records matched \"" + searchInputStr + "\"."
												: "Your allocation history log is currently empty." %>
										</p>
									</div>
								</td>
							</tr>
							<%
								}
							}
							%>
						</tbody>
					</table>
				</div>
			</section>
		</main>
	</div>

	<%-- CONFIRM LOGOUT MODAL --%>
	<div id="logoutModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200">
		<div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200">
			<div class="flex items-center gap-3 text-red-600 mb-3">
				<div class="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
					<i data-lucide="log-out" class="w-5 h-5"></i>
				</div>
				<h3 class="text-lg font-bold text-slate-800">Confirm Logout</h3>
			</div>
			<p class="text-sm text-slate-600 mb-6">Are you sure you want to log out of the Port ERP Management system? Any unsaved changes will be lost.</p>
			<div class="flex gap-3 justify-end">
				<button onclick="closeLogoutModal()" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
					Cancel
				</button>
				<a id="confirmLogoutBtn" href="logout" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">
					Log Out
				</a>
			</div>
		</div>
	</div>

	<script>
		/* CONFIRM USER LOGOUT TRIGGER INTERCEPT */
		function confirmLogout(event) {
			event.preventDefault();
			const modal = document.getElementById('logoutModal');
			modal.classList.remove('hidden');
			lucide.createIcons();
			return false;
		}

		function closeLogoutModal() {
			const modal = document.getElementById('logoutModal');
			modal.classList.add('hidden');
		}

		window.onclick = function(event) {
			const modal = document.getElementById('logoutModal');
			if (event.target === modal) {
				closeLogoutModal();
			}
		}

		function toggleUpdateForm(rowId) {
			const row = document.getElementById(rowId);
			row.classList.toggle('hidden');
			lucide.createIcons();
		}

		function handleSidebarClick(event) {
			const sidebar = document.getElementById('sidebar');
			if (sidebar.classList.contains('sidebar-collapsed')) {
				sidebar.classList.remove('sidebar-collapsed', 'w-20');
				sidebar.classList.add('w-64');
				document.getElementById('collapseIcon').setAttribute('data-lucide', 'chevron-left');
				lucide.createIcons();
			}
		}

		function toggleSidebar(event) {
			if (event) event.stopPropagation();

			const sidebar = document.getElementById('sidebar');
			const icon = document.getElementById('collapseIcon');

			sidebar.classList.toggle('sidebar-collapsed');
			if (sidebar.classList.contains('sidebar-collapsed')) {
				sidebar.classList.remove('w-64');
				sidebar.classList.add('w-20');
				icon.setAttribute('data-lucide', 'chevron-right');
			} else {
				sidebar.classList.remove('w-20');
				sidebar.classList.add('w-64');
				icon.setAttribute('data-lucide', 'chevron-left');
			}
			lucide.createIcons();
		}

		function toggleMobileSidebar() {
			const sidebar = document.getElementById('sidebar');
			const overlay = document.getElementById('sidebarOverlay');
			if (sidebar.classList.contains('hidden')) {
				sidebar.classList.remove('hidden', 'w-20');
				sidebar.classList.add('fixed', 'inset-y-0', 'left-0', 'w-64', 'z-40');
				overlay.classList.remove('hidden');
			} else {
				sidebar.classList.add('hidden');
				sidebar.classList.remove('fixed', 'inset-y-0', 'left-0', 'w-64', 'z-40');
				overlay.classList.add('hidden');
			}
		}

		lucide.createIcons();
	</script>
</body>
</html>