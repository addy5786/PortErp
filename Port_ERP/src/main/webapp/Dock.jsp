<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="model.Dock"%>

<%
if (session == null || session.getAttribute("user_id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String userRole = (session.getAttribute("role") != null) ? session.getAttribute("role").toString() : "";

Dock dockObj = new Dock();
List<Dock> dockList     = (List<Dock>) request.getAttribute("dockList");
List<Dock> searchResult = (List<Dock>) request.getAttribute("searchResult");
boolean    isSearchMode = (searchResult != null);

if (dockList == null) { dockList = dockObj.viewDock(); }

Map<String, Integer> stats = dockObj.dockStatistics();
int available   = stats.getOrDefault("available",   0);
int occupied    = stats.getOrDefault("occupied",    0);
int maintenance = stats.getOrDefault("maintenance", 0);
int total       = stats.getOrDefault("total",       0);

String toastMsg  = "";
String toastType = "";
if (request.getParameter("added")   != null) { toastMsg = "✅ Dock added successfully!";   toastType = "success"; }
if (request.getParameter("updated") != null) { toastMsg = "✏️ Dock updated successfully!"; toastType = "info";    }
if (request.getParameter("deleted") != null) { toastMsg = "🗑️ Dock deleted successfully!"; toastType = "danger";  }
if (request.getParameter("deleteBlocked") != null) { toastMsg = "🚢 Cannot delete an occupied dock. Please free the berth first."; toastType = "warning"; }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dock Management | Port Management System</title>
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

.stat-card { cursor: pointer; transition: transform 0.25s cubic-bezier(.34,1.56,.64,1), box-shadow 0.25s ease; }
.stat-card:hover { transform: translateY(-4px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05); }
.stat-panel { display: none; }
.stat-panel.open { display: block; }

.btn-edit { display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.375rem 0.75rem; border: 1px solid #E2E8F0; border-radius: 0.375rem; font-size: 0.75rem; font-weight: 500; color: #334155; background: #ffffff; transition: all 0.15s; }
.btn-edit:hover { border-color: #94A3B8; background-color: #F8FAFC; }
.btn-delete { display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.375rem 0.75rem; border: 1px solid #FEE2E2; border-radius: 0.375rem; font-size: 0.75rem; font-weight: 500; color: #DC2626; background: #FEF2F2; transition: all 0.15s; }
.btn-delete:hover { border-color: #FCA5A5; background: #FFE4E6; }

#toast { position: fixed; top: 1rem; left: 50%; transform: translateX(-50%) translateY(-120px); z-index: 100; display: flex; align-items: center; gap: 0.5rem; padding: 0.875rem 1.5rem; border-radius: 0.75rem; font-size: 0.875rem; font-weight: 700; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); opacity: 0; transition: transform 0.3s cubic-bezier(.34,1.56,.64,1), opacity 0.3s; }
#toast.show { transform: translateX(-50%) translateY(0); opacity: 1; }
#toast.success { background: #F0FDF4; color: #166534; border: 1px solid #BBF7D0; border-l-4 border-l-[#166534]; }
#toast.info    { background: #EFF6FF; color: #1E40AF; border: 1px solid #BFDBFE; border-l-4 border-l-[#1E40AF]; }
#toast.danger  { background: #FEF2F2; color: #991B1B; border: 1px solid #FEE2E2; border-l-4 border-l-[#991B1B]; }
#toast.warning { background: #FEFCE8; color: #854D0E; border: 1px solid #FEF08A; border-l-4 border-l-[#854D0E]; }

.modal-overlay { 
    position: fixed; 
    inset: 0; 
    background: rgba(15, 23, 42, 0.6); 
    backdrop-filter: blur(4px); 
    display: none; 
    align-items: center;      
    justify-content: center;  
    z-index: 50; 
    padding: 1rem;            
}
.modal-overlay.flex { display: flex; }
</style>
</head>

<body class="bg-slate-50 text-slate-800 font-sans flex h-screen overflow-hidden">

<div id="toast"><span id="toastIcon"></span><span id="toastText"></span></div>

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

			<a href="DockController" class="nav-link bg-port-active text-slate-900 font-semibold shadow-md" title="Dock Management"> 
				<i data-lucide="layers" class="w-4 h-4 text-slate-900 flex-shrink-0"></i> 
				<span class="sidebar-text whitespace-nowrap">Dock Management</span>
			</a> 
			
			<a href="dockAllocation.jsp" class="nav-link nav-link-inactive" title="Dock Allocation"> 
				<i data-lucide="git-pull-request" class="nav-icon-inactive"></i> 
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
		<span class="sidebar-text whitespace-nowrap">Role: <strong class="text-slate-300"><%= !userRole.equals("") ? userRole : "No Role Assigned" %></strong></span>
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
                <i data-lucide="layers" class="w-5 h-5 text-slate-600"></i> Dock Management System
            </h1>
		</div>
		
		<div class="flex items-center gap-6 ml-auto">
			<div class="flex items-center gap-2 text-sm text-slate-600">
				<i data-lucide="user-circle" class="w-5 h-5 text-slate-500"></i> 
				<span>Welcome, <strong class="text-slate-800"><%= session.getAttribute("username") != null ? session.getAttribute("username") : "User" %></strong></span>
			</div>
			<a href="logout" onclick="return confirmLogout(event);" class="bg-port-accent hover:bg-slate-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors">Logout</a>
		</div>
	</header>

	<main class="p-6 max-w-7xl w-full mx-auto space-y-6 flex-1">

		<div class="bg-port-accent p-6 rounded-xl text-white shadow border-l-4 border-l-[#FFEAD8]">
			<h2 class="text-2xl font-bold tracking-tight">Dock Infrastructure Operations</h2>
			<p class="text-slate-300 text-sm mt-1">Manage physical berthing hubs, verify terminal usage statuses, and adjust infrastructure assignments.</p>
		</div>

		<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

			<section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
				<div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4">
					<span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Operational Entry</span>
					<h3 class="text-lg font-bold text-slate-700">Add New Dock</h3>
				</div>
				<form action="DockController" method="post" class="p-6 space-y-4" id="addDockForm">
					<input type="hidden" name="add" value="true">
					<div class="form-step-card">
						<div>
							<label class="block text-xs font-medium text-slate-500 mb-1">Dock Name</label>
							<input type="text" name="dockName" required class="form-input-field" placeholder="Enter Dock Name">
						</div>
						<div>
							<label class="block text-xs font-medium text-slate-500 mb-1">Status Matrix</label>
							<select name="status" class="form-input-field">
								<option>Available</option>
								<option>Under Maintenance</option>
							</select>
						</div>
					</div>
					<div class="pt-4 border-t border-slate-100 flex justify-end">
						<button type="submit" class="bg-port-accent hover:bg-slate-600 text-white px-6 py-2.5 rounded-lg font-medium text-sm transition shadow-sm hover:shadow">Add Dock Infrastructure</button>
					</div>
				</form>
			</section>

			<section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
				<div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4">
					<span class="text-xs font-semibold uppercase tracking-wider text-slate-400">System Information Lookup</span>
					<h3 class="text-lg font-bold text-slate-700">Search Hub</h3>
				</div>
				<div class="p-6">
					<form action="DockController" method="post" class="space-y-4" id="searchForm">
						<input type="hidden" name="search" id="hiddenSearch" value="true">
						<input type="hidden" name="searchStatus" id="hiddenSearchStatus" value="" disabled>
						
						<div class="form-step-card">
							<div>
								<label class="block text-xs font-medium text-slate-500 mb-1">Query Category</label>
								<select id="searchByDropdown" class="form-input-field" onchange="toggleSearchInput()">
									<option value="name">Name Parameters</option>
									<option value="status">Status Parameters</option>
								</select>
							</div>
							<div id="nameInputWrapper">
								<label class="block text-xs font-medium text-slate-500 mb-1">Dock Name Target</label>
								<input type="text" name="keyword" class="form-input-field" placeholder="Enter Dock Name">
							</div>
							<div id="statusInputWrapper" class="hidden">
								<label class="block text-xs font-medium text-slate-500 mb-1">Functional Status Target</label>
								<select name="status" class="form-input-field">
									<option>Available</option>
									<option>Occupied</option>
									<option>Under Maintenance</option>
								</select>
							</div>
						</div>

						<div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-2">
							<% if (isSearchMode) { %>
							<button type="button" onclick="clearSearch()" class="px-4 py-2 border border-slate-300 rounded-lg text-sm text-slate-600 hover:bg-slate-50 transition flex items-center gap-1">
								<i data-lucide="x" class="w-4 h-4"></i> Clear Filters
							</button>
							<% } %>
							<button type="submit" class="bg-port-accent hover:bg-slate-600 text-white px-5 py-2 rounded-lg text-sm font-medium flex items-center gap-1.5 transition shadow-sm">
								<i data-lucide="search" class="w-4 h-4"></i> Execute Search
							</button>
						</div>
					</form>
				</div>
			</section>
		</div>

		<section class="space-y-3">
			<div class="flex items-center justify-between">
				<h3 class="text-sm font-semibold uppercase tracking-wider text-slate-400">Live Status Metrics</h3>
				<span class="text-[11px] text-slate-400 tracking-wider">Click dashboard panels to toggle context sheets</span>
			</div>

			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
				<div class="stat-card bg-white p-5 rounded-xl shadow-sm border border-slate-200 border-l-4 border-l-emerald-500" onclick="togglePanel('panel-available')">
					<div class="flex items-center justify-between">
						<p class="text-xs font-medium text-slate-500 uppercase tracking-wider">Available Docks</p>
						<span class="w-7 h-7 rounded-lg bg-emerald-50 flex items-center justify-center border border-emerald-100">
							<i data-lucide="check-circle" class="w-4 h-4 text-emerald-600"></i>
						</span>
					</div>
					<h2 class="text-3xl font-bold text-slate-800 mt-2"><%= available %></h2>
					<p class="text-[11px] text-slate-400 mt-2 flex items-center gap-1"><i data-lucide="chevron-down" class="w-3 h-3"></i> Expand tracking log</p>
				</div>

				<div class="stat-card bg-white p-5 rounded-xl shadow-sm border border-slate-200 border-l-4 border-l-blue-500" onclick="togglePanel('panel-occupied')">
					<div class="flex items-center justify-between">
						<p class="text-xs font-medium text-slate-500 uppercase tracking-wider">Occupied Docks</p>
						<span class="w-7 h-7 rounded-lg bg-blue-50 flex items-center justify-center border border-blue-100">
							<i data-lucide="ship" class="w-4 h-4 text-blue-600"></i>
						</span>
					</div>
					<h2 class="text-3xl font-bold text-slate-800 mt-2"><%= occupied %></h2>
					<p class="text-[11px] text-slate-400 mt-2 flex items-center gap-1"><i data-lucide="chevron-down" class="w-3 h-3"></i> Expand tracking log</p>
				</div>

				<div class="stat-card bg-white p-5 rounded-xl shadow-sm border border-slate-200 border-l-4 border-l-amber-500" onclick="togglePanel('panel-maintenance')">
					<div class="flex items-center justify-between">
						<p class="text-xs font-medium text-slate-500 uppercase tracking-wider">Under Maintenance</p>
						<span class="w-7 h-7 rounded-lg bg-amber-50 flex items-center justify-center border border-amber-100">
							<i data-lucide="wrench" class="w-4 h-4 text-amber-600"></i>
						</span>
					</div>
					<h2 class="text-3xl font-bold text-slate-800 mt-2"><%= maintenance %></h2>
					<p class="text-[11px] text-slate-400 mt-2 flex items-center gap-1"><i data-lucide="wrench" class="w-3 h-3"></i> Expand tracking log</p>
				</div>

				<div class="stat-card bg-white p-5 rounded-xl shadow-sm border border-slate-200 border-l-4 border-l-slate-700" onclick="togglePanel('panel-total')">
					<div class="flex items-center justify-between">
						<p class="text-xs font-medium text-slate-500 uppercase tracking-wider">Total Registered</p>
						<span class="w-7 h-7 rounded-lg bg-slate-50 flex items-center justify-center border border-slate-200">
							<i data-lucide="layers" class="w-4 h-4 text-slate-600"></i>
						</span>
					</div>
					<h2 class="text-3xl font-bold text-slate-800 mt-2"><%= total %></h2>
					<p class="text-[11px] text-slate-400 mt-2 flex items-center gap-1"><i data-lucide="chevron-down" class="w-3 h-3"></i> Expand tracking log</p>
				</div>
			</div>

			<div class="space-y-2">
				<div id="panel-available" class="stat-panel bg-slate-100/80 border border-slate-200 rounded-lg p-4 text-xs text-slate-700">
					<p class="font-bold mb-1 flex items-center gap-1.5"><i data-lucide="anchor" class="w-4 h-4 text-emerald-600"></i> Available Berths Summary</p>
					<p><strong><%= available %></strong> infrastructure nodes are free and cleared for incoming allocations.</p>
				</div>
				<div id="panel-occupied" class="stat-panel bg-slate-100/80 border border-slate-200 rounded-lg p-4 text-xs text-slate-700">
					<p class="font-bold mb-1 flex items-center gap-1.5"><i data-lucide="ship" class="w-4 h-4 text-blue-600"></i> Active Occupancy Metrics</p>
					<p><strong><%= occupied %></strong> structural positions are locked by vessels. Run an allocation lookup to display targeted IDs.</p>
				</div>
				<div id="panel-maintenance" class="stat-panel bg-slate-100/80 border border-slate-200 rounded-lg p-4 text-xs text-slate-700">
					<p class="font-bold mb-1 flex items-center gap-1.5"><i data-lucide="wrench" class="w-4 h-4 text-amber-600"></i> Engineering & MRO Registers</p>
					<p><strong><%= maintenance %></strong> bays are isolated for repairs or structural evaluation logs.</p>
				</div>
				<div id="panel-total" class="stat-panel bg-slate-100/80 border border-slate-200 rounded-lg p-4 text-sm text-slate-700">
					<p class="font-bold mb-2 flex items-center gap-1.5 text-slate-800 text-base">Total Managed Infrastructure Overview</p>
					<div class="flex flex-wrap gap-3 mt-2 font-mono text-xs">
						<span class="bg-emerald-50 text-emerald-700 px-3 py-1.5 rounded-md border border-emerald-200 shadow-xs font-semibold"><%= available %> Available</span>
						<span class="bg-blue-50 text-blue-700 px-3 py-1.5 rounded-md border border-blue-200 shadow-xs font-semibold"><%= occupied %> Occupied</span>
						<span class="bg-amber-50 text-amber-700 px-3 py-1.5 rounded-md border border-amber-200 shadow-xs font-semibold"><%= maintenance %> Under Maintenance</span>
					</div>
				</div>
			</div>
		</section>

		<% if (isSearchMode) { %>
		<section id="searchResultSection" class="bg-white rounded-xl border border-amber-200 shadow-sm overflow-hidden">
			<div class="border-b border-amber-100 bg-amber-50/50 px-6 py-4 flex items-center justify-between">
				<div>
					<span class="text-xs font-semibold uppercase tracking-wider text-amber-600">Search Yield Context</span>
					<h3 class="text-lg font-bold text-slate-800 flex items-center gap-2">
						<i data-lucide="search" class="w-4 h-4 text-amber-500"></i> Active Filter Matrix
						<span class="text-xs font-mono bg-amber-100 border border-amber-200 text-amber-800 px-2.5 py-0.5 rounded-full"><%= searchResult.size() %> entries found</span>
					</h3>
				</div>
				<button onclick="clearSearch()" class="inline-flex items-center gap-1 px-3 py-1.5 border border-amber-200 hover:border-amber-300 text-xs font-medium text-amber-800 bg-white rounded-md transition shadow-xs">
					<i data-lucide="x-circle" class="w-3.5 h-3.5"></i> Clear Filters & Restore Registers
				</button>
			</div>
			
			<% if (searchResult.isEmpty()) { %>
			<div class="p-12 text-center text-slate-400">
				<i data-lucide="search-x" class="w-10 h-10 mx-auto mb-2 text-slate-300"></i>
				<h4 class="font-bold text-slate-700 text-sm">No infrastructure indices matched your filters</h4>
				<p class="text-xs mt-1">Adjust query text arrays or status parameters before executing searches.</p>
			</div>
			<% } else { %>
			<div class="overflow-x-auto">
				<table class="w-full text-left border-collapse">
					<thead>
						<tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
							<th class="px-6 py-3.5">Dock ID</th>
							<th class="px-6 py-3.5">Dock Structural Label</th>
							<th class="px-6 py-3.5">Current Matrix Status</th>
							<th class="px-6 py-3.5 text-center">Management Controls</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100 text-sm text-slate-600">
					<% for (Dock d : searchResult) {
						String badge = "bg-slate-100 text-slate-800 border-slate-200";
						if (d.getStatus().equalsIgnoreCase("Available")) badge = "bg-emerald-50 text-emerald-700 border-emerald-200";
						if (d.getStatus().equalsIgnoreCase("Occupied")) badge = "bg-blue-50 text-blue-700 border-blue-200";
						if (d.getStatus().equalsIgnoreCase("Under Maintenance")) badge = "bg-amber-50 text-amber-700 border-amber-200";
					%>
						<tr class="hover:bg-slate-50/40 transition duration-150 bg-amber-50/10">
							<td class="px-6 py-4 font-mono text-xs font-bold text-slate-500">#<%= d.getDockId() %></td>
							<td class="px-6 py-4 font-medium text-slate-900"><%= d.getDockName() %></td>
							<td class="px-6 py-4">
								<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border <%= badge %>"><%= d.getStatus() %></span>
							</td>
							<td class="px-6 py-4 text-center">
								<div class="flex items-center justify-center gap-2">
									<button onclick="openEditModal('<%= d.getDockId() %>','<%= d.getDockName() %>','<%= d.getStatus() %>')" class="btn-edit">
										<i data-lucide="pencil" class="w-3.5 h-3.5"></i> Edit
									</button>
									<button type="button" onclick="triggerDeleteModal('<%= d.getDockId() %>', '<%= d.getStatus() %>')" class="btn-delete">
										<i data-lucide="trash-2" class="w-3.5 h-3.5"></i> Delete
									</button>
								</div>
							</td>
						</tr>
					<% } %>
					</tbody>
				</table>
			</div>
			<% } %>
		</section>
		<% } %>

		<section id="registeredDocksSection" class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
			<div class="border-b border-slate-100 bg-slate-50/75 px-6 py-4 flex items-center justify-between">
				<div>
					<span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Master Record Arrays</span>
					<h3 class="text-lg font-bold text-slate-700">View Registered Docks</h3>
				</div>
				<span class="text-xs font-mono bg-slate-100 text-slate-600 px-2.5 py-1 rounded border border-slate-200"><%= dockList.size() %> total terminals</span>
			</div>
			
			<div class="overflow-x-auto">
				<table class="w-full text-left border-collapse">
					<thead>
						<tr class="bg-slate-50/75 border-b border-slate-200 text-xs font-semibold uppercase text-slate-500 tracking-wider">
							<th class="px-6 py-3.5">Dock ID</th>
							<th class="px-6 py-3.5">Dock Structural Label</th>
							<th class="px-6 py-3.5">Current Matrix Status</th>
							<th class="px-6 py-3.5 text-center">Management Controls</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-slate-100 text-sm text-slate-600">
					<% for (Dock d : dockList) {
						String badge = "bg-slate-100 text-slate-800 border-slate-200";
						if (d.getStatus().equalsIgnoreCase("Available")) badge = "bg-emerald-50 text-emerald-700 border-emerald-200";
						if (d.getStatus().equalsIgnoreCase("Occupied")) badge = "bg-blue-50 text-blue-700 border-blue-200";
						if (d.getStatus().equalsIgnoreCase("Under Maintenance")) badge = "bg-amber-50 text-amber-700 border-amber-200";
					%>
						<tr class="hover:bg-slate-50/50 transition duration-150">
							<td class="px-6 py-4 font-mono text-xs font-bold text-slate-500">#<%= d.getDockId() %></td>
							<td class="px-6 py-4 font-medium text-slate-900"><%= d.getDockName() %></td>
							<td class="px-6 py-4">
								<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border <%= badge %>"><%= d.getStatus() %></span>
							</td>
							<td class="px-6 py-4 text-center">
								<div class="flex items-center justify-center gap-2">
									<button onclick="openEditModal('<%= d.getDockId() %>','<%= d.getDockName() %>','<%= d.getStatus() %>')" class="btn-edit">
										<i data-lucide="pencil" class="w-3.5 h-3.5"></i> Edit
									</button>
									<button type="button" onclick="triggerDeleteModal('<%= d.getDockId() %>', '<%= d.getStatus() %>')" class="btn-delete">
										<i data-lucide="trash-2" class="w-3.5 h-3.5"></i> Delete
									</button>
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

<%-- ══════════════════════ EDIT MODAL (FALLBACK PROTECTION) ══════════════════════ --%>
<div id="editModal" class="modal-overlay" onclick="closeModal()">
	<div class="bg-white rounded-xl shadow-2xl border border-slate-200/80 max-w-md w-full overflow-hidden mx-4 transform transition-all flex flex-col my-auto" onclick="event.stopPropagation()">
		
		<div class="bg-slate-900 px-6 py-4 text-white flex items-center justify-between border-b border-slate-800 flex-shrink-0">
			<div class="flex items-center gap-2.5">
				<div class="p-1.5 bg-slate-800 rounded-lg border border-slate-700">
					<i data-lucide="edit-3" class="w-4 h-4 text-slate-300"></i>
				</div>
				<div>
					<h3 class="font-bold text-sm tracking-tight text-slate-100">Update Dock Parameters</h3>
					<p class="text-[10px] text-slate-400 -mt-0.5 uppercase tracking-wider">Infrastructure Matrix Configuration</p>
				</div>
			</div>
			<button type="button" class="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-slate-800 transition-colors" onclick="closeModal()">
				<i data-lucide="x" class="w-4 h-4"></i>
			</button>
		</div>

		<form action="DockController" method="post" class="p-6 space-y-4 m-0" onsubmit="markUpdated()">
			<input type="hidden" name="update" value="true">
			<input type="hidden" id="editDockId" name="dockId">

			<div class="flex items-center justify-between px-3 py-2 bg-slate-50 border border-slate-200/60 rounded-lg text-xs">
				<span class="font-medium text-slate-500">Identified Context Target:</span>
				<span class="font-mono font-bold bg-white px-2.5 py-1 rounded border border-slate-200 text-slate-700 flex items-center gap-1 shadow-sm">
					<i data-lucide="hash" class="w-3 h-3 text-slate-400"></i><span id="editDockIdDisplay">—</span>
				</span>
			</div>

			<div>
				<label class="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-1.5">Target Description Label</label>
				<input type="text" id="editDockName" name="dockName" required
					class="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-sm text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition duration-150 shadow-sm" 
					placeholder="Specify updated structural label string">
			</div>

			<div>
				<label class="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-1.5">System Operational Status</label>
				<select id="editStatus" name="status" 
					class="w-full px-3 py-2 bg-white border border-slate-300 rounded-lg text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition duration-150 cursor-pointer shadow-sm">
					<option value="Available">Available</option>
					<option value="Under Maintenance">Under Maintenance</option>
				</select>
			</div>

			<div class="pt-4 border-t border-slate-100 flex items-center justify-end gap-3">
				<button type="button" onclick="closeModal()" 
					class="px-4 py-2 border border-slate-300 text-slate-600 hover:bg-slate-50 rounded-lg text-sm font-semibold transition duration-150">
					Abort Action
				</button>
				<button type="submit" 
					class="bg-slate-900 hover:bg-slate-800 text-white px-4 py-2 rounded-lg text-sm font-semibold shadow-md hover:shadow-lg transition duration-150 flex items-center gap-2">
					<i data-lucide="save" class="w-4 h-4 text-slate-400"></i> Commit Log Changes
				</button>
			</div>
		</form>
	</div>
</div>

<%-- ══════════════════════ DELETE CONFIRMATION MODAL ══════════════════════ --%>
<div id="deleteModal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50 hidden transition-opacity duration-200" onclick="closeDeleteModalOnBackdrop(event)">
    <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 border border-slate-200 m-4 transform scale-95 transition-transform duration-200" onclick="event.stopPropagation()">
        <div class="flex items-center gap-3 text-red-600 mb-3">
            <div class="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center">
                <i data-lucide="trash-2" class="w-5 h-5"></i>
            </div>
            <h3 class="text-lg font-bold text-slate-800">Confirm Infrastructure Deletion</h3>
        </div>
        <p class="text-sm text-slate-600 mb-6">Are you sure you want to delete dock terminal <strong id="deleteDockIdDisplay"></strong>? Removing this physical node cannot be undone and clears matching master record arrays.</p>
        <div class="flex gap-3 justify-end">
            <button onclick="closeDeleteModal()" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                Cancel
            </button>
            <form id="deleteForm" action="DockController" method="post" class="inline m-0">
                <input type="hidden" name="delete" value="true">
                <input type="hidden" name="dockId" id="deleteDockIdInput">
                <input type="hidden" name="dockStatus" id="deleteDockStatusInput">
                <button type="submit" class="px-4 py-2 text-sm font-semibold text-white bg-red-500 hover:bg-red-600 rounded-lg transition-colors shadow-sm">
                    Delete Dock Terminal
                </button>
            </form>
        </div>
    </div>
</div>

<%-- ══════════════════════ LOGOUT MODAL ══════════════════════ --%>
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
const toastMsg  = "<%= toastMsg %>";
const toastType = "<%= toastType %>";

function showToast(msg, type) {
  const el = document.getElementById('toast');
  document.getElementById('toastText').textContent = msg;
  el.className = 'show ' + type;
  setTimeout(() => { el.className = type; }, 3500);
}

function scrollToSection(id, delay = 120) {
  setTimeout(() => {
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, delay);
}

window.addEventListener('load', () => {
  lucide.createIcons();

  if (toastMsg) showToast(toastMsg, toastType);

  const pending = sessionStorage.getItem('pendingToast');
  if (pending) {
    const { msg, type } = JSON.parse(pending);
    showToast(msg, type);
    sessionStorage.removeItem('pendingToast');
  }

  const params = new URLSearchParams(window.location.search);
  if (params.has('added') || params.has('updated') || params.has('deleted')) {
    scrollToSection('registeredDocksSection');
  }

  if (<%= isSearchMode ? "true" : "false" %>) {
    scrollToSection('searchResultSection');
  }
});

function clearSearch() {
  sessionStorage.setItem('scrollTo', 'registeredDocksSection');
  window.location.href = 'DockController';
}

window.addEventListener('load', () => {
  const target = sessionStorage.getItem('scrollTo');
  if (target) {
    sessionStorage.removeItem('scrollTo');
    scrollToSection(target, 200);
  }
});

function togglePanel(id) {
  document.querySelectorAll('.stat-panel').forEach(p => { if (p.id !== id) p.classList.remove('open'); });
  document.getElementById(id).classList.toggle('open');
}

function toggleSearchInput() {
  const mode = document.getElementById("searchByDropdown").value;
  document.getElementById("nameInputWrapper").classList.toggle("hidden", mode !== "name");
  document.getElementById("statusInputWrapper").classList.toggle("hidden", mode === "name");
  document.getElementById("hiddenSearch").disabled       = (mode !== "name");
  document.getElementById("hiddenSearch").value          = (mode === "name") ? "true" : "";
  document.getElementById("hiddenSearchStatus").disabled = (mode === "name");
  document.getElementById("hiddenSearchStatus").value    = (mode !== "name") ? "true" : "";
}

function openEditModal(id, name, status) {
  document.getElementById("editDockIdDisplay").textContent = id;
  document.getElementById("editDockId").value              = id;
  document.getElementById("editDockName").value            = name;
  
  const statusDropdown = document.getElementById("editStatus");
  
  // Clean up any dynamic temporary choices left over from previous modal selections
  const customOpt = statusDropdown.querySelector('.custom-dynamic-option');
  if (customOpt) customOpt.remove();

  // Clean up any previously disabled Occupied flag option layout
  let occupiedOption = statusDropdown.querySelector('option[value="Occupied"]');
  if (occupiedOption) occupiedOption.remove();

  // Handle standard exact match options
  if (status.toLowerCase() === 'available' || status.toLowerCase() === 'under maintenance') {
      // Direct standardization match alignment
      statusDropdown.value = (status.toLowerCase() === 'available') ? "Available" : "Under Maintenance";
  } else if (status.toLowerCase() === 'occupied') {
      // Inject standard protected Occupied flag option block layout
      occupiedOption = document.createElement("option");
      occupiedOption.value = "Occupied";
      occupiedOption.textContent = "Occupied (Locked by Allocation)";
      occupiedOption.disabled = true;
      statusDropdown.appendChild(occupiedOption);
      statusDropdown.value = "Occupied";
  } else {
      // FALLBACK PROTECTION: Keep the exact raw value from your table cell exactly as it is 
      const fallbackOption = document.createElement("option");
      fallbackOption.value = status;
      fallbackOption.textContent = status ? status : "— (No Value Specified)";
      fallbackOption.className = "custom-dynamic-option";
      statusDropdown.appendChild(fallbackOption);
      statusDropdown.value = status;
  }

  document.getElementById("editModal").classList.add("flex");
  lucide.createIcons();
}

function closeModal() {
  document.getElementById("editModal").classList.remove("flex");
}

function triggerDeleteModal(dockId, status) {
  if (status && status.toLowerCase() === 'occupied') {
    showToast('🚢 Cannot delete an occupied dock. Please free the berth first.', 'warning');
    return;
  }
  
  document.getElementById('deleteDockIdInput').value = dockId;
  document.getElementById('deleteDockStatusInput').value = status;
  document.getElementById('deleteDockIdDisplay').innerText = "#" + dockId;
  
  const modal = document.getElementById('deleteModal');
  modal.classList.remove('hidden');
  lucide.createIcons();
}

function closeDeleteModal() {
  const modal = document.getElementById('deleteModal');
  modal.classList.add('hidden');
}

function closeDeleteModalOnBackdrop(e) {
  if (e.target === document.getElementById('deleteModal')) closeDeleteModal();
}

document.getElementById('deleteForm')?.addEventListener('submit', () => {
  sessionStorage.setItem('pendingToast', JSON.stringify({ msg: '🗑️ Dock deleted successfully!', type: 'danger' }));
});

function markUpdated() {
  sessionStorage.setItem('pendingToast', JSON.stringify({ msg: '✏️ Dock updated successfully!', type: 'info' }));
}

document.getElementById('addDockForm')?.addEventListener('submit', () => {
  sessionStorage.setItem('pendingToast', JSON.stringify({ msg: '✅ Dock added successfully!', type: 'success' }));
});

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
    const logoutModal = document.getElementById('logoutModal');
    if (event.target === logoutModal) {
        closeLogoutModal();
    }
}

document.addEventListener('keydown', e => { 
    if (e.key === 'Escape') {
        closeModal(); 
        closeLogoutModal();
        closeDeleteModal();
    } 
});

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
</script>

</body>
</html>