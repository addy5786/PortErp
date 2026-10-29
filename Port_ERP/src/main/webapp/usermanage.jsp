<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.User"%>

<%
    // Intercept and prevent direct URL access bypass. Force routing through the Servlet controller.
    if (request.getAttribute("userList") == null) {
        response.sendRedirect(request.getContextPath() + "/UserController");
        return;
    }

    // FIX: Read directly from session scope to preserve identity states across page redirects
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if (username == null || username.trim().isEmpty()) username = "Guest";
    if (role == null || role.trim().isEmpty()) role = "Administrator"; 
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Port ERP | User Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        *{ margin:0; padding:0; box-sizing:border-box; }
        body{ background:#F8FAFC; overflow-x:hidden; color:#1E293B; }
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
            transition: all 150ms cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 0.875rem;
            justify-content: flex-start;
        }
        .nav-link-inactive { color: #E2E8F0; }
        .nav-link-inactive:hover {
            background-color: rgba(255, 255, 255, 0.06);
            color: #FFFFFF;
        }
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

        .hero-card{ background:#334155; border-left:4px solid #FFEAD8; color:white; padding:24px; border-radius:16px; box-shadow:0 4px 12px rgba(0,0,0,0.08); }
        .create-btn{ background:#334155; color:#FFEAD8; border:1px solid rgba(255,234,216,0.2); padding:12px 22px; border-radius:12px; font-size:14px; font-weight:600; cursor:pointer; display:flex; align-items:center; gap:8px; transition:all 0.2s ease; }
        .create-btn:hover{ background:#1E293B; color:white; border-color:rgba(255,255,255,0.2); transform:translateY(-1px); }
        .card{ background:white; border-radius:18px; border:1px solid #E2E8F0; box-shadow:0 1px 3px rgba(0,0,0,0.04); margin-bottom: 120px; overflow: hidden; }
        .table-filter-bar { padding: 20px 24px; border-bottom: 1px solid #E2E8F0; background: #FFFFFF; }
        .search-wrapper { position: relative; width: 100%; max-width: 400px; }
        .search-wrapper input { width: 100%; padding: 10px 16px 10px 42px; border: 1px solid #CBD5E1; background: #F8FAFC; border-radius: 10px; outline: none; font-size: 14px; transition: all .2s ease; }
        .search-wrapper input:focus { background: #FFFFFF; border-color: #475569; box-shadow: 0 0 0 3px rgba(71, 85, 105, 0.1); }
        .search-wrapper .search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94A3B8; pointer-events: none; }
        
        .table-responsive-container { width: 100%; overflow-x: auto; overflow-y: visible !important; position: relative; padding-bottom: 80px; }
        table{ width:100%; min-width:900px; border-collapse:separate; border-spacing: 0; }
        tr { position: relative; z-index: 1; }
        tr:focus-within, tr:hover { z-index: 50 !important; }
        th{ background:#F8FAFC; padding:18px 24px; text-align:left; font-size:12px; color:#64748B; text-transform:uppercase; letter-spacing:.08em; font-weight:700; border-bottom:1px solid #E2E8F0; position: relative; z-index: 5; }
        td{ padding:18px 24px; border-bottom:1px solid #F1F5F9; font-size:14px; overflow: visible !important; }
        
        .status{ padding:6px 12px; border-radius:999px; font-size:12px; font-weight:600; display:inline-flex; align-items:center; gap:6px; }
        .active-status{ background:#ECFDF3; color:#027A48; border:1px solid #ABEFC6; }
        .deactive-status{ background:#FEF3F2; color:#B42318; border:1px solid #FECDCA; }
        
        .action-menu{ position:relative; display:inline-block; z-index: 100; }
        .menu-btn{ border:1px solid #E2E8F0; background:white; font-size:16px; cursor:pointer; color:#334155; padding:10px 12px; border-radius:10px; transition:all .2s ease; }
        .menu-btn:hover{ background:#F8FAFC; }
        .dropdown-menu{ display:none; position:absolute; right:0; width:190px; background:white; border-radius:12px; overflow:hidden; border:1px solid #E2E8F0; box-shadow:0 10px 25px rgba(15,23,42,0.15); z-index:9999 !important; }
        .dropdown-menu.drop-up { bottom: 100%; margin-bottom: 6px; top: auto; }
        .dropdown-menu.drop-down { top: 100%; margin-top: 6px; bottom: auto; }
        .dropdown-menu.show{ display:block; }
        .dropdown-item{ width:100%; border:none; background:white; padding:12px 16px; text-align:left; cursor:pointer; font-size:14px; display:flex; align-items:center; gap:10px; color:#475569; }
        .dropdown-item:hover{ background:#F8FAFC; color:#1E293B; }
        .activate-item{ color:#027A48 !important; font-weight:600; }
        .deactivate-item{ color:#B42318 !important; font-weight:600; }
        
        .modal{ display:none; position:fixed; inset:0; background:rgba(15,23,42,0.45); backdrop-filter:blur(4px); z-index:3000; }
        .modal-content{ width:460px; max-width:92%; background:white; border-radius:20px; padding:30px; margin:60px auto; position:relative; border:1px solid #E2E8F0; box-shadow:0 20px 40px rgba(0,0,0,0.15); }
        .close{ position:absolute; top:16px; right:20px; font-size:26px; cursor:pointer; color:#64748B; }
        .form-group{ margin-bottom:18px; }
        .form-group label{ display:block; margin-bottom:8px; font-weight:600; font-size:14px; color:#475569; }
        .form-group input, .form-group select{ width:100%; padding:13px 14px; border:1px solid #CBD5E1; background:white; border-radius:10px; outline:none; font-size:14px; transition:all .2s ease; }
        .form-group input:focus, .form-group select:focus{ border-color:#475569; box-shadow:0 0 0 3px rgba(71,85,105,.15); }
        .submit-btn{ width:100%; padding:14px; border:none; border-radius:12px; background:#334155; color:#FFEAD8; font-size:14px; font-weight:600; cursor:pointer; transition:all .2s ease; }
        .submit-btn:hover{ background:#1E293B; color:white; }
        .flash-error{ background:#FEF2F2; color:#B91C1C; border:1px solid #FECACA; border-radius:12px; padding:14px 18px; font-size:14px; font-weight:600; }
        
        #successToast { position: fixed; top: 24px; right: 24px; background: #FFFFFF; border-left: 4px solid #10B981; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); border-radius: 12px; padding: 16px 20px; z-index: 9999; transform: translateX(120%); transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); display: flex; align-items: center; gap: 12px; min-width: 330px; }
        #successToast.show-toast { transform: translateX(0); }
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
                
                <% if ("Administrator".equals(role)) { %>
                <a href="UserController" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="User Management">
                    <i data-lucide="users" class="w-4 h-4 text-slate-900 flex-shrink-0"></i>
                    <span class="sidebar-text whitespace-nowrap">User Management</span>
                </a>
                <% } %>
                
                <a href="shipManagement.jsp" class="nav-link nav-link-inactive" title="Ship Management">
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
                <a href="containermanagement.jsp" class="nav-link nav-link-inactive" title="Container Management">
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
        <header class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-6 sticky top-0 z-10 shadow-sm flex-shrink-0">
            <div class="flex items-center gap-4">
                <button onclick="toggleMobileSidebar()" class="md:hidden text-slate-600 hover:text-slate-900 p-1 rounded hover:bg-slate-100">
                    <i data-lucide="menu" class="w-5 h-5"></i>
                </button>
                <h1 class="text-lg font-bold text-slate-700 tracking-tight whitespace-nowrap flex items-center gap-2">
                    <i data-lucide="users" class="w-5 h-5 text-slate-600"></i> Port ERP | Identity Systems
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
            <div class="hero-card">
                <h2 class="text-2xl font-bold tracking-tight">User Management Ledger</h2>
                <p class="text-slate-300 text-sm mt-1">Manage all port system users, access layers, and operational privileges efficiently.</p>
            </div>

            <%
                String errorMsg = (String) request.getAttribute("errorMsg");
                if (errorMsg != null && !errorMsg.isEmpty()) {
            %>
            <div class="flash-error">
                <i class="fa-solid fa-circle-exclamation"></i>
                <%= errorMsg %>
            </div>
            <%
                }
            %>

            <div class="flex justify-end">
                <button class="create-btn" onclick="openModal()">
                    <i class="fa-solid fa-plus"></i> Create New User
                </button>
            </div>

            <div class="card">
                <div class="table-filter-bar">
                    <div class="search-wrapper">
                        <i data-lucide="search" class="search-icon w-4 h-4"></i>
                        <input type="text" id="userSearchInput" onkeyup="filterUserTable()" placeholder="Search by name, ID, email, role, status...">
                    </div>
                </div>

                <div class="table-responsive-container">
                    <%
                        ArrayList<User> userList = (ArrayList<User>) request.getAttribute("userList");
                        if (userList == null || userList.isEmpty()) {
                    %>
                    <div class="px-6 py-16 text-center text-slate-400">
                        <div class="flex flex-col items-center justify-center space-y-3">
                            <div class="w-14 h-14 rounded-full bg-slate-50 flex items-center justify-center border border-slate-200">
                                <i data-lucide="users" class="w-6 h-6"></i>
                            </div>
                            <h4 class="font-bold text-slate-700 text-base">No users found</h4>
                            <p class="text-xs text-slate-400">No users are currently registered in the system.</p>
                        </div>
                    </div>
                    <% } else { %>
                    <table id="userTable">
                        <thead>
                            <tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
                                <th class="px-6 py-3.5">ID</th>
                                <th class="px-6 py-3.5">Name</th>
                                <th class="px-6 py-3.5">Email</th>
                                <th class="px-6 py-3.5">Role</th>
                                <th class="px-6 py-3.5">Status</th>
                                <th class="px-6 py-3.5">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-sm text-slate-600">
                            <%
                                for (User u : userList) {
                                    String status = u.getStatus();
                                    String safeId    = String.valueOf(u.getUserId());
                                    String safeName  = escapeHtml(u.getName());
                                    String safeEmail = escapeHtml(u.getEmail());
                                    String safeRole  = escapeHtml(u.getRoleName());
                            %>
                            <tr class="hover:bg-slate-50/50 transition duration-150">
                                <td class="px-6 py-4 font-mono text-xs text-slate-900 font-semibold">#<%= safeId %></td>
                                <td class="px-6 py-4 font-medium text-slate-900"><%= safeName %></td>
                                <td class="px-6 py-4"><%= safeEmail %></td>
                                <td class="px-6 py-4"><%= safeRole %></td>
                                <td class="px-6 py-4">
                                    <span class="status <%= status.equalsIgnoreCase("ACTIVE") ? "active-status" : "deactive-status" %>">
                                        <span class="w-1.5 h-1.5 rounded-full bg-current"></span>
                                        <%= status %>
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="action-menu">
                                        <button class="menu-btn"
                                                data-user-id="<%= safeId %>"
                                                data-user-name="<%= safeName %>"
                                                data-user-email="<%= safeEmail %>"
                                                data-user-role="<%= safeRole %>"
                                                onclick="toggleMenu(this,event)">
                                            <i class="fa-solid fa-ellipsis"></i>
                                        </button>

                                        <div class="dropdown-menu">
                                            <button type="button" class="dropdown-item" onclick="openEditModalFromBtn(this.closest('.action-menu').querySelector('.menu-btn'))">
                                                <i class="fa-solid fa-pen-to-square"></i> Edit Details
                                            </button>

                                            <% if (status.equalsIgnoreCase("ACTIVE")) { %>
                                            <form action="${pageContext.request.contextPath}/UserController" method="post" style="margin: 0;" onsubmit="return handleStatusConfirm(this, event, 'deactivate', '<%= safeName %>')">
                                                <input type="hidden" name="deactivate" value="deactivate">
                                                <input type="hidden" name="userId" value="<%= safeId %>">
                                                <button type="submit" class="dropdown-item deactivate-item">
                                                    <i class="fa-solid fa-user-slash"></i> Deactivate
                                                </button>
                                            </form>
                                            <% } else { %>
                                            <form action="${pageContext.request.contextPath}/UserController" method="post" style="margin: 0;" onsubmit="return handleStatusConfirm(this, event, 'activate', '<%= safeName %>')">
                                                <input type="hidden" name="activate" value="activate">
                                                <input type="hidden" name="userId" value="<%= safeId %>">
                                                <button type="submit" class="dropdown-item activate-item">
                                                    <i class="fa-solid fa-user-check"></i> Activate
                                                </button>
                                            </form>
                                            <% } %>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                    
                    <div id="noResultsBlock" class="hidden px-6 py-16 text-center text-slate-400">
                        <div class="flex flex-col items-center justify-center space-y-3">
                            <div class="w-14 h-14 rounded-full bg-slate-50 flex items-center justify-center border border-slate-200">
                                <i data-lucide="search-x" class="w-6 h-6 text-slate-400"></i>
                            </div>
                            <h4 class="font-bold text-slate-700 text-base">No matching results</h4>
                            <p class="text-xs text-slate-400">Try adjusting your keywords or search query criteria.</p>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </main>
    </div>
</div>

<div class="modal" id="addModal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h2 class="text-xl font-bold text-slate-700 mb-6">Add User</h2>
        <form action="${pageContext.request.contextPath}/UserController" method="post" autocomplete="off">
            <input type="hidden" name="insert" value="insert">
            <div class="form-group">
                <label>Name</label>
                <input type="text" name="name" maxlength="100" required>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" maxlength="100" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password1" minlength="6" required>
            </div>
            <div class="form-group">
                <label>Role</label>
                <select name="roleId">
                    <option value="1">Administrator</option>
                    <option value="2">Port Manager</option>
                    <option value="3">Ship Operator</option>
                    <option value="4">Dock Manager</option>
                    <option value="5">Cargo Handler</option>
                </select>
            </div>
            <button type="submit" class="submit-btn">Create User</button>
        </form>
    </div>
</div>

<div class="modal" id="editModal">
    <div class="modal-content">
        <span class="close" onclick="closeEditModal()">&times;</span>
        <h2 class="text-xl font-bold text-slate-700 mb-6">Edit User</h2>
        <form action="${pageContext.request.contextPath}/UserController" method="post">
            <input type="hidden" name="update" value="update">
            <input type="hidden" name="userId" id="editUserId">
            <div class="form-group">
                <label>Name</label>
                <input type="text" name="name" id="editName" maxlength="100" required>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" id="editEmail" maxlength="100" required>
            </div>
            <div class="form-group">
                <label>Role</label>
                <select name="roleId" id="editRole">
                    <option value="1">Administrator</option>
                    <option value="2">Port Manager</option>
                    <option value="3">Ship Operator</option>
                    <option value="4">Dock Manager</option>
                    <option value="5">Cargo Handler</option>
                </select>
            </div>
            <button type="submit" class="submit-btn">Update User</button>
        </form>
    </div>
</div>

<div id="customConfirmModal" class="fixed inset-0 z-[5000] hidden flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-sm">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-2xl border border-slate-100 overflow-hidden transform transition-all scale-95 opacity-0 duration-200" id="confirmBox">
        <div class="p-6">
            <div class="flex items-start gap-4">
                <div id="confirmIconContainer" class="w-10 h-10 rounded-full flex items-center justify-center shrink-0 border">
                    <i id="confirmIcon" class="w-5 h-5"></i>
                </div>
                <div class="space-y-1.5 flex-1">
                    <h3 id="confirmTitle" class="text-base font-bold text-slate-800">Confirm Action</h3>
                    <p id="confirmMessage" class="text-sm text-slate-500 leading-relaxed">Are you sure you want to proceed?</p>
                </div>
            </div>
        </div>
        <div class="bg-slate-50 px-6 py-4 flex justify-end gap-3 border-t border-slate-100">
            <button id="confirmCancelBtn" type="button" class="px-4 py-2 rounded-xl text-sm font-semibold text-slate-600 bg-white border border-slate-200 hover:bg-slate-50 transition-colors">
                Cancel
            </button>
            <button id="confirmActionBtn" type="button" class="px-4 py-2 rounded-xl text-sm font-semibold text-white transition-all shadow-sm">
                Confirm
            </button>
        </div>
    </div>
</div>

<div id="logoutModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-[5000] hidden transition-opacity duration-200">
    <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200" id="logoutBox">
        <div class="flex items-center gap-3 text-red-600 mb-3">
            <div class="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                <i data-lucide="log-out" class="w-5 h-5"></i>
            </div>
            <h3 class="text-lg font-bold text-slate-800">Confirm Logout</h3>
        </div>
        <p class="text-sm text-slate-600 mb-6">Are you sure you want to log out of the Port ERP Management system? Any unsaved work metrics will be discarded.</p>
        <div class="flex gap-3 justify-end">
            <button onclick="closeLogoutModal()" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                Cancel
            </button>
            <a href="logout" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">
                Log Out
            </a>
        </div>
    </div>
</div>

<div id="successToast">
    <div class="w-8 h-8 rounded-full bg-emerald-50 flex items-center justify-center border border-emerald-100 text-emerald-600 shrink-0">
        <i class="fa-solid fa-circle-check text-sm"></i>
    </div>
    <div class="flex-1">
        <h4 class="text-xs font-bold text-slate-800 uppercase tracking-wide">System Notice</h4>
        <p id="toastMessage" class="text-xs text-slate-500 mt-0.5 font-medium"></p>
    </div>
    <button type="button" onclick="dismissToast()" class="text-slate-400 hover:text-slate-600 transition-colors ml-2">
        <i class="fa-solid fa-xmark text-sm"></i>
    </button>
</div>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value
            .replace("&","&amp;")
            .replace("<","&lt;")
            .replace(">","&gt;")
            .replace("\"","&quot;")
            .replace("'","&#x27;");
    }
%>

<script>
lucide.createIcons();

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
    const box = document.getElementById('logoutBox');
    modal.classList.remove('hidden');
    setTimeout(() => {
        box.classList.remove('scale-95');
        box.classList.add('scale-100');
    }, 10);
    return false;
}

function closeLogoutModal() {
    const modal = document.getElementById('logoutModal');
    const box = document.getElementById('logoutBox');
    box.classList.remove('scale-100');
    box.classList.add('scale-95');
    setTimeout(() => {
        modal.classList.add('hidden');
    }, 150);
}

function filterUserTable() {
    const input = document.getElementById("userSearchInput");
    const filter = input.value.toLowerCase().trim();
    const table = document.getElementById("userTable");
    
    if(!table) return;
    
    const rows = table.getElementsByTagName("tbody")[0].getElementsByTagName("tr");
    const noResultsBlock = document.getElementById("noResultsBlock");
    let visibleRowsCount = 0;

    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const idCell = row.cells[0] ? row.cells[0].textContent : "";
        const nameCell = row.cells[1] ? row.cells[1].textContent : "";
        const emailCell = row.cells[2] ? row.cells[2].textContent : "";
        const roleCell = row.cells[3] ? row.cells[3].textContent : "";
        const statusCell = row.cells[4] ? row.cells[4].textContent : "";

        const combinedText = (idCell + " " + nameCell + " " + emailCell + " " + roleCell + " " + statusCell).toLowerCase();

        if (combinedText.includes(filter)) {
            row.style.display = "";
            visibleRowsCount++;
        } else {
            row.style.display = "none";
        }
    }

    if (visibleRowsCount === 0) {
        table.style.display = "none";
        if(noResultsBlock) noResultsBlock.classList.remove("hidden");
    } else {
        table.style.display = "";
        if(noResultsBlock) noResultsBlock.classList.add("hidden");
    }
}

<%
String toastMsgParam = request.getParameter("toastMsg");
if (toastMsgParam != null && !toastMsgParam.isEmpty()) {
%>
window.addEventListener("load", () => {
 showSuccessToast("<%= escapeHtml(toastMsgParam) %>");
 if (window.history.replaceState) {
     const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
     window.history.replaceState({ path: cleanUrl }, '', cleanUrl);
 }
});
<%
}
%>

function openModal() { document.getElementById("addModal").style.display = "block"; }
function closeModal() { document.getElementById("addModal").style.display = "none"; }
function closeEditModal() { document.getElementById("editModal").style.display = "none"; }

function openEditModalFromBtn(btn) {
    const id    = btn.dataset.userId;
    const name  = btn.dataset.userName;
    const email = btn.dataset.userEmail;
    const role  = btn.dataset.userRole;

    document.getElementById("editModal").style.display = "block";
    document.getElementById("editUserId").value = id;
    document.getElementById("editName").value   = name;
    document.getElementById("editEmail").value  = email;

    const roleMap = {
        "Administrator":"1",
        "Port Manager":"2",
        "Ship Operator":"3",
        "Dock Manager":"4",
        "Cargo Handler":"5"
    };
    document.getElementById("editRole").value = roleMap[role] || "5";
}

let resolveConfirm;

function showCustomConfirm({ title, message, type, actionText }) {
    const modal = document.getElementById("customConfirmModal");
    const box = document.getElementById("confirmBox");
    const titleEl = document.getElementById("confirmTitle");
    const msgEl = document.getElementById("confirmMessage");
    const actionBtn = document.getElementById("confirmActionBtn");
    const iconContainer = document.getElementById("confirmIconContainer");
    const icon = document.getElementById("confirmIcon");

    titleEl.textContent = title;
    msgEl.innerHTML = message;
    actionBtn.textContent = actionText;

    iconContainer.className = "w-10 h-10 rounded-full flex items-center justify-center shrink-0 border";
    actionBtn.className = "px-4 py-2 rounded-xl text-sm font-semibold transition-all shadow-sm";
    icon.className = "";

    if (type === 'danger') {
        iconContainer.classList.add("bg-red-50", "border-red-200", "text-red-600");
        icon.className = "fa-solid fa-user-slash text-sm";
        actionBtn.classList.add("bg-red-600", "hover:bg-red-700", "text-white");
    } else {
        iconContainer.classList.add("bg-emerald-50", "border-emerald-200", "text-emerald-600");
        icon.className = "fa-solid fa-user-check text-sm";
        actionBtn.classList.add("bg-slate-700", "hover:bg-slate-800", "text-[#FFEAD8]");
    }

    modal.classList.remove("hidden");
    setTimeout(() => {
        box.classList.remove("scale-95", "opacity-0");
        box.classList.add("scale-100", "opacity-100");
    }, 10);

    return new Promise((resolve) => { resolveConfirm = resolve; });
}

function closeCustomConfirm(result) {
    const box = document.getElementById("confirmBox");
    const modal = document.getElementById("customConfirmModal");
    box.classList.remove("scale-100", "opacity-100");
    box.classList.add("scale-95", "opacity-0");
    setTimeout(() => {
        modal.classList.add("hidden");
        if(resolveConfirm) resolveConfirm(result);
    }, 150);
}

document.getElementById("confirmActionBtn").addEventListener("click", () => closeCustomConfirm(true));
document.getElementById("confirmCancelBtn").addEventListener("click", () => closeCustomConfirm(false));

async function handleStatusConfirm(form, event, actionType, username) {
    if (form.dataset.confirmed === "true") return true;
    event.preventDefault(); 

    let setup = actionType === 'deactivate' ? {
        title: "Deactivate User",
        message: `Are you sure you want to <strong>DEACTIVATE</strong> user: <span class="text-slate-900 font-semibold">${username}</span>?<br>They will lose system access privileges immediately.`,
        type: "danger",
        actionText: "Deactivate Profile"
    } : {
        title: "Activate User",
        message: `Are you sure you want to <strong>ACTIVATE</strong> user: <span class="text-slate-900 font-semibold">${username}</span>?<br>Their standard profile operational access will be restored.`,
        type: "success",
        actionText: "Activate Profile"
    };

    const approved = await showCustomConfirm(setup);
    if (approved) {
        form.dataset.confirmed = "true";
        form.submit(); 
    }
    return false;
}

function toggleMenu(button, event){
    event.stopPropagation();
    const menu = button.nextElementSibling;
    const row = button.closest('tr');

    document.querySelectorAll("#userTable tbody tr").forEach(r => { r.style.zIndex = "1"; });
    document.querySelectorAll(".dropdown-menu").forEach(drop => { if(drop !== menu) drop.classList.remove("show"); });

    const buttonRect = button.getBoundingClientRect();
    const spaceBelow = window.innerHeight - buttonRect.bottom;
    if (spaceBelow < 160) {
        menu.classList.remove("drop-down"); menu.classList.add("drop-up");
    } else {
        menu.classList.remove("drop-up"); menu.classList.add("drop-down");
    }

    if (!menu.classList.contains("show") && row) {
        row.style.setProperty("z-index", "100", "important");
    }
    menu.classList.toggle("show");
}

document.addEventListener("click", function(){
    document.querySelectorAll(".dropdown-menu").forEach(m => m.classList.remove("show"));
    if(document.getElementById("userTable")) {
        document.querySelectorAll("#userTable tbody tr").forEach(r => { r.style.zIndex = "1"; });
    }
});

window.onclick = function(event){
    const addModal = document.getElementById("addModal");
    const editModal = document.getElementById("editModal");
    const logoutModal = document.getElementById("logoutModal");

    if(event.target === addModal) addModal.style.display = "none";
    if(event.target === editModal) editModal.style.display = "none";
    if(event.target === logoutModal) closeLogoutModal();
};

function showSuccessToast(message) {
    const toast = document.getElementById("successToast");
    document.getElementById("toastMessage").textContent = message;
    toast.classList.add("show-toast");
    setTimeout(() => { dismissToast(); }, 4000);
}
function dismissToast() { document.getElementById("successToast").classList.remove("show-toast"); }
</script>
</body>
</html>