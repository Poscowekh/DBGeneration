from facilities import *
from people import *
from truck import *
from order import *
from shipment import *
from comment import *
from clothing import *


class Factory(BasicFactory):
    # Counts of types
    __layout__: Dict[type, int] = {
        type(Department): 25,
        type(SortingFacility): 5,
        type(CleaningFacility): 10,
        type(Truck): 15,
        type(Courier): 25,
        type(Manager): 50,
        type(Customer): 200,
        type(Order): 500,
        type(Shipment): 20,
        type(Comment): 700,
        type(Clothing): 1000
    }

    @staticmethod
    def get_layout() -> Dict[type, int]:
        return Factory.__layout__

    @staticmethod
    def set_layout(new_layout: Dict[type, int]) -> None:
        if new_layout.keys() != Factory.__layout__.keys():
            print("New layout improper")
            return

        Factory.__layout__ = new_layout

    layout = property(get_layout, set_layout)

    @staticmethod
    def create_all() -> Dict[type, List[Tuple]]:
        return {k: [k.get_instances()] for k, v in Factory.get_layout().items()}

    @staticmethod
    def create_department() -> Department:
        return Factory.create(Department)

    @staticmethod
    def create_sorting_facility() -> SortingFacility:
        return Factory.create(SortingFacility)

    @staticmethod
    def create_cleaning_facility() -> CleaningFacility:
        return Factory.create(CleaningFacility)

    @staticmethod
    def create_customer() -> Customer:
        return Factory.create(Customer)

    @staticmethod
    def create_manager(department_id_bounds: Tuple[int, int] = (0, layout[Department])) -> Manager:
        return Factory.create(Manager, department_id_bounds)

    @staticmethod
    def create_courier() -> Courier:
        return Factory.create(Courier)

    @staticmethod
    def create_truck() -> Truck:
        return

    @staticmethod
    def create_order() -> Order:
        pass

    @staticmethod
    def create_comment() -> Comment:
        pass
