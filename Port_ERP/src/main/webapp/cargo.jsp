<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Cargo" %>
<% 
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "";

    List<Cargo> listCargo = (List<Cargo>) request.getAttribute("listCargo"); 
    List<String[]> emptyContainersList = (List<String[]>) request.getAttribute("emptyContainersList");
    
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String containerFilter = (String) request.getAttribute("containerFilter");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String msg = request.getParameter("msg");
    
    boolean isFiltered = (searchKeyword != null && !searchKeyword.isEmpty()) || 
                         (containerFilter != null && !containerFilter.isEmpty()) || 
                         (statusFilter != null && !statusFilter.isEmpty() && !"All".equalsIgnoreCase(statusFilter));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cargo Management | Port ERP</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .bg-port-sidebar { background-color: #20242D; }
        .bg-port-active  { background-color: #FFEAD8; }
        .text-port-active { color: #FFEAD8; }
        .bg-port-accent  { background-color: #334155; }

        .nav-link {
            display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem; border-radius: 0.5rem;
            transition-property: all; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;
            font-size: 0.875rem; justify-content: flex-start;
        }
        .nav-link-inactive { color: #E2E8F0; }
        .nav-link-inactive:hover { background-color: rgba(255, 255, 255, 0.06); color: #FFFFFF; }
        .nav-icon-inactive { color: #94A3B8; width: 1rem; height: 1rem; flex-shrink: 0; }
        .nav-link-inactive:hover .nav-icon-inactive { color: #FFEAD8; }

        #sidebar { transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .sidebar-text { transition: opacity 0.2s ease, max-width 0.2s ease; max-width: 200px; opacity: 1; }
        .sidebar-collapsed .sidebar-text { max-width: 0; opacity: 0; overflow: hidden; display: none; }
        .sidebar-collapsed .header-wrapper { justify-content: center; padding-left: 0; padding-right: 0; }
        .sidebar-collapsed { cursor: ew-resize; }
        .sidebar-collapsed * { cursor: ew-resize !important; }
        .sidebar-collapsed .toggle-btn-sidebar { opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; }
        .toggle-btn-sidebar { transition: opacity 0.2s ease, visibility 0.2s ease; opacity: 1; visibility: visible; }
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
                <a href="Dock.jsp" class="nav-link nav-link-inactive" title="Dock Management">
                    <i data-lucide="layers" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Dock Management</span>
                </a>
                <a href="dockAllocation.jsp" class="nav-link nav-link-inactive" title="Dock Allocation">
                    <i data-lucide="git-pull-request" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Dock Allocation</span>
                </a>
                <a href="ContainerController" class="nav-link nav-link-inactive" title="Container Management">
                    <i data-lucide="box" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Container Management</span>
                </a>
                <% } %>
                
                <a href="CargoController?action=list" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="Cargo Management">
                    <i data-lucide="package" class="w-4 h-4 text-slate-900 flex-shrink-0"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Management</span>
                </a>
                
                <a href="CargoController?action=all_history" class="nav-link nav-link-inactive" title="Cargo Logs">
                    <i data-lucide="clipboard-list" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Logs</span>
                </a>
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
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
            <span class="sidebar-text whitespace-nowrap">Role: <strong class="text-slate-300"><%= !userRole.equals("") ? userRole : "Cargo Handler" %></strong></span>
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
                    <i data-lucide="package" class="w-5 h-5 text-slate-600"></i> Cargo Handling System
                </h1>
            </div>
            
            <div class="flex items-center gap-6 ml-auto">
                <div class="flex items-center gap-2 text-sm text-slate-600">
                    <i data-lucide="user-circle" class="w-5 h-5 text-slate-500"></i> 
                    <span>Welcome, <strong class="text-slate-800"><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong></span>
                </div>
                <a href="logout" onclick="return confirmLogout(event);" class="bg-port-accent hover:bg-slate-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors">
                    Logout 
                </a>
            </div>
        </header>

        <main class="p-6 max-w-7xl w-full mx-auto space-y-6 flex-1">
            <div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-[#FFEAD8] flex justify-between items-center flex-wrap gap-4">
                <div>
                    <h2 class="text-2xl font-bold tracking-tight">Cargo Inventory</h2>
                    <p class="text-slate-300 text-sm mt-1">Manage cargo items, container assignments, and real-time status.</p>
                </div>
                <button onclick="openCargoModal()" class="bg-white text-slate-800 px-4 py-2 rounded-lg text-sm font-semibold hover:bg-slate-100 transition shadow-sm flex items-center gap-2">
                    <i data-lucide="plus" class="w-4 h-4"></i> Add Cargo
                </button>
            </div>

            <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-4">
                <form action="CargoController" method="get" class="flex flex-col md:flex-row gap-4 items-end md:items-center w-full">
                    <input type="hidden" name="action" value="list" />
                    
                    <div class="relative flex-1 w-full">
                        <label class="block text-xs font-semibold text-slate-500 mb-1 uppercase tracking-wider">Search</label>
                        <i data-lucide="search" class="w-4 h-4 absolute left-3 top-8 text-slate-400"></i>
                        <input type="text" name="keyword" value="<%= searchKeyword != null ? searchKeyword : "" %>" placeholder="ID, Description, Ship..." class="w-full pl-9 pr-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-slate-500 outline-none transition" />
                    </div>

                    <div class="w-full md:w-48">
                        <label class="block text-xs font-semibold text-slate-500 mb-1 uppercase tracking-wider">Container ID</label>
                        <div class="relative">
                            <i data-lucide="box" class="w-4 h-4 absolute left-3 top-2.5 text-slate-400"></i>
                            <input type="text" name="containerFilter" value="<%= containerFilter != null ? containerFilter : "" %>" placeholder="e.g. 101" class="w-full pl-9 pr-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-slate-500 outline-none transition" />
                        </div>
                    </div>

                    <div class="w-full md:w-48">
                        <label class="block text-xs font-semibold text-slate-500 mb-1 uppercase tracking-wider">Status</label>
                        <select name="statusFilter" class="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-slate-500 outline-none transition appearance-none bg-white">
                            <option value="All" <%= "All".equalsIgnoreCase(statusFilter) || statusFilter == null || statusFilter.trim().isEmpty() ? "selected" : "" %>>All Statuses</option>
                            <option value="Loaded" <%= "Loaded".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Loaded</option>
                            <option value="Unloaded" <%= "Unloaded".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Unloaded</option>
                            <option value="In Transit" <%= "In Transit".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>In Transit</option>
                        </select>
                    </div>

                    <div class="flex items-center gap-2 w-full md:w-auto mt-4 md:mt-0">
                        <button type="submit" class="flex-1 md:flex-none px-4 py-2 bg-port-accent text-white text-sm font-semibold rounded-lg hover:bg-slate-800 transition flex items-center justify-center gap-2">
                            <i data-lucide="filter" class="w-4 h-4"></i> Filter
                        </button>
                        <% if (isFiltered) { %>
                            <a href="CargoController?action=list" class="px-4 py-2 bg-slate-100 text-slate-600 hover:text-red-600 hover:bg-red-50 text-sm font-semibold rounded-lg transition flex items-center justify-center" title="Clear Filters">
                                <i data-lucide="x" class="w-4 h-4"></i>
                            </a>
                        <% } %>
                    </div>
                </form>
            </div>

            <section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left text-slate-600">
                        <thead class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
                            <tr>
                                <th class="px-6 py-3.5">ID</th>
                                <th class="px-6 py-3.5">Description</th>
                                <th class="px-6 py-3.5">Weight (kg)</th>
                                <th class="px-6 py-3.5">Status</th>
                                <th class="px-6 py-3.5">Container</th>
                                <th class="px-6 py-3.5 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <% if (listCargo != null && !listCargo.isEmpty()) { 
                                for (Cargo c : listCargo) { %>
                                <tr class="hover:bg-slate-50/50 transition duration-150">
                                    <td class="px-6 py-4 font-mono text-xs font-semibold text-slate-900">#<%= c.getCargoId() %></td>
                                    <td class="px-6 py-4 font-medium text-slate-800"><%= c.getDescription() %></td>
                                    <td class="px-6 py-4"><%= c.getWeight() %></td>
                                    <td class="px-6 py-4">
                                        <% if ("Loaded".equals(c.getStatus())) { %>
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border bg-emerald-50 text-emerald-700 border-emerald-200"><span class="w-1.5 h-1.5 rounded-full bg-current"></span>Loaded</span>
                                        <% } else if ("Unloaded".equals(c.getStatus())) { %>
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border bg-amber-50 text-amber-700 border-amber-200"><span class="w-1.5 h-1.5 rounded-full bg-current"></span>Unloaded</span>
                                        <% } else { %>
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border bg-blue-50 text-blue-700 border-blue-200"><span class="w-1.5 h-1.5 rounded-full bg-current"></span>In Transit</span>
                                        <% } %>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="font-medium text-slate-700">Cont-<%= c.getContainerId() %></div>
                                        <div class="text-xs text-slate-500"><%= c.getContainerType() %> | <%= c.getShipName() %></div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center justify-center gap-2">
                                            <button onclick="openCargoModal('<%= c.getCargoId() %>', '<%= c.getContainerId() %>', '<%= c.getDescription() != null ? c.getDescription().replace("'", "\\'").replace("\"", "&quot;") : "" %>', '<%= c.getWeight() %>', '<%= c.getStatus() %>')" class="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded transition border border-transparent hover:border-blue-200" title="Edit"><i data-lucide="edit" class="w-4 h-4"></i></button>
                                            <a href="CargoController?action=history&id=<%= c.getCargoId() %>" class="p-1.5 text-slate-400 hover:text-teal-600 hover:bg-teal-50 rounded transition border border-transparent hover:border-teal-200" title="Audit Log"><i data-lucide="history" class="w-4 h-4"></i></a>
                                            <button type="button" onclick="openDeleteModal('<%= c.getCargoId() %>')" class="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded transition border border-transparent hover:border-red-200" title="Delete"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                        </div>
                                    </td>
                                </tr>
                            <%  } } else { %>
                                <tr>
                                    <td colspan="6" class="px-6 py-12 text-center text-slate-400">
                                        <div class="flex flex-col items-center justify-center space-y-2">
                                            <div class="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center border border-slate-200">
                                                <i data-lucide="search-x" class="w-6 h-6 text-slate-400"></i>
                                            </div>
                                            <p class="font-semibold text-slate-700 mt-2">No cargo found matching criteria.</p>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>

        <% if (msg != null && !msg.isEmpty()) { 
            String alertColor = "bg-emerald-50 border-emerald-200 text-emerald-800";
            String icon = "check-circle";
            String alertText = "Action completed successfully.";
            
            if ("added".equals(msg)) {
                alertText = "Cargo successfully added to inventory.";
            } else if ("updated".equals(msg)) {
                alertText = "Cargo details successfully updated.";
            } else if ("deleted".equals(msg)) {
                alertText = "Cargo successfully removed.";
                alertColor = "bg-red-50 border-red-200 text-red-800";
                icon = "trash-2";
            } else if ("invalid_container".equals(msg)) {
                String badId = request.getParameter("badId");
                alertText = "There is no container named or IDed as " + (badId != null ? badId : "5") + ".";
                alertColor = "bg-red-50 border-red-200 text-red-800";
                icon = "alert-triangle";
            } else if ("failed".equals(msg)) {
                alertText = "An error occurred while handling cargo operations.";
                alertColor = "bg-red-50 border-red-200 text-red-800";
                icon = "x-circle";
            }
        %>
        <div id="toastNotification" class="fixed top-20 right-6 z-50 flex items-center p-4 mb-4 text-sm rounded-lg border shadow-lg transition-opacity duration-500 <%= alertColor %>" role="alert">
            <i data-lucide="<%= icon %>" class="w-5 h-5 mr-3"></i>
            <span class="font-medium"><%= alertText %></span>
            <button type="button" onclick="document.getElementById('toastNotification').style.display='none'" class="ml-4 -mx-1.5 -my-1.5 p-1.5 inline-flex h-8 w-8 rounded-lg hover:bg-black/5 focus:ring-2 focus:ring-black/10 transition">
                <span class="sr-only">Close</span>
                <i data-lucide="x" class="w-4 h-4"></i>
            </button>
        </div>
        <% } %>
    </div>

    <%-- ADD / EDIT MODAL --%>
    <div id="cargoModal" class="fixed inset-0 z-50 hidden bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4 transition-opacity opacity-0 duration-300">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-lg overflow-hidden transform scale-95 transition-transform duration-300" id="cargoModalContent">
            <div class="px-6 py-4 border-b border-slate-200 flex justify-between items-center bg-slate-50">
                <h3 id="modalTitle" class="text-lg font-bold text-slate-800">Add New Cargo</h3>
                <button onclick="closeCargoModal()" class="text-slate-400 hover:text-slate-700 transition p-1 rounded-md hover:bg-slate-200">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            
            <form action="CargoController" method="post" class="p-6 space-y-4">
                <input type="hidden" name="action" id="formAction" value="insert">
                <input type="hidden" name="cargoId" id="modalCargoId" value="">
                
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Container ID <span class="text-red-500">*</span></label>
                    <select name="containerId" id="modalContainerId" required class="w-full px-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-port-accent focus:border-transparent outline-none transition appearance-none bg-white">
                        <option value="" disabled selected hidden>Select an empty container...</option>
                        <% 
                            if (emptyContainersList != null) {
                                for (String[] container : emptyContainersList) {
                        %>
                            <option value="<%= container[0] %>">Cont-<%= container[0] %> (<%= container[1] %>)</option>
                        <% 
                                }
                            } 
                        %>
                    </select>
                </div>
                
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Description <span class="text-red-500">*</span></label>
                    <input type="text" name="description" id="modalDescription" required class="w-full px-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-port-accent focus:border-transparent outline-none transition" placeholder="Cargo description...">
                </div>
                
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Weight (kg) <span class="text-red-500">*</span></label>
                        <input type="number" step="0.01" name="weight" id="modalWeight" required class="w-full px-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-port-accent focus:border-transparent outline-none transition" placeholder="0.00">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Status <span class="text-red-500">*</span></label>
                        <select name="status" id="modalStatus" required class="w-full px-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-port-accent focus:border-transparent outline-none transition">
                            <option value="Loaded">Loaded</option>
                            <option value="Unloaded">Unloaded</option>
                            <option value="In Transit">In Transit</option>
                        </select>
                    </div>
                </div>
                
                <div class="pt-4 flex justify-end gap-3 border-t border-slate-100">
                    <button type="button" onclick="closeCargoModal()" class="px-4 py-2 text-sm font-medium text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-lg transition">Cancel</button>
                    <button type="submit" id="modalSubmitBtn" class="px-4 py-2 text-sm font-semibold text-white bg-port-accent hover:bg-slate-800 rounded-lg shadow-sm transition">Save Cargo</button>
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
            <p class="text-sm text-slate-600 mb-6">Are you sure you want to delete cargo entry <strong id="deleteCargoIdDisplay"></strong>? material files will be unlinked from current container allocations instantly.</p>
            <div class="flex gap-3 justify-end">
                <button type="button" onclick="closeDeleteModal()" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                    Cancel
                </button>
                <a id="confirmDeleteBtn" href="#" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">
                    Delete Cargo
                </a>
            </div>
        </div>
    </div>

    <%-- CONFIRM LOGOUT MODAL --%>
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

        function closeLogoutModalOnBackdrop(event) {
            if (event.target === document.getElementById('logoutModal')) {
                closeLogoutModal();
            }
        }

        function openDeleteModal(cargoId) {
            document.getElementById('deleteCargoIdDisplay').innerText = "#" + cargoId;
            document.getElementById('confirmDeleteBtn').href = "CargoController?action=delete&id=" + cargoId;
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

        function openCargoModal(id = null, containerId = '', description = '', weight = '', status = 'Loaded') {
            const modal = document.getElementById('cargoModal');
            const content = document.getElementById('cargoModalContent');
            const title = document.getElementById('modalTitle');
            const formAction = document.getElementById('formAction');
            const submitBtn = document.getElementById('modalSubmitBtn');
            const containerDropdown = document.getElementById('modalContainerId');
            
            document.getElementById('modalCargoId').value = id || '';
            document.getElementById('modalDescription').value = description;
            document.getElementById('modalWeight').value = weight;
            document.getElementById('modalStatus').value = status;
            
            if (containerId) {
                let optionExists = Array.from(containerDropdown.options).some(option => option.value == containerId);
                
                if (!optionExists) {
                    let newOpt = document.createElement('option');
                    newOpt.value = containerId;
                    newOpt.text = "Cont-" + containerId + " (Current Assigned)";
                    containerDropdown.add(newOpt);
                }
                containerDropdown.value = containerId;
            } else {
                containerDropdown.selectedIndex = 0; 
            }
            
            if (id) {
                title.innerText = 'Edit Cargo #' + id;
                formAction.value = 'update';
                submitBtn.innerText = 'Update Cargo';
            } else {
                title.innerText = 'Add New Cargo';
                formAction.value = 'insert';
                submitBtn.innerText = 'Save Cargo';
            }
            
            modal.classList.remove('hidden');
            setTimeout(() => {
                modal.classList.remove('opacity-0');
                content.classList.remove('scale-95');
                content.classList.add('scale-100');
            }, 10);
        }

        function closeCargoModal() {
            const modal = document.getElementById('cargoModal');
            const content = document.getElementById('cargoModalContent');
            
            modal.classList.add('opacity-0');
            content.classList.remove('scale-100');
            content.classList.add('scale-95');
            
            setTimeout(() => {
                modal.classList.add('hidden');
            }, 300);
        }

        document.addEventListener("DOMContentLoaded", function() {
            const toast = document.getElementById('toastNotification');
            if (toast) {
                setTimeout(() => {
                    toast.classList.add('opacity-0');
                    setTimeout(() => toast.style.display = 'none', 500);
                }, 4000);
            }
        });

        document.addEventListener('keydown', e => { 
            if (e.key === 'Escape') {
                closeCargoModal();
                closeLogoutModal();
                closeDeleteModal();
            }
        });

        lucide.createIcons();
    </script>
</body>
</html>