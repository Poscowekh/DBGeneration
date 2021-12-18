from people import *


@dataclass(frozen=True)
class Truck(RandomEntry):
    courier_id: int
    label: str
    is_in_working_condition: bool

    possible_labels: ClassVar = nparray([
        "PlaceholderTruckLabel"
    ], dtype=str)

    def create(courier_id_bounds: int, *args, **kwargs) -> RandomEntry:
        id = Truck.latest_id
        Truck.latest_id += 1

        return Truck(
            id,
            rand_from_bounds(courier_id_bounds),
            None, # choice(Truck.possible_labels),
            rand_bool()
        )

    def tuplefy(self) -> Tuple:
        return (self.id,
                self.courier_id,
                self.label,
                self.is_in_working_condition)