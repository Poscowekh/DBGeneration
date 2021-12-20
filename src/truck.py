from src.random_value_factory import *
from src.people import Courier, ActiveCourier


@dataclass(frozen=True)
class Truck(RandomEntry):
    __instances__: ClassVar[List[RandomEntry]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "trucks"

    courier_id: int
    label: str
    is_in_working_condition: bool

    possible_labels: ClassVar[array_t] = array([
        "PlaceholderTruckLabel"
    ], dtype=str)

    def create(active_couriers: List[ActiveCourier], *args, **kwargs) -> RandomEntry:
        courier_id: int = None

        if rand_bool():
            courier_id, _ = ActiveCourier.choose_unused(active_couriers)

        return Truck(
            courier_id,
            none_or(choice(Truck.possible_labels)),
            rand_bool(7)
        )

    def __eq__(self, other):
        if not self.courier_id or other.courier_id:
            return False
        return self.courier_id == other.courier_id


@dataclass
class WorkingTruck(GeneratedEntry):
    """Truck entry with is_in_working_condition flag set to True"""

    entry: Truck
    """The entry itself"""
