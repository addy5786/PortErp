<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Container" %>
<%
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "";

    if (request.getAttribute("containers") == null) {
        response.sendRedirect(request.getContextPath() + "/ContainerController");
        return;
    }
    List<Container> containers = (List<Container>) request.getAttribute("containers");
    List<Container> details    = (List<Container>) request.getAttribute("details");
    List<String[]> dockedShipsList = (List<String[]>) request.getAttribute("dockedShipsList");
    
    Integer selectedId         = (Integer)         request.getAttribute("selectedContainerId");
    String  searchInput        = (String)           request.getAttribute("searchInput");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Container Management | Port ERP</title>
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://unpkg.com/lucide@latest"></script>
<style>
.bg-port-sidebar { background-color: #20242D; }
.bg-port-active  { background-color: #FFEAD8; }
.text-port-active { color: #FFEAD8; }
.bg-port-accent  { background-color: #334155; }

.nav-link {
    display: flex; align-items: center; gap: 0.75rem;
    padding: 0.75rem; border-radius: 0.5rem;
    transition: all 150ms cubic-bezier(0.4,0,0.2,1);
    font-size: 0.875rem; justify-content: flex-start;
}
.nav-link-inactive { color: #E2E8F0; }
.nav-link-inactive:hover { background-color: rgba(255,255,255,0.06); color: #fff; }
.nav-icon-inactive { color: #94A3B8; width: 1rem; height: 1rem; flex-shrink: 0; }
.nav-link-inactive:hover .nav-icon-inactive { color: #FFEAD8; }

.form-step-card {
    padding: 1.25rem; border: 1px solid #E2E8F0;
    border-radius: 0.5rem; background-color: #F8FAFC;
    display: flex; flex-direction: column; gap: 0.75rem;
}
.form-input-field {
    width: 100%; padding: 0.625rem 0.75rem;
    background-color: #fff; border: 1px solid #CBD5E1;
    border-radius: 0.375rem; font-size: 0.875rem; transition: all 0.2s;
}
.form-input-field:focus { outline: none; box-shadow: 0 0 0 2px #475569; border-color: #475569; }

#sidebar { transition: width 0.3s cubic-bezier(0.4,0,0.2,1); }
.sidebar-text { transition: opacity 0.2s ease, max-width 0.2s ease; max-width: 200px; opacity: 1; }
.sidebar-collapsed .sidebar-text { max-width: 0; opacity: 0; overflow: hidden; display: none; }
.sidebar-collapsed .header-wrapper { justify-content: center; padding-left: 0; padding-right: 0; }
.sidebar-collapsed { cursor: ew-resize; }
.sidebar-collapsed * { cursor: ew-resize !important; }
.sidebar-collapsed .toggle-btn-sidebar { opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; }
.toggle-btn-sidebar { transition: opacity 0.2s ease, visibility 0.2s ease; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

.modal-backdrop {
    display: none; position: fixed; inset: 0;
    background: rgba(15,20,35,0.4); backdrop-filter: blur(2px);
    z-index: 50; align-items: center; justify-content: center;
}
.modal-backdrop.active { display: flex; }

.detail-panel { display: none; }
.detail-panel.active { display: table-row !important; }
.detail-panel > td { padding: 0 !important; border: none !important; }

@keyframes instantHide {
    0%   { opacity: 1; visibility: visible; transform: scale(1); }
    85%  { opacity: 1; visibility: visible; transform: scale(1); }
    100% { opacity: 0; visibility: hidden; transform: scale(0.95); height: 0; padding: 0; margin: 0; border: none; }
}
.clear-message-instantly { animation: instantHide 5s steps(1,end) forwards; }
</style>
</head>
<body class="bg-slate-50 text-slate-800 font-sans flex h-screen overflow-hidden">

<aside id="sidebar" onclick="handleSidebarClick(event)"
    class="w-64 bg-port-sidebar text-white flex flex-col justify-between hidden md:flex h-screen sticky top-0 flex-shrink-0 shadow-xl z-20">
    <div class="flex flex-col overflow-y-auto flex-1 no-scrollbar relative">
        <div class="header-wrapper p-5 flex items-center justify-between border-b border-slate-700/60 sticky top-0 bg-port-sidebar z-10">
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
            
            <a href="ShipManagement_Controller" class="nav-link nav-link-inactive" title="Ship Management">
                <i data-lucide="ship" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Ship Management</span>
            </a>
            
            <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
            <a href="Dock.jsp" class="nav-link nav-link-inactive" title="Dock Management">
                <i data-lucide="layers" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Dock Management</span>
            </a>
            <a href="dockAllocation.jsp" class="nav-link nav-link-inactive" title="Dock Allocation">
                <i data-lucide="git-pull-request" class="nav-icon-inactive"></i>
                <span class="sidebar-text whitespace-nowrap">Dock Allocation</span>
            </a>
            <% } %>
            
            <a href="ContainerController" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="Container Management">
                <i data-lucide="box" class="w-4 h-4 text-slate-900 flex-shrink-0"></i>
                <span class="sidebar-text whitespace-nowrap">Container Management</span>
            </a>
            
            <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
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
        <span class="sidebar-text whitespace-nowrap">Role: <strong class="text-slate-300"><%= !userRole.equals("") ? userRole : "Ship Operator" %></strong></span>
    </div>
</aside>

<div id="sidebarOverlay" onclick="toggleMobileSidebar()"
    class="fixed inset-0 bg-black/40 z-30 hidden md:hidden transition-opacity"></div>

<div class="flex-1 flex flex-col min-w-0 h-screen overflow-y-auto">

    <header class="h-16 bg-white border-b border-slate-200 flex items-center px-6 sticky top-0 z-10 shadow-sm flex-shrink-0 relative">
        <div class="flex items-center gap-4">
            <button onclick="toggleMobileSidebar()" class="md:hidden text-slate-600 hover:text-slate-900 p-1 rounded hover:bg-slate-100">
                <i data-lucide="menu" class="w-5 h-5"></i>
            </button>
            <h1 class="text-lg font-bold text-slate-700 tracking-tight whitespace-nowrap flex items-center gap-2">
                <i data-lucide="box" class="w-5 h-5 text-slate-600"></i> Port ERP | Box Logistics
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
                boolean isError = msg.toUpperCase().contains("FAIL")
                               || msg.toUpperCase().contains("ERROR")
                               || msg.toUpperCase().contains("INVALID")
                               || msg.toUpperCase().contains("NOT FOUND")
                               || msg.toUpperCase().contains("CANNOT")
                               || msg.toUpperCase().contains("DOES NOT")
                               || msg.toUpperCase().contains("EXIST");
                String bannerClass = isError
                    ? "bg-red-50 border-2 border-red-300 text-red-900 border-l-8"
                    : "bg-emerald-50 border-2 border-emerald-300 text-emerald-900 border-l-8";
                String iconName = isError ? "alert-circle" : "check-circle";
        %>
        <div class="absolute inset-x-0 top-16 flex items-center justify-center pointer-events-none z-50 pt-3">
            <div class="<%= bannerClass %> pointer-events-auto rounded-xl px-6 py-3.5 flex items-center gap-3.5 text-base font-bold shadow-xl max-w-md w-full clear-message-instantly mx-4">
                <i data-lucide="<%= iconName %>" class="w-6 h-6 flex-shrink-0"></i>
                <span class="leading-snug"><%= msg %></span>
            </div>
        </div>
        <% } %>
    </header>

    <main class="p-6 max-w-7xl w-full mx-auto space-y-6 flex-1">

        <div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8]">
            <h2 class="text-2xl font-bold tracking-tight">Container Registry</h2>
            <p class="text-slate-300 text-sm mt-1">Register, monitor and manage all containers assigned to vessels in the port.</p>
        </div>

        <%-- REGISTER FORM --%>
        <section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden" aria-label="Register New Container">
            <div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4 flex items-center justify-between">
                <div>
                    <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Operational Tool</span>
                    <h3 class="text-lg font-bold text-slate-700">Register New Container</h3>
                </div>
                <button type="button" onclick="toggleForm('registerForm','registerIcon')"
                    class="text-slate-400 hover:text-slate-700 p-2 rounded-lg hover:bg-slate-100 transition">
                    <i id="registerIcon" data-lucide="chevron-up" class="w-5 h-5"></i>
                </button>
            </div>
            <div id="registerForm">
                <form action="<%= request.getContextPath() %>/ContainerController" method="post" class="p-6 space-y-6">
                    <input type="hidden" name="action" value="add"/>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="form-step-card">
                            <label class="block text-xs font-semibold uppercase tracking-wide text-slate-500">
                                Container Type <span class="text-red-500">*</span>
                            </label>
                            <select name="container_type" required class="form-input-field">
                                <option value="">-- Select Type --</option>
                                <option value="Dry">Dry</option>
                                <option value="Reefer">Reefer</option>
                                <option value="Open Top">Open Top</option>
                                <option value="Tank">Tank</option>
                            </select>
                        </div>
                        <div class="form-step-card">
                            <label class="block text-xs font-semibold uppercase tracking-wide text-slate-500">
                                Status <span class="text-red-500">*</span>
                            </label>
                            <select name="status" required class="form-input-field">
                                <option value="">-- Select Status --</option>
                                <option value="Loaded">Loaded</option>
                                <option value="Empty">Empty</option>
                                <option value="In Transit">In Transit</option>
                            </select>
                        </div>
                        <div class="form-step-card">
                            <label class="block text-xs font-semibold uppercase tracking-wide text-slate-500">
                                Ship ID <span class="text-red-500">*</span>
                            </label>
                            <select name="ship_id" required class="form-input-field appearance-none bg-white">
                                <option value="" disabled selected hidden>-- Select Docked Ship --</option>
                                <% 
                                    if (dockedShipsList != null && !dockedShipsList.isEmpty()) {
                                        for (String[] ship : dockedShipsList) {
                                %>
                                    <option value="<%= ship[0] %>">#<%= ship[0] %> - <%= ship[1] %></option>
                                <% 
                                        }
                                    } else {
                                %>
                                    <option value="" disabled>No docked vessels available</option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <div class="pt-4 border-t border-slate-100 flex items-center justify-between flex-wrap gap-4 bg-slate-50/50 -mx-6 -mb-6 p-6">
                        <span class="text-xs text-slate-500 flex items-center gap-1">
                            <i data-lucide="info" class="w-4 h-4 text-slate-400"></i>
                            All fields marked <span class="text-red-500 mx-1">*</span> are required.
                        </span>
                        <button type="submit"
                            class="bg-port-accent hover:bg-slate-600 text-white px-6 py-2.5 rounded-lg font-medium text-sm shadow-sm hover:shadow transition-all duration-200 flex items-center gap-2 transform hover:-translate-y-0.5">
                            <i data-lucide="plus-circle" class="w-4 h-4 text-slate-300"></i> Add Container
                        </button>
                    </div>
                </form>
            </div>
        </section>

        <%-- ALL CONTAINERS TABLE --%>
        <section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden" aria-label="All Containers">
            <div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Registry</span>
                    <h3 class="text-lg font-bold text-slate-700">All Containers</h3>
                </div>
                <form action="<%= request.getContextPath() %>/ContainerController" method="get"
                    class="flex items-center gap-2 w-full sm:w-auto">
                    <input type="hidden" name="action" value="search"/>
                    <div class="relative flex-1 sm:w-72">
                        <i data-lucide="search" class="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none"></i>
                        <input type="text" name="searchInput"
                            value="<%= searchInput != null ? searchInput : "" %>"
                            placeholder="Search by type, status, or ship name..."
                            class="w-full pl-9 pr-3 py-2 border border-slate-300 rounded-md text-xs bg-white focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition"/>
                    </div>
                    <button type="submit"
                        class="bg-port-accent hover:bg-slate-600 text-white px-3 py-2 text-xs rounded-lg font-semibold flex items-center gap-1 flex-shrink-0 transition">
                        <i data-lucide="search" class="w-3 h-3"></i> Search
                    </button>
                    <a href="<%= request.getContextPath() %>/ContainerController"
                        class="px-3 py-2 border border-slate-300 rounded-lg text-xs text-slate-600 hover:bg-slate-50 transition flex-shrink-0 flex items-center gap-1">
                        <i data-lucide="x" class="w-3.5 h-3.5"></i> Reset
                    </a>
                </form>
            </div>

            <% if (searchInput != null && !searchInput.isEmpty()) { %>
            <div class="px-6 py-2.5 bg-blue-50 border-b border-blue-100 flex items-center gap-2 text-xs text-blue-700 font-semibold">
                <i data-lucide="filter" class="w-3.5 h-3.5"></i>
                Showing <%= containers.size() %> result<%= containers.size() != 1 ? "s" : "" %> for
                &ldquo;<%= searchInput %>&rdquo;
                &nbsp;&mdash;&nbsp;
                <a href="<%= request.getContextPath() %>/ContainerController" class="underline hover:text-blue-900 transition">Clear search</a>
            </div>
            <% } %>

            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
                            <th class="px-6 py-3.5">Container ID</th>
                            <th class="px-6 py-3.5">Type</th>
                            <th class="px-6 py-3.5">Status</th>
                            <th class="px-6 py-3.5">Ship ID</th>
                            <th class="px-6 py-3.5">Ship Name</th>
                            <th class="px-6 py-3.5 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm text-slate-600">
                    <%
                        if (containers != null && !containers.isEmpty()) {
                            for (Container c : containers) {
                                String cStatus = c.getStatus() != null ? c.getStatus() : "";
                                String badgeClass, dotClass;
                                if ("Loaded".equals(cStatus)) {
                                    badgeClass = "bg-blue-50 text-blue-700 border-blue-200";
                                    dotClass   = "bg-blue-500";
                                } else if ("In Transit".equals(cStatus)) {
                                    badgeClass = "bg-amber-50 text-amber-700 border-amber-200";
                                    dotClass   = "bg-amber-500";
                                } else {
                                    badgeClass = "bg-slate-100 text-slate-600 border-slate-200";
                                    dotClass   = "bg-slate-400";
                                }
                                boolean isSelected = (selectedId != null && selectedId.equals(c.getContainer_id()));
                    %>
                        <tr class="hover:bg-slate-50/50 transition duration-150">
                            <td class="px-6 py-4 font-mono text-xs text-slate-400">#<%= c.getContainer_id() %></td>
                            <td class="px-6 py-4 font-semibold text-slate-900"><%= c.getContainer_type() %></td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border <%= badgeClass %>">
                                    <span class="w-1.5 h-1.5 rounded-full inline-block <%= dotClass %>"></span>
                                    <%= cStatus %>
                                </span>
                            </td>
                            <td class="px-6 py-4 font-mono text-xs text-slate-500">
                                <%= c.getShip_id() != 0 ? "#" + c.getShip_id() : "—" %>
                            </td>
                            <td class="px-6 py-4 text-slate-700 font-medium">
                                <%= c.getShip_name() != null ? c.getShip_name() : "—" %>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center justify-end gap-2">
                                    <button type="button"
                                        onclick="openEditModal('<%= c.getContainer_id() %>','<%= c.getContainer_type() %>','<%= cStatus %>','<%= c.getShip_id() %>','<%= c.getShip_name() != null ? c.getShip_name().replace("'", "\\'") : "" %>')"
                                        class="inline-flex items-center gap-1 px-3 py-1.5 border border-slate-200 hover:border-slate-400 text-xs font-medium text-slate-700 bg-white hover:bg-slate-50 rounded-md transition duration-150">
                                        <i data-lucide="pencil" class="w-3.5 h-3.5 text-slate-400"></i> Edit
                                    </button>
                                    <button type="button"
                                        id="btn-detail-<%= c.getContainer_id() %>"
                                        onclick="handleViewDetails('<%= c.getContainer_id() %>', <%= isSelected %>)"
                                        class="inline-flex items-center gap-1 px-3 py-1.5 border border-slate-200 hover:border-slate-400 text-xs font-medium text-slate-700 bg-white hover:bg-slate-50 rounded-md transition duration-150">
                                        <i data-lucide="<%= isSelected ? "eye-off" : "eye" %>" class="w-3.5 h-3.5 text-slate-400"></i>
                                        <%= isSelected ? "Hide Details" : "View Details" %>
                                    </button>
                                    <button type="button"
                                        onclick="openDeleteModal('<%= c.getContainer_id() %>')"
                                        class="inline-flex items-center gap-1 px-3 py-1.5 border border-red-200 hover:border-red-300 text-xs font-medium text-red-600 bg-red-50/30 hover:bg-red-50 rounded-md transition duration-150">
                                        <i data-lucide="trash-2" class="w-3.5 h-3.5"></i> Delete
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr id="detail-<%= c.getContainer_id() %>" class="detail-panel">
                            <td colspan="6">
                                <div style="border-top: 3px solid #20242D;">
                                    <div class="bg-port-sidebar px-6 py-4 flex items-center gap-3 border-b border-slate-700">
                                        <div class="w-9 h-9 bg-slate-700 rounded-lg flex items-center justify-center flex-shrink-0">
                                            <i data-lucide="box" class="w-4 h-4 text-slate-300"></i>
                                        </div>
                                        <div>
                                            <div class="font-bold text-sm text-slate-100"><%= c.getContainer_type() %> Container</div>
                                            <div class="text-xs text-slate-400 mt-0.5">Cargo Contents</div>
                                        </div>
                                        <div class="ml-auto flex items-center gap-2">
                                            <span class="bg-slate-700 border border-slate-600 text-slate-300 text-xs px-3 py-1 rounded-full font-mono font-semibold">
                                                Container #<%= c.getContainer_id() %>
                                            </span>
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border <%= badgeClass %>">
                                                <span class="w-1.5 h-1.5 rounded-full inline-block <%= dotClass %>"></span>
                                                <%= cStatus %>
                                            </span>
                                        </div>
                                    </div>

                                    <div class="bg-white p-6">
                                    <% if (isSelected && details != null) {
                                           boolean hasCargo = !details.isEmpty() && details.get(0).getCargo_id() != 0;
                                           if (hasCargo) { %>
                                        <div class="border border-slate-200 rounded-lg overflow-hidden">
                                            <table class="w-full text-left border-collapse text-xs">
                                                <thead>
                                                    <tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
                                                        <th class="px-5 py-3">Cargo ID</th>
                                                        <th class="px-5 py-3">Description</th>
                                                        <th class="px-5 py-3">Weight (kg)</th>
                                                        <th class="px-5 py-3">Status</th>
                                                    </tr>
                                                </thead>
                                                <tbody class="divide-y divide-slate-100">
                                                <% for (Container d : details) {
                                                       String cgs = d.getCargoStatus() != null ? d.getCargoStatus() : "";
                                                       String cgBadge;
                                                       if ("Loaded".equals(cgs))        cgBadge = "bg-blue-50 text-blue-700 border-blue-200";
                                                       else if ("Unloaded".equals(cgs)) cgBadge = "bg-slate-100 text-slate-600 border-slate-200";
                                                       else                             cgBadge = "bg-amber-50 text-amber-700 border-amber-200";
                                                %>
                                                    <tr class="hover:bg-slate-50/50 transition">
                                                        <td class="px-5 py-3 font-mono text-slate-400">#<%= d.getCargo_id() %></td>
                                                        <td class="px-5 py-3 text-slate-700"><%= d.getDescription() != null ? d.getDescription() : "—" %></td>
                                                        <td class="px-5 py-3 text-slate-700"><%= d.getWeight() %></td>
                                                        <td class="px-5 py-3">
                                                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold border <%= cgBadge %>">
                                                                <%= cgs %>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                <% } %>
                                                </tbody>
                                            </table>
                                        </div>
                                    <% } else { %>
                                        <div class="flex flex-col items-center justify-center py-8 border-2 border-dashed border-slate-200 rounded-lg bg-slate-50/50 text-center">
                                            <div class="w-11 h-11 bg-slate-100 rounded-full flex items-center justify-center mb-3">
                                                <i data-lucide="package-open" class="w-5 h-5 text-slate-400"></i>
                                            </div>
                                            <div class="text-sm font-semibold text-slate-600">No Cargo in This Container</div>
                                            <div class="text-xs text-slate-400 mt-1">This container has no cargo items registered.</div>
                                        </div>
                                    <% } %>
                                    <% } else { %>
                                        <div class="flex items-center justify-center py-6 border-2 border-dashed border-slate-200 rounded-lg bg-slate-50/50">
                                            <span class="text-xs text-slate-400">Click <strong>View Details</strong> to load the cargo contents of this container.</span>
                                        </div>
                                    <% } %>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    <%
                            } 
                        } else {
                    %>
                        <tr>
                            <td colspan="6" class="px-6 py-16 text-center text-slate-400">
                                <div class="flex flex-col items-center justify-center space-y-3 max-w-sm mx-auto">
                                    <div class="w-14 h-14 rounded-full bg-slate-50 flex items-center justify-center border border-slate-100">
                                        <i data-lucide="box" class="w-7 h-7"></i>
                                    </div>
                                    <h4 class="font-bold text-slate-700 text-base">No Containers Found</h4>
                                    <p class="text-xs text-slate-400 leading-relaxed">
                                        <%= (searchInput != null && !searchInput.isEmpty())
                                            ? "No containers matched &quot;" + searchInput + "&quot;. Try a different search."
                                            : "Register a new container using the form above." %>
                                    </p>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

<%-- EDIT MODAL --%>
<div id="editModal" class="modal-backdrop" onclick="closeEditModalOnBackdrop(event)">
    <div class="bg-white rounded-xl shadow-2xl border border-slate-200 max-w-md w-full mx-4 overflow-hidden"
        onclick="event.stopPropagation()">
        <div class="bg-port-sidebar px-6 py-4 text-white flex items-center justify-between border-b border-slate-700">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-slate-700 rounded-lg flex items-center justify-center">
                    <i data-lucide="pencil" class="w-4 h-4 text-slate-300"></i>
                </div>
                <div>
                    <h3 class="font-bold text-base text-slate-100">Edit Container</h3>
                    <p class="text-xs text-slate-400 mt-0.5">Update the container record below.</p>
                </div>
            </div>
            <button onclick="closeEditModal()"
                class="text-slate-400 hover:text-white p-1 rounded hover:bg-white/10 transition">
                <i data-lucide="x" class="w-5 h-5"></i>
            </button>
        </div>
        <form action="<%= request.getContextPath() %>/ContainerController" method="post" class="p-6 space-y-4">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="container_id" id="editContainerId"/>

            <div class="bg-slate-50 border border-slate-200 rounded-lg px-4 py-2.5 text-xs text-slate-500 font-mono">
                Editing Container ID: <strong id="editContainerIdDisplay" class="text-slate-800"></strong>
            </div>

            <div class="grid grid-cols-1 gap-4">
                <div class="form-step-card">
                    <label class="block text-xs font-semibold uppercase tracking-wide text-slate-500">
                        Container Type <span class="text-red-500">*</span>
                    </label>
                    <select id="editContainerType" name="container_type" required class="form-input-field">
                        <option value="Dry">Dry</option>
                        <option value="Reefer">Reefer</option>
                        <option value="Open Top">Open Top</option>
                        <option value="Tank">Tank</option>
                    </select>
                </div>
                <div class="form-step-card">
                    <label class="block text-xs font-semibold uppercase tracking-wide text-slate-500">
                        Status <span class="text-red-500">*</span>
                    </label>
                    <select id="editStatus" name="status" required class="form-input-field">
                        <option value="Loaded">Loaded</option>
                        <option value="Empty">Empty</option>
                        <option value="In Transit">In Transit</option>
                    </select>
                </div>
                <div class="form-step-card">
                    <label class="block text-xs font-semibold uppercase tracking-wide text-slate-500">
                        Ship ID <span class="text-red-500">*</span>
                    </label>
                    <select id="editShipId" name="ship_id" required class="form-input-field appearance-none bg-white">
                        <% 
                            if (dockedShipsList != null) {
                                for (String[] ship : dockedShipsList) {
                        %>
                            <option value="<%= ship[0] %>">#<%= ship[0] %> - <%= ship[1] %></option>
                        <% 
                                }
                            } 
                        %>
                    </select>
                </div>
            </div>

            <div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-3 bg-slate-50/50 -mx-6 -mb-6 p-4">
                <button type="button" onclick="closeEditModal()"
                    class="px-4 py-2 border border-slate-200 text-slate-600 hover:bg-slate-100 transition rounded-lg text-xs font-semibold">
                    Cancel
                </button>
                <button type="submit"
                    class="bg-port-accent hover:bg-slate-600 text-white px-5 py-2 rounded-lg text-xs font-semibold shadow-sm transition flex items-center gap-2">
                    <i data-lucide="save" class="w-3.5 h-3.5 text-slate-300"></i> Save Changes
                </button>
            </div>
        </form>
    </div>
</div>

<%-- DELETE CONFIRMATION MODAL --%>
<div id="deleteModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200" onclick="closeDeleteModalOnBackdrop(event)">
    <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200" onclick="event.stopPropagation()">
        <div class="flex items-center gap-3 text-red-600 mb-3">
            <div class="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                <i data-lucide="trash-2" class="w-5 h-5"></i>
            </div>
            <h3 class="text-lg font-bold text-slate-800">Confirm Deletion</h3>
        </div>
        <p class="text-sm text-slate-600 mb-6">Are you sure you want to delete container freight unit <strong id="deleteContainerIdDisplay"></strong>? This operation cannot be reversed and will sever matching manifest data logs.</p>
        <div class="flex gap-3 justify-end">
            <button type="button" onclick="closeDeleteModal()" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                Cancel
            </button>
            <a id="confirmDeleteBtn" href="#" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">
                Delete Container
            </a>
        </div>
    </div>
</div>

<%-- LOGOUT CONFIRMATION MODAL --%>
<div id="logoutModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200" onclick="closeLogoutModalOnBackdrop(event)">
    <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200" onclick="event.stopPropagation()">
        <div class="flex items-center gap-3 text-red-600 mb-3">
            <div class="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                <i data-lucide="log-out" class="w-5 h-5"></i>
            </div>
            <h3 class="text-lg font-bold text-slate-800">Confirm Logout</h3>
        </div>
        <p class="text-sm text-slate-600 mb-6">Are you sure you want to log out of the Port ERP Management system? Any unsaved changes will be lost.</p>
        <div class="flex gap-3 justify-end">
            <button type="button" onclick="closeLogoutModal()" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                Cancel
            </button>
            <a id="confirmLogoutBtn" href="logout" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">
                Log Out
            </a>
        </div>
    </div>
</div>

<script>
    function confirmLogout(event) {
        event.preventDefault();
        const modal = document.getElementById('logoutModal');
        modal.classList.remove('hidden');
        lucide.createIcons();
        return false;
    }
    function closeLogoutModal() {
        document.getElementById('logoutModal').classList.add('hidden');
    }
    function closeLogoutModalOnBackdrop(event) {
        if (event.target === document.getElementById('logoutModal')) {
            closeLogoutModal();
        }
    }

    function openDeleteModal(containerId) {
        document.getElementById('deleteContainerIdDisplay').innerText = "#" + containerId;
        document.getElementById('confirmDeleteBtn').href = "<%= request.getContextPath() %>/ContainerController?action=delete&container_id=" + containerId;
        const modal = document.getElementById('deleteModal');
        modal.classList.remove('hidden');
        lucide.createIcons();
    }
    function closeDeleteModal() {
        document.getElementById('deleteModal').classList.add('hidden');
    }
    function closeDeleteModalOnBackdrop(event) {
        if (event.target === document.getElementById('deleteModal')) {
            closeDeleteModal();
        }
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
        const hidden  = sidebar.classList.contains('hidden');
        sidebar.classList.toggle('hidden', !hidden);
        sidebar.classList.toggle('fixed',     hidden);
        sidebar.classList.toggle('inset-y-0', hidden);
        sidebar.classList.toggle('left-0',    hidden);
        sidebar.classList.toggle('w-64',      hidden);
        sidebar.classList.toggle('z-40',      hidden);
        overlay.classList.toggle('hidden', !hidden);
    }

    function toggleForm(formId, iconId) {
        const form   = document.getElementById(formId);
        const icon   = document.getElementById(iconId);
        const hidden = form.style.display === 'none';
        form.style.display = hidden ? 'block' : 'none';
        icon.setAttribute('data-lucide', hidden ? 'chevron-up' : 'chevron-down');
        lucide.createIcons();
    }

    function handleViewDetails(containerId, isLoaded) {
        if (isLoaded) {
            const panel = document.getElementById('detail-' + containerId);
            const btn   = document.getElementById('btn-detail-' + containerId);
            const isActive = panel.classList.contains('active');

            document.querySelectorAll('.detail-panel.active').forEach(p => p.classList.remove('active'));
            document.querySelectorAll('[id^="btn-detail-"]').forEach(b => {
                b.innerHTML = '<i data-lucide="eye" class="w-3.5 h-3.5 text-slate-400"></i> View Details';
            });

            if (!isActive) {
                panel.classList.add('active');
                btn.innerHTML = '<i data-lucide="eye-off" class="w-3.5 h-3.5 text-slate-400"></i> Hide Details';
            }
            lucide.createIcons();
        } else {
            window.location.href = '<%= request.getContextPath() %>/ContainerController?action=details&container_id=' + containerId;
        }
    }

    window.addEventListener('DOMContentLoaded', function () {
        <% if (selectedId != null) { %>
        var panel = document.getElementById('detail-<%= selectedId %>');
        if (panel) {
            panel.classList.add('active');
            panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
        <% } %>
        lucide.createIcons();
    });

    function openEditModal(containerId, containerType, status, shipId, shipName) {
        const shipDropdown = document.getElementById('editShipId');
        document.getElementById('editContainerId').value              = containerId;
        document.getElementById('editContainerIdDisplay').textContent = '#' + containerId;
        document.getElementById('editContainerType').value            = containerType;
        document.getElementById('editStatus').value                   = status;
        
        if (shipId && shipId != "0") {
            let optionExists = Array.from(shipDropdown.options).some(opt => opt.value == shipId);
            if (!optionExists) {
                let newOpt = document.createElement('option');
                newOpt.value = shipId;
                newOpt.text = "#" + shipId + " - " + (shipName || "Current Vessel");
                shipDropdown.add(newOpt);
            }
            shipDropdown.value = shipId;
        } else {
            shipDropdown.selectedIndex = 0;
        }
        
        document.getElementById('editModal').classList.add('active');
    }
    
    function closeEditModal() {
        document.getElementById('editModal').classList.remove('active');
    }
    function closeEditModalOnBackdrop(e) {
        if (e.target === document.getElementById('editModal')) closeEditModal();
    }
    
    document.addEventListener('keydown', e => { 
        if (e.key === 'Escape') {
            closeEditModal();
            closeLogoutModal();
            closeDeleteModal();
        }
    });

    lucide.createIcons();
</script>
</body>
</html>