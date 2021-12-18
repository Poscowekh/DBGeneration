from basic_factory import *

@dataclass(frozen=True)
class Clothing(RandomEntry):
    order_id: int
    shipment_id: int

    type: str
    defect_type: str

    name: str
    comment: str

    type_bounds: ClassVar = (1, 3)
    defect_type_bounds: ClassVar = (1, 4)

    possible_clothing_names: ClassVar = nparray([
        "PlaceholderClothingName"
    ], dtype=str)

    def create(order_id_bounds: Tuple[int, int],
               shipment_id_bounds: Tuple[int, int],
               *args,
               **kwargs):
        id = Clothing.latest_id
        Clothing.latest_id += 1

        return Clothing(
            id,
            rand_from_bounds(order_id_bounds),
            rand_from_bounds(shipment_id_bounds),
            None, # choice(clothing_types, Clothing.type_bounds),
            None, # choice(defect_types, Clothing.defect_type_bounds),
            None, # choice(Clothing.possible_clothing_names)
            None
        )

    def tuplefy(self) -> Tuple:
        return (self.id,
                self.order_id,
                self.shipment_id,
                self.type,
                self.defect_type,
                self.name,
                self.comment)
