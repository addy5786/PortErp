package model;

import java.util.List;
import java.util.Map;
import operation_implementor.DockAllocation_Implementor;

public class DockAllocation {
    

    
    // Fields
    private int allocationId;
    private int shipId;
    private int dockId;
    private String shipName;
    private String dockName;
    private String allocationTime;
    private String releaseTime;
    
    // Getters and Setters
    public int getAllocationId() {
        return allocationId;
    }
    public void setAllocationId(int allocationId) {
        this.allocationId = allocationId;
    }
    public int getShipId() {
        return shipId;
    }
    public void setShipId(int shipId) {
        this.shipId = shipId;
    }
    public int getDockId() {
        return dockId;
    }
    public void setDockId(int dockId) {
        this.dockId = dockId;
    }
    public String getShipName() {
        return shipName;
    }
    public void setShipName(String shipName) {
        this.shipName = shipName;
    }
    public String getDockName() {
        return dockName;
    }
    public void setDockName(String dockName) {
        this.dockName = dockName;
    }
    public String getAllocationTime() {
        return allocationTime;
    }
    public void setAllocationTime(String allocationTime) {
        this.allocationTime = allocationTime;
    }
    public String getReleaseTime() {
        return releaseTime;
    }
    public void setReleaseTime(String releaseTime) {
        this.releaseTime = releaseTime;
    }

    DockAllocation_Implementor implementor = new DockAllocation_Implementor();
    
    // Business Logic Delegation Methods
    public String allocate_dock(DockAllocation dockAllocation) {
        return implementor.allocate_dock(dockAllocation);
    }
 
    public String release_dock(DockAllocation dockAllocation) {
        return implementor.release_dock(dockAllocation);
    }
 
    public String update_dock_allocation(DockAllocation dockAllocation) {
        return implementor.update_dock_allocation(dockAllocation);
    }
 
    public List<Map<String, Object>> view_active_allocations() {
        return implementor.view_active_allocations();
    }

    public List<Map<String, Object>> view_allocation_history() {
        return implementor.view_allocation_history();
    }

    public List<Map<String, Object>> view_anchored_ships() {
        return implementor.view_anchored_ships();
    }

    public List<Map<String, Object>> view_available_docks() {
        return implementor.view_available_docks();
    }

    public List<Map<String, Object>> search_dock(String input) {
        return implementor.search_dock(input);
    }
}