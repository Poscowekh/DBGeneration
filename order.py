from datetime import timedelta
from basic_factory import *
from enum import Enum

class Status(Enum):
    initiated = "initiated",
    being_shipped = "being shipped",
    being_sorted_for_cleaning = "being sorted for cleaning",
    being_cleaned = "being cleaned",
    being_sorted_for_delivery_back = "being sorted for delivery back",
    delievered_back_to_department = "delievered back to department",
    delievered_to_client = "delievered to client"


@dataclass(frozen=True)
class Order(RandomEntry):
    customer_id: int
    department_id: int

    creation_date: Date
    due_date: Date
    actual_finish_date: Date

    possible_due_date_delays: ClassVar = nparray([
        timedelta(days=2), # express
        timedelta(days=4), timedelta(days=4),
        timedelta(days=7), timedelta(days=7)
    ], dtype=timedelta)

    possible_actual_finish_date_deltas: ClassVar = nparray([
        -timedelta(days=1), -timedelta(days=1),
        timedelta(), timedelta(), timedelta(),
        timedelta(days=1), timedelta(days=1),
        timedelta(days=2)
    ], dtype=timedelta)

    current_status: str

    possible_statuses: ClassVar = nparray([
        Status.initiated,
        Status.being_shipped,
        Status.being_sorted_for_cleaning,
        Status.being_cleaned,
        Status.being_sorted_for_delivery_back,
        Status.delievered_back_to_department, Status.delievered_back_to_department, # for twice the chance
        Status.delievered_to_client, Status.delievered_to_client # for twice the chance
    ], dtype=Status)

    is_prepayed: bool
    is_express: bool
    to_be_delievered: bool

    customer_comment: str
    delivery_comment: str

    possible_customer_comments: ClassVar = nparray([
        "PlaceholderCustomerComment"
    ], dtype=str)

    possible_delivery_comments: ClassVar = nparray([
        "PlaceholderDeliveryComment"
    ], dtype=str)

    def create(customer_id_bounds: Tuple[int, int],
               department_id_bounds: Tuple[int, int],
               *args,
               **kwargs):
        id = Order.latest_id
        Order.latest_id += 1

        creation_date = BasicFactory.create_date()
        due_date = creation_date + choice(Order.possible_due_date_delays)

        is_express = rand_bool()
        if is_express:
            due_date = creation_date + timedelta(days=2)

        status = choice(Order.possible_statuses)

        finished_date = None
        if status == Status.delievered_to_client or status.delievered_back_to_department:
            finished_date = creation_date + choice(Order.possible_actual_finish_date_deltas)

        to_be_delievered = rand_bool()
        if status == Status.delievered_to_client:
            to_be_delievered = True

        return Order(
            id,
            rand_from_bounds(customer_id_bounds),
            rand_from_bounds(department_id_bounds),
            creation_date,
            due_date,
            finished_date,
            status.value,
            rand_bool(),
            rand_bool(),
            to_be_delievered,
            None, # choice(Order.possible_customer_comments)
            None # choice(Order.possible_delivery_comments)
        )
