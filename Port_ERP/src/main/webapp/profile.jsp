<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Profile" %>
<%
// Stop execution instantly if accessed without an active logging state container
if (session == null || session.getAttribute("user_id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

// Safely extract user role to avoid NullPointerExceptions
String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "";

Profile profile = (Profile) request.getAttribute("profile");
String username = (String) session.getAttribute("username");
String message = request.getParameter("message");

if(profile == null){
    profile = new Profile();
    profile.setName("");
    profile.setEmail("");
    profile.setRole("");
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Settings | Port ERP</title>
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

    <%-- SIDEBAR NAVIGATION --%>
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
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager") || userRole.equalsIgnoreCase("Ship Operator")) { %>
                <a href="ShipManagement_Controller" class="nav-link nav-link-inactive" title="Ship Management">
                    <i data-lucide="ship" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Ship Management</span>
                </a>
                <% } %>
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager") || userRole.equalsIgnoreCase("Dock Manager")) { %>
                <a href="Dock.jsp" class="nav-link nav-link-inactive" title="Dock Management">
                    <i data-lucide="layers" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Dock Management</span>
                </a>
                <a href="dockAllocation.jsp" class="nav-link nav-link-inactive" title="Dock Allocation">
                    <i data-lucide="git-pull-request" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Dock Allocation</span>
                </a>
                <% } %>
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager") || userRole.equalsIgnoreCase("Ship Operator")) { %>
                <a href="ContainerController" class="nav-link nav-link-inactive" title="Container Management">
                    <i data-lucide="box" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Container Management</span>
                </a>
                <% } %>
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager") || userRole.equalsIgnoreCase("Cargo Handler")) { %>
                <a href="CargoController?action=list" class="nav-link nav-link-inactive" title="Cargo Management">
                    <i data-lucide="package" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Management</span>
                </a>
                <a href="CargoController?action=all_history" class="nav-link nav-link-inactive" title="Cargo Logs">
                    <i data-lucide="clipboard-list" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Cargo Logs</span>
                </a>
                <% } %>
                
                <% if (userRole.equalsIgnoreCase("Administrator") || userRole.equalsIgnoreCase("Port Manager")) { %>
                <a href="securitylog.jsp" class="nav-link nav-link-inactive" title="Security Log">
                    <i data-lucide="shield-alert" class="nav-icon-inactive"></i>
                    <span class="sidebar-text whitespace-nowrap">Security Log</span>
                </a>
                <% } %>
                
                <a href="profile" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="Profile / Settings">
                    <i data-lucide="user-cog" class="w-4 h-4 text-slate-900 flex-shrink-0"></i>
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
        <header class="h-16 bg-white border-b border-slate-200 flex items-center px-6 sticky top-0 z-10 shadow-sm flex-shrink-0">
            <div class="flex items-center gap-4">
                <button onclick="toggleMobileSidebar()" class="md:hidden text-slate-600 hover:text-slate-900 p-1 rounded hover:bg-slate-100">
                    <i data-lucide="menu" class="w-5 h-5"></i>
                </button>
                <h1 class="text-lg font-bold text-slate-700 tracking-tight whitespace-nowrap flex items-center gap-2">
                    <i data-lucide="user-cog" class="w-5 h-5 text-slate-600"></i> Profile & Settings
                </h1>
            </div>
            
            <div class="flex items-center gap-6 ml-auto">
                <div class="flex items-center gap-2 text-sm text-slate-600">
                    <i data-lucide="user-circle" class="w-5 h-5 text-slate-500"></i>
                    <span>Welcome, <strong class="text-slate-800"><%= username != null ? username : "" %></strong></span>
                </div>
                <button onclick="openModal('logoutModal')" class="bg-port-accent hover:bg-slate-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors">
                    Logout
                </button>
            </div>
        </header>

        <main class="p-6 max-w-5xl mx-auto w-full space-y-6 flex-1">
            <% if(message != null) { 
                boolean isError = message.toUpperCase().contains("FAIL") || message.toUpperCase().contains("ERROR");
                String alertClass = isError ? "bg-red-50 border-red-300 text-red-700" : "bg-green-50 border-green-300 text-green-700";
            %>
                <div class="<%= alertClass %> border px-5 py-4 rounded-xl shadow font-semibold flex items-center gap-2">
                    <i data-lucide="<%= isError ? "alert-circle" : "check-circle" %>" class="w-5 h-5"></i>
                    <%= message %>
                </div>
            <% } %>

            <%-- DYNAMIC USER DETAILS HERO CONTEXT BANNER --%>
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="bg-port-accent p-6 text-white border-l-4 border-[#FFEAD8]">
                    <div class="flex items-center gap-4">
                        <div class="w-20 h-20 rounded-full bg-white/10 flex items-center justify-center border border-slate-600">
                            <i data-lucide="user" class="w-10 h-10 text-slate-200"></i>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold tracking-tight">
                                <%= (profile != null && profile.getName() != null && !profile.getName().isEmpty()) ? profile.getName() : (username != null ? username : "User") %>
                            </h2>
                            <p class="text-xs mt-1.5 bg-black/20 inline-block px-2.5 py-1 rounded-md border border-slate-600/30">
                                Role Context: <strong class="text-[#FFEAD8]"><%= (profile != null && profile.getRole() != null && !profile.getRole().isEmpty()) ? profile.getRole() : (!userRole.equals("") ? userRole : "No Active Role") %></strong>
                            </p>
                        </div>
                    </div>
                </div>

                <div class="p-6 grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="border rounded-xl p-6 bg-slate-50/50">
                        <h3 class="text-sm font-semibold uppercase tracking-wider text-slate-400 mb-4">Update Identity Label</h3>
                        <form id="nameForm" action="profile" method="post" onsubmit="interceptSubmit(event, 'nameModal')">
                            <input type="hidden" name="action" value="updateName">
                            <div class="space-y-2">
                                <label class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Display Name</label>
                                <input type="text" name="name" required value="<%= (profile != null && profile.getName() != null && !profile.getName().isEmpty()) ? profile.getName() : (username != null ? username : "") %>" class="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm bg-white focus:ring-2 focus:ring-slate-500 outline-none transition">
                                <p class="text-xs text-slate-400">Your layout moniker configuration as logged across tables.</p>
                            </div>
                            <button type="submit" class="mt-5 bg-port-accent hover:bg-slate-700 text-white text-sm px-4 py-2 rounded-lg font-semibold shadow-sm transition">Save Changes</button>
                        </form>
                    </div>

                    <div class="border rounded-xl p-6 bg-slate-50/50">
                        <h3 class="text-sm font-semibold uppercase tracking-wider text-slate-400 mb-4">Update Communication Nodes</h3>
                        <form id="emailForm" action="profile" method="post" onsubmit="interceptSubmit(event, 'emailModal')">
                            <input type="hidden" name="action" value="updateEmail">
                            <div class="space-y-2">
                                <label class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Email Address</label>
                                <input type="email" name="email" required value="<%= (profile != null && profile.getEmail() != null && !profile.getEmail().isEmpty()) ? profile.getEmail() : (session.getAttribute("user_email") != null ? session.getAttribute("user_email").toString() : "") %>" class="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm bg-white focus:ring-2 focus:ring-slate-500 outline-none transition">
                                <p class="text-xs text-slate-400">Primary route used for account auditing metrics.</p>
                            </div>
                            <button type="submit" class="mt-5 bg-port-accent hover:bg-slate-700 text-white text-sm px-4 py-2 rounded-lg font-semibold shadow-sm transition">Update Email</button>
                        </form>
                    </div>

                    <div class="border rounded-xl p-6 bg-slate-50/50 lg:col-span-2">
                        <h3 class="text-sm font-semibold uppercase tracking-wider text-slate-400 mb-4">Access Credentials Ledger</h3>
                        <form id="passwordForm" action="profile" method="post" onsubmit="interceptSubmit(event, 'passwordModal')">
                            <input type="hidden" name="action" value="changePassword">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label class="text-xs font-semibold text-slate-500 uppercase tracking-wide">Current Cryptographic Key</label>
                                    <input type="password" name="currentPassword" required class="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm bg-white mt-1.5 focus:ring-2 focus:ring-slate-500 outline-none transition">
                                </div>
                                <div>
                                    <label class="text-xs font-semibold text-slate-500 uppercase tracking-wide">New Cryptographic Key</label>
                                    <input type="password" name="newPassword" required class="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm bg-white mt-1.5 focus:ring-2 focus:ring-slate-500 outline-none transition">
                                    <p class="text-xs text-slate-400 mt-2">Enforce uppercase variants, numeral vectors, and symbols.</p>
                                </div>
                            </div>
                            <button type="submit" class="mt-5 bg-port-accent hover:bg-slate-700 text-white text-sm px-4 py-2 rounded-lg font-semibold shadow-sm transition">Update Password</button>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <%-- MODALS --%>
    <div id="nameModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200">
        <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200">
            <div class="flex items-center gap-3 text-slate-700 mb-3">
                <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-600">
                    <i data-lucide="user-round" class="w-5 h-5"></i>
                </div>
                <h3 class="text-lg font-bold text-slate-800">Save Identity Changes?</h3>
            </div>
            <p class="text-sm text-slate-600 mb-6">Are you sure you want to write these display name alterations to your active record infrastructure?</p>
            <div class="flex gap-3 justify-end">
                <button type="button" onclick="closeModal('nameModal')" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">Cancel</button>
                <button type="button" onclick="confirmAndSubmit('nameForm')" class="px-4 py-2 text-sm font-semibold text-white bg-slate-700 hover:bg-slate-800 rounded-lg transition-colors shadow-sm">Save Changes</button>
            </div>
        </div>
    </div>

    <div id="emailModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200">
        <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200">
            <div class="flex items-center gap-3 text-slate-700 mb-3">
                <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-600">
                    <i data-lucide="mail" class="w-5 h-5"></i>
                </div>
                <h3 class="text-lg font-bold text-slate-800">Update Communication Nodes?</h3>
            </div>
            <p class="text-sm text-slate-600 mb-6">Updating your email impacts account auditing routing metrics. Do you wish to perform this transfer?</p>
            <div class="flex gap-3 justify-end">
                <button type="button" onclick="closeModal('emailModal')" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">Cancel</button>
                <button type="button" onclick="confirmAndSubmit('emailForm')" class="px-4 py-2 text-sm font-semibold text-white bg-slate-700 hover:bg-slate-800 rounded-lg transition-colors shadow-sm">Update Email</button>
            </div>
        </div>
    </div>

    <div id="passwordModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200">
        <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200">
            <div class="flex items-center gap-3 text-amber-600 mb-3">
                <div class="w-10 h-10 rounded-full bg-amber-50 flex items-center justify-center">
                    <i data-lucide="key-round" class="w-5 h-5"></i>
                </div>
                <h3 class="text-lg font-bold text-slate-800">Modify Security Cryptography?</h3>
            </div>
            <p class="text-sm text-slate-600 mb-6">You will be required to utilize your new cryptographic access token on your next systemic authentication sequence.</p>
            <div class="flex gap-3 justify-end">
                <button type="button" onclick="closeModal('passwordModal')" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">Cancel</button>
                <button type="button" onclick="confirmAndSubmit('passwordForm')" class="px-4 py-2 text-sm font-semibold text-white bg-amber-600 hover:bg-amber-700 rounded-lg transition-colors shadow-sm">Confirm Change</button>
            </div>
        </div>
    </div>

    <div id="logoutModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200">
        <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200">
            <div class="flex items-center gap-3 text-red-600 mb-3">
                <div class="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                    <i data-lucide="log-out" class="w-5 h-5"></i>
                </div>
                <h3 class="text-lg font-bold text-slate-800">Confirm Logout</h3>
            </div>
            <p class="text-sm text-slate-600 mb-6">Are you sure you want to log out of the Port ERP System? Any unsaved modifications within this configuration layer will be discarded.</p>
            <div class="flex gap-3 justify-end">
                <button type="button" onclick="closeModal('logoutModal')" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">Cancel</button>
                <a href="logout" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">Log Out</a>
            </div>
        </div>
    </div>

    <script>
        let currentActiveForm = null;

        // Functional Modal Controls
        function openModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.classList.remove('hidden');
            lucide.createIcons();
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.classList.add('hidden');
        }

        function interceptSubmit(event, modalId) {
            event.preventDefault();
            currentActiveForm = event.target;
            openModal(modalId);
        }

        function confirmAndSubmit(formId) {
            const form = document.getElementById(formId);
            if(form) {
                form.submit();
            }
        }

        window.onclick = function(event) {
            const modals = ['nameModal', 'emailModal', 'passwordModal', 'logoutModal'];
            modals.forEach(modalId => {
                const modal = document.getElementById(modalId);
                if (event.target === modal) {
                    closeModal(modalId);
                }
            });
        }

        // Sidebar Dynamics
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