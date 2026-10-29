package model;

import java.util.List;
import java.util.Map;
import operation_implementor.Dock_implementor;

public class Dock {

    private int dockId;
    private String dockName;
    private String status;
    private int total;
    private int available;
    private int occupied;
    private int maintenance;

    // Getters and Setters
    public int getDockId() { return dockId; }
    public void setDockId(int dockId) { this.dockId = dockId; }

    public String getDockName() { return dockName; }
    public void setDockName(String dockName) { this.dockName = dockName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }

    public int getAvailable() { return available; }
    public void setAvailable(int available) { this.available = available; }

    public int getOccupied() { return occupied; }
    public void setOccupied(int occupied) { this.occupied = occupied; }

    public int getMaintenance() { return maintenance; }
    public void setMaintenance(int maintenance) { this.maintenance = maintenance; }
    
    Dock_implementor implementor = new Dock_implementor();

    public void addDock(Dock dock) { implementor.addDock(dock); }
    public List<Dock> viewDock() { return implementor.viewDock(); }
    public void updateDockName(Dock dock) { implementor.updateDockName(dock); }
    public void updateDockStatus(Dock dock) { implementor.updateDockStatus(dock); }
    public void deleteDock(Dock dock) { implementor.deleteDock(dock); }
    public List<Dock> searchDockByName(String keyword) { return implementor.searchDockByName(keyword); }
    public List<Dock> searchDockByStatus(String status) { return implementor.searchDockByStatus(status); }
    public Map<String, Integer> dockStatistics() { return implementor.dockStatistics(); }
}