package operations;

import java.util.List;
import java.util.Map;
import model.Dock;

public interface Dock_operation {
    void addDock(Dock dock);
    List<Dock> viewDock();
    void updateDockName(Dock dock);
    void updateDockStatus(Dock dock);
    void deleteDock(Dock dock);
    void viewAvailableDocks();
    void viewOccupiedDocks();
    void viewUnderMaintenanceDocks();
    List<Dock> searchDockByName(String keyword);
    List<Dock> searchDockByStatus(String status);
    Map<String, Integer> dockStatistics();
}