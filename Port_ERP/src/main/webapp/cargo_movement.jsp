<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.CargoMovement" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.TimeZone" %>
<% 
    // Secure against running the file template isolated without an authorized user session
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Safely extract user role to avoid NullPointerExceptions
    String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "";

    List<CargoMovement> movementHistory = (List<CargoMovement>) request.getAttribute("movementHistory"); 
    Integer cargoId = (Integer) request.getAttribute("cargoId");
    
    SimpleDateFormat istFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    istFormat.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movement History | Port Management System</title>
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

    <%-- SIDEBAR NAVIGATION WITH CONDITIONALLY FILTERED NAV-LINKS --%>
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
                
                <a href="CargoController?action=list" class="nav-link <%= cargoId != null ? "bg-port-active text-slate-900 font-semibold shadow-md" : "nav-link-inactive" %>" title="Cargo Management">
                    <i data-lucide="package" class="<%= cargoId != null ? "w-4 h-4 text-slate-900 flex-shrink-0" : "nav-icon-inactive" %>"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Management</span>
                </a>
                
                <a href="CargoController?action=all_history" class="nav-link <%= cargoId == null ? "bg-port-active text-slate-900 font-semibold shadow-md" : "nav-link-inactive" %>" title="Cargo Logs">
                    <i data-lucide="clipboard-list" class="<%= cargoId == null ? "w-4 h-4 text-slate-900 flex-shrink-0" : "nav-icon-inactive" %>"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Logs</span>
                </a>
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
                <a href="securitylog.jsp" class="nav-link nav-link-inactive" title="Security Log">
                    <i data-lucide="shield-alert" class="w-4 h-4"></i>
                    <span class="sidebar-text">Security Log</span>
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
                    <i data-lucide="history" class="w-5 h-5 text-slate-600"></i> Port ERP | Audit Logs
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
                    <h2 class="text-2xl font-bold tracking-tight">Movement Audit Trail</h2>
                    <p class="text-slate-300 text-sm mt-1">
                        <%= cargoId != null ? "Immutable ledger for Cargo #" + cargoId : "Global ledger for all Cargo movements" %>
                    </p>
                </div>
                <a href="CargoController?action=list" class="flex items-center gap-2 px-4 py-2 bg-slate-700 hover:bg-slate-600 border border-slate-500 rounded-lg text-sm font-semibold text-white transition shadow-sm">
                    <i data-lucide="arrow-left" class="w-4 h-4"></i> Back to Inventory
                </a>
            </div>

            <div class="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
                <form action="CargoController" method="GET" class="flex flex-col md:flex-row gap-4 items-end md:items-center w-full">
                    <input type="hidden" name="action" value="all_history">
                    
                    <div class="relative flex-1 w-full">
                        <i data-lucide="search" class="w-4 h-4 absolute left-3 top-3 text-slate-400"></i>
                        <input type="text" name="logKeyword" placeholder="Search Cargo ID or User ID..." value="${logKeyword}" class="w-full pl-9 pr-4 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-slate-500 outline-none transition">
                    </div>
                    
                    <div class="w-full md:w-48">
                        <select name="logTypeFilter" class="w-full px-3 py-2 text-sm border border-slate-300 rounded-lg focus:ring-2 focus:ring-slate-500 outline-none transition appearance-none bg-white">
                            <option value="All" ${logTypeFilter == 'All' || empty logTypeFilter ? 'selected' : ''}>All Types</option>
                            <option value="Load" ${logTypeFilter == 'Load' ? 'selected' : ''}>Load</option>
                            <option value="Unload" ${logTypeFilter == 'Unload' ? 'selected' : ''}>Unload</option>
                            <option value="Transfer" ${logTypeFilter == 'Transfer' ? 'selected' : ''}>Transfer</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="px-4 py-2 bg-port-accent text-white text-sm font-semibold rounded-lg hover:bg-slate-800 transition flex items-center justify-center gap-2 w-full md:w-auto">Filter Logs</button>
                </form>
            </div>

            <section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden" aria-label="Audit Logs Table">
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
                                <th class="px-6 py-3.5">Log ID</th>
                                <th class="px-6 py-3.5">Action Type</th>
                                <th class="px-6 py-3.5">Timestamp (IST)</th>
                                <th class="px-6 py-3.5">Authorized Handler</th>
                            </tr>
                        </thead>
                        <tbody id="auditLogBody" class="divide-y divide-slate-100 text-sm text-slate-600">
                            <% if (movementHistory != null && !movementHistory.isEmpty()) { 
                                for (CargoMovement m : movementHistory) { %>
                                <tr class="audit-row hover:bg-slate-50/50 transition duration-150">
                                    <td class="px-6 py-4 font-mono text-xs text-slate-900 font-semibold">#<%= m.getMovementId() %></td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-2">
                                            <% if ("Load".equals(m.getMovementType())) { %>
                                                <i data-lucide="arrow-down-to-line" class="w-4 h-4 text-emerald-600"></i>
                                                <span class="font-medium text-emerald-700">Load</span>
                                            <% } else if ("Unload".equals(m.getMovementType())) { %>
                                                <i data-lucide="arrow-up-from-line" class="w-4 h-4 text-amber-600"></i>
                                                <span class="font-medium text-amber-700">Unload</span>
                                            <% } else { %>
                                                <i data-lucide="arrow-right-left" class="w-4 h-4 text-blue-600"></i>
                                                <span class="font-medium text-blue-700">Transfer</span>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 font-mono text-xs text-slate-500"><%= m.getMovementDate() != null ? istFormat.format(m.getMovementDate()) : "" %></td>
                                    <td class="px-6 py-4 flex items-center gap-2">
                                        <div class="w-6 h-6 rounded-full bg-slate-200 border border-slate-300 flex items-center justify-center text-xs font-bold text-slate-600">
                                            <%= m.getHandlerName() != null && m.getHandlerName().length() > 0 ? m.getHandlerName().substring(0,1).toUpperCase() : "?" %>
                                        </div>
                                        <span class="font-medium text-slate-800"><%= m.getHandlerName() %></span>
                                    </td>
                                </tr>
                            <%  } } else { %>
                                <tr class="no-results-row">
                                    <td colspan="4" class="px-6 py-12 text-center text-slate-400">
                                        <div class="flex flex-col items-center justify-center space-y-2">
                                            <div class="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center border border-slate-200">
                                                <i data-lucide="folder-search" class="w-6 h-6 text-slate-400"></i>
                                            </div>
                                            <p class="font-semibold text-slate-700 mt-2">No movement history recorded</p>
                                            <p class="text-xs text-slate-400 max-w-xs mx-auto">This cargo item has not yet been processed or moved.</p>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            
                            <tr id="noSearchMatch" style="display:none;">
                                <td colspan="4" class="px-6 py-12 text-center text-slate-400">
                                    <div class="flex flex-col items-center justify-center space-y-2">
                                        <div class="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center border border-slate-200">
                                            <i data-lucide="search-x" class="w-6 h-6 text-slate-400"></i>
                                        </div>
                                        <p class="font-semibold text-slate-700 mt-2">No logs match your search.</p>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
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
        /* Confirm Logout Intercept Dialog box */
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

        /* Global Keyboard Handling */
        document.addEventListener('keydown', e => { 
            if (e.key === 'Escape') {
                closeLogoutModal();
            } 
        });

        lucide.createIcons();
    </script>
</body>
</html>