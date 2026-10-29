<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Dashboard" %>

<%
    Dashboard dashboard = (Dashboard) request.getAttribute("dashboard");
    String username = (String) request.getAttribute("username");
    String role = (String) request.getAttribute("role");

    if (dashboard == null) {
        dashboard = new model.Dashboard();
    }
    if (username == null) {
        username = "Guest";
    }
    if (role == null) {
        role = "Administrator"; 
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Port ERP Dashboard</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        .bg-port-sidebar { background-color: #20242D; } 
        .bg-port-active  { background-color: #FFEAD8; } 
        .text-port-active { color: #FFEAD8; }
        .bg-port-accent  { background-color: #334155; } 

        .nav-link {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem;
            border-radius: 0.5rem;
            transition-property: all;
            transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            transition-duration: 150ms;
            font-size: 0.875rem;
            justify-content: flex-start;
        }
        .nav-link-inactive { color: #E2E8F0; }
        .nav-link-inactive:hover {
            background-color: rgba(255, 255, 255, 0.06);
            color: #FFFFFF;
        }
        .nav-icon-inactive {
            color: #94A3B8;
            width: 1rem;
            height: 1rem;
            flex-shrink: 0;
        }
        .nav-link-inactive:hover .nav-icon-inactive { color: #FFEAD8; }

        #sidebar { transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .sidebar-text {
            transition: opacity 0.2s ease, max-width 0.2s ease;
            max-width: 200px;
            opacity: 1;
        }
        
        .sidebar-collapsed .sidebar-text {
            max-width: 0;
            opacity: 0;
            overflow: hidden;
            display: none;
        }
        .sidebar-collapsed .header-wrapper {
            justify-content: center;
            padding-left: 0;
            padding-right: 0;
        }
        .sidebar-collapsed { cursor: ew-resize; }
        .sidebar-collapsed * { cursor: ew-resize !important; }
        .sidebar-collapsed .toggle-btn-sidebar {
            opacity: 0 !important;
            visibility: hidden !important;
            pointer-events: none !important;
        }
        .toggle-btn-sidebar {
            transition: opacity 0.2s ease, visibility 0.2s ease;
            opacity: 1;
            visibility: visible;
        }
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
</head>

<body class="bg-slate-50 text-slate-800 font-sans flex h-screen overflow-hidden">

<aside id="sidebar" onclick="handleSidebarClick(event)" class="w-64 bg-port-sidebar text-white flex flex-col justify-between hidden md:flex h-screen sticky top-0 flex-shrink-0 transition-all duration-300 shadow-xl z-20">
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
            <button id="toggleBtn" onclick="toggleSidebar(event)" class="toggle-btn-sidebar text-slate-400 hover:text-white p-1 rounded hover:bg-white/5 transition hidden md:block flex-shrink-0">
                <i id="collapseIcon" data-lucide="chevron-left" class="w-4 h-4"></i>
            </button>
        </div>

        <nav class="p-4 space-y-1.5 flex-1">
            <a href="dashboard" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="Dashboard">
                <i data-lucide="layout-dashboard" class="w-4 h-4 text-slate-900 flex-shrink-0"></i>
                <span class="sidebar-text whitespace-nowrap">Dashboard</span>
            </a>

            <% if ("Administrator".equals(role)) { %>
            <a href="UserController" class="nav-link nav-link-inactive" title="User Management">
                <i data-lucide="users" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">User Management</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role) || "Ship Operator".equals(role)) { %>
            <a href="shipManagement.jsp" class="nav-link nav-link-inactive" title="Ship Management">
                <i data-lucide="ship" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Ship Management</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role) || "Dock Manager".equals(role)) { %>
            <a href="Dock.jsp" class="nav-link nav-link-inactive" title="Dock Management">
                <i data-lucide="layers" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Dock Management</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role) || "Dock Manager".equals(role)) { %>
            <a href="dockAllocation.jsp" class="nav-link nav-link-inactive" title="Dock Allocation">
                <i data-lucide="git-pull-request" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Dock Allocation</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role) || "Ship Operator".equals(role)) { %>
            <a href="containermanagement.jsp" class="nav-link nav-link-inactive" title="Container Management">
                <i data-lucide="box" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Container Management</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role) || "Cargo Handler".equals(role)) { %>
            <a href="CargoController?action=list" class="nav-link nav-link-inactive" title="Cargo Management">
                <i data-lucide="package" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Cargo Management</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role) || "Cargo Handler".equals(role)) { %>
            <a href="CargoController?action=all_history" class="nav-link nav-link-inactive" title="Cargo Logs">
                <i data-lucide="clipboard-list" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Cargo Logs</span>
            </a>
            <% } %>

            <% if ("Administrator".equals(role) || "Port Manager".equals(role)) { %>
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
        <span class="sidebar-text whitespace-nowrap">Role: <strong class="text-slate-300"><%= role %></strong></span>
    </div>
</aside>

<div id="sidebarOverlay" onclick="toggleMobileSidebar()" class="fixed inset-0 bg-black/40 z-30 hidden md:hidden transition-opacity"></div>

<div class="flex-1 flex flex-col min-w-0 h-screen overflow-y-auto">
    <header class="h-16 bg-white border-b border-slate-200 flex items-center px-6 sticky top-0 z-10 shadow-sm flex-shrink-0">
        <div class="flex items-center gap-4">
            <button onclick="toggleMobileSidebar()" class="md:hidden text-slate-600 hover:text-slate-900 p-1 rounded hover:bg-slate-100">
                <i data-lucide="menu" class="w-5 h-5"></i>
            </button>
            <h1 class="text-lg font-bold text-slate-700 tracking-tight whitespace-nowrap flex items-center gap-2">
                <i data-lucide="layout-dashboard" class="w-5 h-5 text-slate-600"></i> Port ERP Dashboard
            </h1>
        </div>
        <div class="flex items-center gap-6 ml-auto">
            <div class="flex items-center gap-2 text-sm text-slate-600">
                <i data-lucide="user-circle" class="w-5 h-5 text-slate-500"></i>
                <span>Welcome, <strong class="text-slate-800"><%= username %></strong></span>
            </div>
            <a href="logout" onclick="return confirmLogout(event);" class="bg-port-accent hover:bg-slate-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors">Logout</a>
        </div>
    </header>

    <main class="p-6 max-w-7xl w-full mx-auto space-y-6 flex-1">

    <% if("Administrator".equals(role) || "Port Manager".equals(role)) { %>
        <div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8]">
            <h2 class="text-2xl font-bold tracking-tight">Admin / Port Manager Dashboard</h2>
            <p class="text-slate-300 text-sm mt-1">Summary of ships, docks, containers, cargo and users.</p>
        </div>

        <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-5">
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <i data-lucide="ship" class="w-6 h-6 text-slate-700 mb-4"></i>
                <p class="text-sm text-slate-500 font-semibold">Total Ships</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getTotalShips() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <i data-lucide="activity" class="w-6 h-6 text-green-600 mb-4"></i>
                <p class="text-sm text-slate-500 font-semibold">Active Docks</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getActiveDocks() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <i data-lucide="box" class="w-6 h-6 text-slate-700 mb-4"></i>
                <p class="text-sm text-slate-500 font-semibold">Containers</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getTotalContainers() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <i data-lucide="package" class="w-6 h-6 text-slate-700 mb-4"></i>
                <p class="text-sm text-slate-500 font-semibold">Pending Cargo</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getPendingCargoCount() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <i data-lucide="users" class="w-6 h-6 text-slate-700 mb-4"></i>
                <p class="text-sm text-slate-500 font-semibold">Users</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getTotalUsers() %></h3>
            </div>
        </section>

        <section class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm lg:col-span-2">
                <div class="p-5 border-b border-slate-100">
                    <h3 class="text-lg font-bold flex items-center gap-2">
                        <i data-lucide="rss" class="w-4 h-4 text-slate-500"></i> Recent Activity Feed
                    </h3>
                </div>
                <div class="divide-y divide-slate-100 text-sm text-slate-600">
                    <%
                        List<Map<String, Object>> activities = (List<Map<String, Object>>) request.getAttribute("recentActivities");
                        if (activities != null && !activities.isEmpty()) {
                            for (Map<String, Object> activity : activities) {
                    %>
                        <div class="p-5 hover:bg-slate-50/50 transition flex justify-between items-center gap-4">
                            <div class="flex items-center gap-3">
                                <div class="w-2 h-2 rounded-full bg-blue-500"></div>
                                <span class="text-slate-700 font-medium"><%= activity.get("activity_details") %></span>
                            </div>
                            <span class="text-xs font-mono text-slate-400 whitespace-nowrap">
                                <%= activity.get("activity_date") %>
                            </span>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <div class="p-8 text-center text-slate-400 flex flex-col items-center justify-center gap-2">
                            <i data-lucide="info" class="w-5 h-5 text-slate-300"></i>
                            <span>No dynamic historical events found.</span>
                        </div>
                    <%  } %>
                </div>
            </div>

            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <h3 class="text-lg font-bold mb-4">Quick Actions</h3>
                <div class="space-y-3">
                    <a href="shipManagement.jsp" class="block p-4 rounded-lg bg-slate-50 hover:bg-[#FFEAD8] text-sm font-medium transition">Add Ship</a>
                    <a href="dockAllocation.jsp" class="block p-4 rounded-lg bg-slate-50 hover:bg-[#FFEAD8] text-sm font-medium transition">Allocate Dock</a>
                    <a href="CargoController?action=list" class="block p-4 rounded-lg bg-slate-50 hover:bg-[#FFEAD8] text-sm font-medium transition">Manage Cargo</a>
                </div>
            </div>
        </section>
    <% } else if("Ship Operator".equals(role)) { %>
        <div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8]">
            <h2 class="text-2xl font-bold tracking-tight">Ship Operator Dashboard</h2>
            <p class="text-slate-300 text-sm mt-1">Assigned ships and upcoming departures.</p>
        </div>

        <section class="grid grid-cols-1 md:grid-cols-3 gap-5">
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <p class="text-sm text-slate-500 font-semibold">Anchored Ships</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getAnchoredShips() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <p class="text-sm text-slate-500 font-semibold">Docked Ships</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getDockedShips() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <p class="text-sm text-slate-500 font-semibold">Departed Ships</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getDepartedShips() %></h3>
            </div>
        </section>

        <section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
            <div class="p-5 border-b border-slate-100"><h3 class="text-lg font-bold">My Ships Panel</h3></div>
            <div class="overflow-x-auto">
                <table class="w-full text-sm text-left border-collapse">
                    <thead class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
                        <tr>
                            <th class="px-5 py-3">Ship</th>
                            <th class="px-5 py-3">Arrival</th>
                            <th class="px-5 py-3">Departure</th>
                            <th class="px-5 py-3">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm text-slate-600">
                    <%
                        List<Map<String, Object>> myShips = (List<Map<String, Object>>) request.getAttribute("myShips");
                        if(myShips != null && !myShips.isEmpty()) {
                            for(Map<String, Object> ship : myShips) {
                    %>
                        <tr class="hover:bg-slate-50/50 transition">
                            <td class="px-5 py-4 font-medium text-slate-900"><%= ship.get("ship_name") %></td>
                            <td class="px-5 py-4"><%= ship.get("arrival_date") %></td>
                            <td class="px-5 py-4"><%= ship.get("departure_date") %></td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-1 rounded-full text-xs font-medium border bg-slate-50 text-slate-700 border-slate-200"><%= ship.get("status") %></span>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="4" class="px-5 py-8 text-center text-slate-400">No vessels currently assigned to operations.</td>
                        </tr>
                    <%  } %>
                    </tbody>
                </table>
            </div>
        </section>
    <% } else if("Dock Manager".equals(role)) { %>
        <div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8]">
            <h2 class="text-2xl font-bold tracking-tight">Dock Manager Dashboard</h2>
            <p class="text-slate-300 text-sm mt-1">Dock occupancy status board and berth grid.</p>
        </div>

        <section class="grid grid-cols-1 md:grid-cols-3 gap-5">
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <p class="text-sm text-slate-500 font-semibold">Available Docks</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getAvailableDocks() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <p class="text-sm text-slate-500 font-semibold">Occupied Docks</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getActiveDocks() %></h3>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
                <p class="text-sm text-slate-500 font-semibold">Maintenance Docks</p>
                <h3 class="text-4xl font-extrabold"><%= dashboard.getMaintenanceDocks() %></h3>
            </div>
        </section>

        <section class="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
            <h3 class="text-lg font-bold mb-5">Visual Berth Grid</h3>
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-5">
            <%
                List<Map<String, Object>> dockBoard = (List<Map<String, Object>>) request.getAttribute("dockBoard");
                if(dockBoard != null) {
                    for(Map<String, Object> dock : dockBoard) {
                        String status = String.valueOf(dock.get("status"));
                        String color = "bg-slate-50 border-slate-200 text-slate-700";

                        if("Available".equals(status)) {
                            color = "bg-green-50 border-green-200 text-green-700";
                        } else if("Occupied".equals(status)) {
                            color = "bg-red-50 border-red-200 text-red-700";
                        } else if("Under Maintenance".equals(status)) {
                            color = "bg-yellow-50 border-yellow-200 text-yellow-700";
                        }
            %>
                <div class="rounded-xl p-5 border text-center transition duration-150 shadow-sm hover:shadow <%= color %>">
                    <h4 class="font-bold text-sm"><%= dock.get("dock_name") %></h4>
                    <p class="text-xs mt-2 font-medium uppercase tracking-wider"><%= status %></p>
                </div>
            <%
                    }
                }
            %>
            </div>
        </section>
    <% } else if("Cargo Handler".equals(role)) { %> 
        <div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8]"> 
            <h2 class="text-2xl font-bold tracking-tight">Cargo Handler Dashboard</h2> 
            <p class="text-slate-300 text-sm mt-1">Pending cargo movements and recently handled cargo.</p> 
        </div> 
        <section class="grid grid-cols-1 md:grid-cols-3 gap-5"> 
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5"> 
                <p class="text-sm text-slate-500 font-semibold">Pending Cargo</p> 
                <h3 class="text-4xl font-extrabold"><%= dashboard.getPendingCargoCount() %></h3> 
            </div> 
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5"> 
                <p class="text-sm text-slate-500 font-semibold">Loaded Cargo</p> 
                <h3 class="text-4xl font-extrabold"><%= dashboard.getLoadedCargo() %></h3> 
            </div> 
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5"> 
                <p class="text-sm text-slate-500 font-semibold">Unloaded Cargo</p> 
                <h3 class="text-4xl font-extrabold"><%= dashboard.getUnloadedCargo() %></h3> 
            </div> 
        </section> 
        <section class="grid grid-cols-1 lg:grid-cols-2 gap-6"> 
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"> 
                <div class="p-5 border-b border-slate-100"><h3 class="text-lg font-bold">Pending Cargo Movements</h3></div> 
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left border-collapse"> 
                        <thead class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider"> 
                            <tr> 
                                <th class="px-5 py-3">Cargo</th> 
                                <th class="px-5 py-3">Container</th> 
                                <th class="px-5 py-3">Status</th> 
                            </tr> 
                        </thead> 
                        <tbody class="divide-y divide-slate-100 text-sm text-slate-600"> 
                        <% 
                            List<Map<String, Object>> pendingCargo = (List<Map<String, Object>>) request.getAttribute("pendingCargo"); 
                            if(pendingCargo != null && !pendingCargo.isEmpty()) { 
                                for(Map<String, Object> cargo : pendingCargo) { 
                        %> 
                            <tr class="hover:bg-slate-50/50 transition"> 
                                <td class="px-5 py-4 font-medium text-slate-800"><%= cargo.get("description") %></td> 
                                <td class="px-5 py-4 font-mono text-xs">Cont-<%= cargo.get("container_id") %></td> 
                                <td class="px-5 py-4">
                                    <span class="px-2.5 py-1 rounded-full text-xs font-medium border bg-amber-50 text-amber-700 border-amber-200"><%= cargo.get("status") %></span>
                                </td> 
                            </tr> 
                        <% 
                                } 
                            } else {
                        %> 
                            <tr>
                                <td colspan="3" class="px-5 py-8 text-center text-slate-400">No pending freight configurations remaining.</td>
                            </tr>
                        <%  } %> 
                        </tbody> 
                    </table> 
                </div>
            </div> 
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden"> 
                <div class="p-5 border-b border-slate-100"><h3 class="text-lg font-bold">Recently Handled Cargo</h3></div> 
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left border-collapse"> 
                        <thead class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider"> 
                            <tr> 
                                <th class="px-5 py-3">Cargo ID</th> 
                                <th class="px-5 py-3">Movement</th> 
                                <th class="px-5 py-3">Date</th> 
                            </tr> 
                        </thead> 
                        <tbody class="divide-y divide-slate-100 text-sm text-slate-600"> 
                        <% 
                            List<Map<String, Object>> recentCargo = (List<Map<String, Object>>) request.getAttribute("recentCargo"); 
                            if(recentCargo != null && !recentCargo.isEmpty()) { 
                                for(Map<String, Object> cargo : recentCargo) { 
                        %> 
                            <tr class="hover:bg-slate-50/50 transition"> 
                                <td class="px-5 py-4 font-mono text-xs text-slate-900">#<%= cargo.get("cargo_id") %></td> 
                                <td class="px-5 py-4 font-medium"><%= cargo.get("movement_type") %></td> 
                                <td class="px-5 py-4 text-xs font-mono text-slate-500"><%= cargo.get("movement_date") %></td> 
                            </tr> 
                        <% 
                                } 
                            } else {
                        %>
                            <tr>
                                <td colspan="3" class="px-5 py-8 text-center text-slate-400">No historical entry metrics populated.</td>
                            </tr>
                        <%  } %> 
                        </tbody> 
                    </table> 
                </div>
            </div> 
        </section> 
    <% } %>
    </main>
</div>

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

    lucide.createIcons();
</script>
</body>
</html>