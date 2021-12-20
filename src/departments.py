from src.random_value_factory import *


@dataclass(frozen=True)
class Building(RandomEntry):
    address: Address
    phone_number: PhoneNumber
    requires_shipment: bool

    table_name: ClassVar[str] = "buildings"

    def __create__(*args, **kwargs) -> RandomEntry:
        return Building(
            RandomValueFactory.create_address(),
            RandomValueFactory.create_phone_number(),
            rand_bool()
        )


@dataclass(frozen=True)
class Department(Building):
    __instances__: ClassVar[List[Building]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "departments"

    def create(*args, **kwargs) -> Building:
        return Building.__create__(*args, **kwargs)


@dataclass(frozen=True)
class SortingDepartment(Building):
    __instances__: ClassVar[List[Building]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "sorting_departments"

    def create(*args, **kwargs) -> Building:
        return Building.__create__(*args, **kwargs)


@dataclass(frozen=True)
class CleaningDepartment(Building):
    __instances__: ClassVar[List[Building]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "cleaning_departments"

    acceptable_clothing_types: str  # TODO add clothing and defects
    acceptable_defect_types: str

    clothing_type_bounds: ClassVar[Bounds] = Bounds(3, 7)
    defect_type_bounds: ClassVar[Bounds] = Bounds(3, 7)

    def create(*args, **kwargs) -> Building:
        base = Building.__create__()

        return CleaningDepartment(
            base.address,
            base.phone_number,
            base.requires_shipment,
            ", ".join(choice(clothing_types, CleaningDepartment.clothing_type_bounds.random())),
            ", ".join(choice(defect_types, CleaningDepartment.defect_type_bounds.random()))
        )
