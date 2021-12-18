from src.basic_factory import *
from src.departments import Department, SortingDepartment, CleaningDepartment
from src.people import Manager, Customer, Courier
from src.order import Order
from src.shipment import Shipment
from src.clothing import Clothing
from src.truck import Truck


"""
order of generation:
    buildings: departments, sorting departments, cleaning departments;
    people: managers, couriers, customers;
    trucks;
    orders;
    shipments;
    clothing;
"""


@dataclass
class GeneratedEntry(ABC):
    """Already generated entry that is useful for generation dependant entries"""

    id: int = field(hash=True)
    """Id of the entry. Is equal to the position it is in the instances list"""
    entry: RandomEntry = field(compare=False)
    """The entry itself"""
    is_used: bool = field(default=False, compare=False)
    """Flag that defines whether this entry was used for generation of some depending entry type"""

    @property
    def tuple(self) -> Tuple[int, RandomEntry, bool]:
        """Implementation deleted"""
        raise NotImplementedError()

    @property
    def string(self) -> str:
        """Implementation deleted"""
        raise NotImplementedError()


@dataclass(frozen=True)
class ActiveManager(GeneratedEntry):
    """Manager entry with is_active flag set to True"""

    entry: Manager
    """The entry itself"""


@dataclass(frozen=True)
class ActiveCourier(GeneratedEntry):
    """Courier entry with is_active flag set to True"""

    entry: Courier
    """The entry itself"""


@dataclass(frozen=True)
class WorkingTruck(GeneratedEntry):
    """Truck entry with is_in_working_condition flag set to True"""

    entry: Truck
    """The entry itself"""


@dataclass(frozen=True)
class UnfinishedOrder(GeneratedEntry):
    """Courier entry with any no finished status"""

    entry: Order
    """The entry itself"""


class Factory(BasicFactory):
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
        Courier: 25,
        Manager: 50,
        Customer: 300,
        Truck: 15,
        Order: 400,
        Shipment: 50,
        Clothing: 700
    }
    """The layout of database: amount of entries to create for each of tables"""

    @staticmethod
    def get_layout() -> Dict[type, int]:
        """Returns the current layout"""
        return Factory.__layout__

    @staticmethod
    def set_layout(new_layout: Dict[type, int]) -> None:
        """Sets new layout if it fits the requirements"""

        new_layout_copy: Dict[type, int] = dict()

        for type_name, type_count in new_layout.items():
            if type_name not in Factory.__layout__.keys():
                raise ValueError("New layout does not mention all tables")
            if type_count <= 0:
                raise ValueError("Table row count cannot be equal or less than zero")
            new_layout_copy[type_name] = type_count

        Factory.__layout__ = new_layout_copy

    layout = property(get_layout, set_layout)
    """Current layout for database generation"""

    # Generated values useful for generation of other entries
    __active_couriers__: ClassVar[List[ActiveCourier]] = list()
    """Generated couriers with is_active flag set to True"""

    __active_managers__: ClassVar[List[ActiveManager]] = list()
    """Generated managers with is_active flag set to True"""

    __working_trucks__: ClassVar[List[WorkingTruck]] = list()
    """Generated trucks with is_in_working_condition flag set to True"""

    __unfinished_orders__: ClassVar[List[UnfinishedOrder]] = list()
    """Generated orders with any not finished status"""


    @staticmethod
    def create(cls: type, unique: bool = True, *args, **kwargs) -> RandomEntry:
        result = cls.create()

        if unique:
            while cls.exists(result):
                result = cls.create(*args, **kwargs)

        cls.register(result)

        return result

    @staticmethod
    def create_all() -> Dict[type, List[Tuple]]:
        """Creates all entries according to the layout and generation order"""

        for type_name in Factory.__generation_order__:
            # for each entry type

            # Some of the instance references must be saved in a list, other are not
            if type_name is ActiveCourier or type_name is ActiveManager:
                pass

            elif type_name is WorkingTruck:
                pass

            elif type_name is UnfinishedOrder:
                pass

            else:
                # standart instance creation
                for id in range(Factory.layout[type_name]):
                    Factory.c


        return {k: [k.get_instances()] for k, v in Factory.get_layout().items()}

    # buildings
    @staticmethod
    def create_department() -> Department:
        return Factory.create(Department)

    @staticmethod
    def create_sorting_department() -> SortingDepartment:
        return Factory.create(SortingDepartment)

    @staticmethod
    def create_cleaning_department() -> CleaningDepartment:
        return Factory.create(CleaningDepartment)

    # people
    @staticmethod
    def create_customer() -> Customer:
        return Factory.create(Customer)

    @staticmethod
    def create_manager(department_id_bounds: Bounds = Bounds(0, Factory.__layout__[Department])) -> Manager:
        return Factory.create(Manager, department_id_bounds)

    @staticmethod
    def create_courier() -> Courier:
        return Factory.create(Courier)

    # last
    @staticmethod
    def create_truck(courier_id_bounds: Bounds = Bounds(0, Factory.__layout__[Courier])) -> Truck:
        return Factory.create(Truck, courier_id_bounds)

    @staticmethod
    def create_order(
            customer_id_bounds: Bounds = Bounds(0, Factory.__layout__[Customer]),
            department_id_bounds: Bounds = Bounds(0, Factory.__layout__[Department]),
            manager_id_bounds: Bounds = Bounds(0, Factory.__layout__[Manager])
    ) -> Order:
        return Factory.create(
            Order,
            customer_id_bounds,
            department_id_bounds,
            manager_id_bounds
        )

    @staticmethod
    def create_shipment(
            department_id_bounds: Bounds = Bounds(0, Factory.__layout__[Department]),
            sorting_department_id_bounds: Bounds = Bounds(0, Factory.__layout__[SortingDepartment]),
            cleaning_department_id_bounds: Bounds = Bounds(0, Factory.__layout__[CleaningDepartment]),
            truck_id_bounds: Bounds = Bounds(0, Factory.__layout__[Truck])
    ) -> Shipment:
        return Factory.create(
            Shipment,
            department_id_bounds,
            sorting_department_id_bounds,
            cleaning_department_id_bounds,
            truck_id_bounds
        )
