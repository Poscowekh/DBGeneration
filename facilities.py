from basic_factory import *
from clothing import Clothing


@dataclass(frozen=True)
class Facility(RandomEntry):
    address: Address
    phone_number: PhoneNumber
    requires_shipment: bool

    def tuplefy(self) -> Tuple:
        return (self.id,) + \
               self.address.tuplefy() + \
               self.phone_number.tuplefy() + \
               (self.requires_shipment,)


@dataclass(frozen=True)
class Department(Facility):
    def create(*args, **kwargs) -> Facility:
        id = Department.latest_id
        Department.latest_id += 1

        return Department(
            id,
            BasicFactory.create_address(),
            BasicFactory.create_phone_number(),
            rand_bool()
        )


@dataclass(frozen=True)
class SortingFacility(Facility):
    def create(*args, **kwargs) -> Facility:
        id = SortingFacility.latest_id
        SortingFacility.latest_id += 1

        return SortingFacility(
            id,
            BasicFactory.create_address(),
            BasicFactory.create_phone_number(),
            rand_bool()
        )


@dataclass(frozen=True)
class CleaningFacility(Facility):
    acceptable_clothing_types: str  # TODO add clothing and defects
    acceptable_defect_types: str

    clothing_type_bounds: ClassVar = (3, 7)
    defect_type_bounds: ClassVar = (3, 7)

    def create(*args, **kwargs) -> Facility:
        id = Facility.latest_id
        Facility.latest_id += 1

        return CleaningFacility(
            id,
            BasicFactory.create_address(),
            BasicFactory.create_phone_number(),
            rand_bool(),
            ", ".join(choice(clothing_types, rand_from_bounds(CleaningFacility.clothing_type_bounds))),
            ", ".join(choice(defect_types, rand_from_bounds(CleaningFacility.defect_type_bounds)))
        )

    def tuplefy(self) -> Tuple:
        return (self.id,) + \
               self.address.tuplefy() + \
               self.phone_number.tuplefy() + \
               (self.requires_shipment,
                self.acceptable_clothing_types,
                self.acceptable_defect_types)
