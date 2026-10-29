package model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;
import operation_implementor.Dashboard_Implementor;
import operations.Dashboard_operation;

public class Dashboard implements Serializable {

    private static final long serialVersionUID = 1L;

    // Internal link to the data operation layer (No Factory used)
    private static final Dashboard_operation dashboardOps = new Dashboard_Implementor();

    // Metric Fields
    private int totalUsers;
    private int totalShips;
    private int totalDocks;
    private int activeDocks;
    private int availableDocks;
    private int totalContainers;
    private int totalCargo;

    private int anchoredShips;
    private int dockedShips;
    private int departedShips;

    private int occupiedDocks;
    private int maintenanceDocks;

    private int pendingCargoCount; // Renamed field to completely prevent any method signature conflicts
    private int loadedCargo;
    private int unloadedCargo;

    public Dashboard() {}

    // ══════════ PASS-THROUGH OPERATIONAL METHODS ══════════

    public static Dashboard getDashboardCounts(int userId) {
        return dashboardOps.getDashboardCounts(userId);
    }

    public static List<Map<String, Object>> getMyShips(int userId) {
        return dashboardOps.getMyShips(userId);
    }

    public static List<Map<String, Object>> getUpcomingDepartures(int userId) {
        return dashboardOps.getUpcomingDepartures(userId);
    }

    public static List<Map<String, Object>> getDockBoard() {
        return dashboardOps.getDockBoard();
    }

    public static List<Map<String, Object>> getPendingCargoList() { // Renamed to avoid matching the count getter
        return dashboardOps.getPendingCargoList();
    }

    public static List<Map<String, Object>> getRecentlyHandledCargo(int userId) {
        return dashboardOps.getRecentlyHandledCargo(userId);
    }

    public static List<Map<String, Object>> getRecentActivities() {
        return dashboardOps.getRecentActivities();
    }

    // ══════════ GETTERS AND SETTERS ══════════
    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    public int getTotalShips() { return totalShips; }
    public void setTotalShips(int totalShips) { this.totalShips = totalShips; }

    public int getTotalDocks() { return totalDocks; }
    public void setTotalDocks(int totalDocks) { this.totalDocks = totalDocks; }

    public int getActiveDocks() { return activeDocks; }
    public void setActiveDocks(int activeDocks) { this.activeDocks = activeDocks; }

    public int getAvailableDocks() { return availableDocks; }
    public void setAvailableDocks(int availableDocks) { this.availableDocks = availableDocks; }

    public int getTotalContainers() { return totalContainers; }
    public void setTotalContainers(int totalContainers) { this.totalContainers = totalContainers; }

    public int getTotalCargo() { return totalCargo; }
    public void setTotalCargo(int totalCargo) { this.totalCargo = totalCargo; }

    public int getAnchoredShips() { return anchoredShips; }
    public void setAnchoredShips(int anchoredShips) { this.anchoredShips = anchoredShips; }

    public int getDockedShips() { return dockedShips; }
    public void setDockedShips(int dockedShips) { this.dockedShips = dockedShips; }

    public int getDepartedShips() { return departedShips; }
    public void setDepartedShips(int departedShips) { this.departedShips = departedShips; }

    public int getOccupiedDocks() { return occupiedDocks; }
    public void setOccupiedDocks(int occupiedDocks) { this.occupiedDocks = occupiedDocks; }

    public int getMaintenanceDocks() { return maintenanceDocks; }
    public void setMaintenanceDocks(int maintenanceDocks) { this.maintenanceDocks = maintenanceDocks; }

    public int getPendingCargoCount() { return pendingCargoCount; }
    public void setPendingCargoCount(int pendingCargoCount) { this.pendingCargoCount = pendingCargoCount; }

    public int getLoadedCargo() { return loadedCargo; }
    public void setLoadedCargo(int loadedCargo) { this.loadedCargo = loadedCargo; }

    public int getUnloadedCargo() { return unloadedCargo; }
    public void setUnloadedCargo(int unloadedCargo) { this.unloadedCargo = unloadedCargo; }
}