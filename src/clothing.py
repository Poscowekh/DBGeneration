from src.random_value_factory import *
from src.order import UnfinishedOrder
from src.shipment import Shipment
from enum import Enum


class ClothingStatus(Enum):
    """Possible statuses of individual clothing piece. Independent from order status"""

    given_in = "given_in"
    being_shipped = "being shipped for sorting"
    being_sorted_for_cleaning = "being sorted for cleaning"
    being_cleaned = "being cleaned"
    being_sorted_for_delivery_back = "being sorted for delivery back"#
    #delievered_back_to_department = "delievered back to department"
    #delievered_to_client = "delievered to client"


@dataclass(frozen=True)
class Clothing(RandomEntry):
    __instances__: ClassVar[List[RandomEntry]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "clothing"

    order_id: int
    shipment_id: int

    status: str

    type: str
    defect_type: str

    name: str
    comment: str

    type_bounds: ClassVar[Bounds] = Bounds(1, 3)
    defect_type_bounds: ClassVar[Bounds] = Bounds(1, 4)

    possible_clothing_names: ClassVar[array_t] = array([
        "PlaceholderClothingName"
    ], dtype=str)

    possible_statuses: ClassVar[array_t] = array([
        ClothingStatus.given_in,
        ClothingStatus.being_shipped, ClothingStatus.being_shipped,  # x2 the chance
        ClothingStatus.being_sorted_for_cleaning,
        ClothingStatus.being_cleaned,
        ClothingStatus.being_sorted_for_delivery_back
    ], dtype=ClothingStatus)

    possible_clothing_comment: ClassVar[array_t] = array([
        "PlaceholderClothingComment"
    ], dtype=str)

    def create(unfinished_orders: List[UnfinishedOrder], *args, **kwargs) -> RandomEntry:
        status: ClothingStatus = choice(Clothing.possible_statuses)

        order_id: int = choice(unfinished_orders).id

        shipment_id: int = None
        if status == ClothingStatus.being_shipped:
            shipment_id: int = Shipment.bounds(Shipment).random()

        status: str = status.value

        return Clothing(
            order_id,
            shipment_id,
            status,
            none_or(choice(clothing_types, Clothing.type_bounds.random())),
            none_or(choice(defect_types, Clothing.defect_type_bounds.random())),
            none_or(choice(Clothing.possible_clothing_names)),
            none_or(choice(Clothing.possible_clothing_comment))
        )
