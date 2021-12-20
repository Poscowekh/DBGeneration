from src.random_value_factory import *
from src.departments import Department, SortingDepartment, CleaningDepartment
from src.people import Manager, Customer, NotBannedCustomer, Courier, ActiveCourier
from src.truck import Truck, WorkingTruck
from src.order import Order, UnfinishedOrder, OrderStatus
from src.shipment import Shipment
from src.clothing import Clothing, ClothingStatus


"""
order of generation:
    buildings: departments, sorting departments, cleaning departments;
    people: managers, couriers, customers;
    trucks;
    orders;
    shipments;
    clothing;
"""


class RandomEntryFactory(RandomValueFactory):
    """Helps to create random entries for tables. May also create random values for entries"""

    __generation_order__: array_t = array([
        Department, SortingDepartment, CleaningDepartment,
        Courier, Manager, Customer,
        Truck,
        Order,
        Shipment,
        Clothing
    ], dtype=type)
    """Defines the order to create entries in"""

    __layout__: Dict[type, int] = {
        Department: 25,
        SortingDepartment: 5,
        CleaningDepartment: 10,
        Courier: 35,
        Manager: 50,
        Customer: 300,
        Truck: 20,
        Order: 400,
        Shipment: 50,
        Clothing: 700
    }
    """The layout of database: amount of entries to create for each of tables"""

    __active_couriers__: List[ActiveCourier] = list()
    """Generated instances of courier entry with is_active flag set to True"""
    __not_banned_customers__: List[NotBannedCustomer] = list()
    """Generated instances of customer entry with is_banned flag set to False"""
    __working_trucks__: List[WorkingTruck] = list()
    """Generated instances of truck entry with is_in_working_condition flag set to True"""
    __unfinished_orders__: List[UnfinishedOrder] = list()
    """Generated instances of order entry with any non-finished status value"""

    @staticmethod
    def get_layout() -> Dict[type, int]:
        """Returns the current layout"""
        return RandomEntryFactory.__layout__

    @staticmethod
    def set_layout(new_layout: Dict[Union[str, type], int]) -> None:
        """Sets new layout if it fits the requirements"""

        for type_or_name, type_count in new_layout.items():
            if isinstance(type_or_name, type) and type_or_name in RandomEntryFactory.__layout__.keys():
                continue
            elif isinstance(type_or_name, str) and type_or_name not in RandomEntryFactory.__layout__.keys():
                for key in RandomEntryFactory.__layout__.keys(): #type: type
                    if key.__name__ == type_or_name:
                        break
            else:
                raise ValueError("New layout does not define all entry counts")

            if type_count <= 0:
                raise ValueError("Table row count cannot be equal or less than zero")

        RandomEntryFactory.__layout__ = new_layout_copy

    @staticmethod
    def __create_all__() -> None:
        """Creates all entries according to the layout and generation order"""

        building_id: int = 1

        for id in range(building_id, building_id + RandomEntryFactory.__layout__[Department]): #type: int
            RandomEntryFactory.create_department(id)
        building_id += RandomEntryFactory.__layout__[Department]
        print(f"----generated {RandomEntryFactory.__layout__[Department]} departments;")

        for id in range(building_id, building_id + RandomEntryFactory.__layout__[SortingDepartment]): #type: int
            RandomEntryFactory.create_sorting_department(id)
        building_id += RandomEntryFactory.__layout__[SortingDepartment]
        print(f"----generated {RandomEntryFactory.__layout__[SortingDepartment]} sorting departments;")

        for id in range(building_id, building_id + RandomEntryFactory.__layout__[CleaningDepartment]): #type: int
            RandomEntryFactory.create_cleaning_department(id)
        building_id += RandomEntryFactory.__layout__[CleaningDepartment]
        print(f"----generated {RandomEntryFactory.__layout__[CleaningDepartment]} cleaning departments;")

        person_id: int = 1

        for id in range(person_id, person_id + RandomEntryFactory.__layout__[Courier]): #type: int
            RandomEntryFactory.create_courier(id)
        person_id += RandomEntryFactory.__layout__[Courier]
        print(f"----generated {RandomEntryFactory.__layout__[Courier]} couriers;")

        for id in range(person_id, person_id + RandomEntryFactory.__layout__[Manager]): #type: int
            RandomEntryFactory.create_manager(id)
        person_id += RandomEntryFactory.__layout__[Manager]
        print(f"----generated {RandomEntryFactory.__layout__[Manager]} managers;")

        for id in range(person_id, person_id + RandomEntryFactory.__layout__[Customer]):  # type: int
            RandomEntryFactory.create_customer(id)
        person_id += RandomEntryFactory.__layout__[Customer]
        print(f"----generated {RandomEntryFactory.__layout__[Customer]} customers;")

        for id in range(1, RandomEntryFactory.__layout__[Truck] + 1): #type: int
            RandomEntryFactory.create_truck(id)
        print(f"----generated {RandomEntryFactory.__layout__[Truck]} trucks;")

        for id in range(1, RandomEntryFactory.__layout__[Order] + 1): #type: int
            RandomEntryFactory.create_order(id)
        print(f"----generated {RandomEntryFactory.__layout__[Order]} order;")

        for id in range(1, RandomEntryFactory.__layout__[Shipment] + 1): #type: int
            RandomEntryFactory.create_shipment(id)
        print(f"----generated {RandomEntryFactory.__layout__[Shipment]} shipments;")

        for id in range(1, RandomEntryFactory.__layout__[Clothing] + 1): #type: int
            RandomEntryFactory.create_clothing(id)
        print(f"----generated {RandomEntryFactory.__layout__[Clothing]} clothing;")

    @staticmethod
    def create_all() -> Dict[type, List[RandomEntry]]:
        RandomEntryFactory.__create_all__()
        return {entry: entry.instances(entry) for entry in RandomEntryFactory.__generation_order__}

    @staticmethod
    def create_all_tuples() -> Dict[type, List[Tuple]]:
        RandomEntryFactory.__create_all__()
        return {entry: entry.tuple_instances(entry) for entry in RandomEntryFactory.__generation_order__}

    @staticmethod
    def create_csvs() -> Any:
        RandomEntryFactory.__create_all__()
        for entry in RandomEntryFactory.__generation_order__: #type: RandomEntry
            entry.to_csv(entry)

    # buildings
    @staticmethod
    def create_department(id: int) -> Department:
        return Department.create_unique(Department)

    @staticmethod
    def create_sorting_department(id: int) -> SortingDepartment:
        return SortingDepartment.create_unique(SortingDepartment)

    @staticmethod
    def create_cleaning_department(id: int) -> CleaningDepartment:
        return CleaningDepartment.create_unique(CleaningDepartment)

    # people
    @staticmethod
    def create_customer(id: int) -> Customer:
        result: Customer = Customer.create_unique(Customer)

        if not result.is_banned:
            RandomEntryFactory.__not_banned_customers__.append(NotBannedCustomer(id, result))

        return result

    @staticmethod
    def create_manager(id: int) -> Manager:
        return Manager.create_unique(Manager)

    @staticmethod
    def create_courier(id: int) -> Courier:
        result: Courier = Courier.create_unique(Courier)

        if result.is_active:
            RandomEntryFactory.__active_couriers__.append(ActiveCourier(id, result))

        return result

    # last
    @staticmethod
    def create_truck(id: int) -> Truck:
        result: Truck = Truck.create(RandomEntryFactory.__active_couriers__)

        while Truck.exists(Truck, result):
            result: Truck = Truck.create(RandomEntryFactory.__active_couriers__)

        Truck.register(Truck, result)

        if result.is_in_working_condition:
            RandomEntryFactory.__working_trucks__.append(WorkingTruck(id, result))

        return result

    @staticmethod
    def create_order(id: int) -> Order:
        result: Order = Order.create(RandomEntryFactory.__not_banned_customers__)

        while Order.exists(Order, result):
            result: Order = Order.create(RandomEntryFactory.__not_banned_customers__)

        Order.register(Order, result)

        if result.status != OrderStatus.arrived_back_to_department and \
                result.status != OrderStatus.arrived_to_customer:
            RandomEntryFactory.__unfinished_orders__.append(UnfinishedOrder(id, result))

        return result

    @staticmethod
    def create_shipment(id: int) -> Shipment:
        result: Shipment = Shipment.create(
            RandomEntryFactory.__working_trucks__,
            RandomEntryFactory.__layout__[Shipment] / len(RandomEntryFactory.__working_trucks__)
        )

        while Shipment.exists(Shipment, result):
            result: Shipment = Shipment.create(
                RandomEntryFactory.__working_trucks__,
                RandomEntryFactory.__layout__[Shipment] / len(RandomEntryFactory.__working_trucks__)
            )

            for working_truck in RandomEntryFactory.__working_trucks__:
                if working_truck.id == result.truck_id:
                    working_truck.is_used = False
                    break

        Shipment.register(Shipment, result)

        return result

    @staticmethod
    def create_clothing(id: int) -> Clothing:
        result: Clothing = Clothing.create(RandomEntryFactory.__unfinished_orders__)

        while Clothing.exists(Clothing, result):
            result: Clothing = Clothing.create(RandomEntryFactory.__unfinished_orders__)

        Clothing.register(Clothing, result)

        return result
