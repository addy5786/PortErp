package operations;

import java.util.List;
import java.util.Map;
import model.DockAllocation;

public interface DockAllocation_Operations {
    String allocate_dock(DockAllocation dockAllocation);
    String release_dock(DockAllocation dockAllocation);
    String update_dock_allocation(DockAllocation dockAllocation);
    List<Map<String, Object>> view_active_allocations();
    List<Map<String, Object>> view_allocation_history();
    List<Map<String, Object>> view_anchored_ships();
    List<Map<String, Object>> view_available_docks();
    List<Map<String, Object>> search_dock(String input);
}