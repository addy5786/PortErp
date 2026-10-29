package operations;

import java.util.List;
import model.Container;

public interface Container_operation {
    String addContainer(Container c);
    List<Container> viewContainers();
    String updateContainer(Container c);
    String deleteContainer(int container_id);
    List<Container> filterContainer(String input);
    List<Container> viewContainerDetails(int container_id);
    List<String[]> getDockedShips();
}