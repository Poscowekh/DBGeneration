from src.random_value_factory import *
from src.departments import Department
from src.people import Manager, NotBannedCustomer, Courier
from enum import Enum


class OrderStatus(Enum):
    """
    Status of an order as a whole.\n
    For example:
    \t1) if none clothing piece is yet delievered back from cleaning department then status should be 'being_cleaned'
    \t2) if at least one piece of clothing is not yet delievered back from cleaning department then status should be 'awaiting_other_clothes'
    """

    created = "created"
    being_cleaned = "being cleaned"
    awaiting_other_clothes = "awaiting other clothes"
    arrived_back_to_department = "arrived back to department"
    arrived_to_customer = "arrived to customer"


@dataclass(frozen=True)
class Order(RandomEntry):
    __instances__: ClassVar[List[RandomEntry]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "orders"

    customer_id: int
    department_id: int
    manager_id: int

    # dates
    creation_date: Date
    due_date: Date
    actual_finish_date: Date

    status: str

    # flags
    is_prepayed: bool
    is_express: bool
    to_be_delievered: bool

    # comments
    customer_comment: str
    delivery_comment: str

    def __eq__(self, other) -> bool:
        return self.customer_id == other.customer_id and \
               self.manager_id == other.manager_id and \
               self.department_id == other.department_id and \
               self.is_prepayed == other.is_prepayed and \
               self.is_express == other.is_express and \
               self.to_be_delievered == other.to_be_delievered and \
               self.creation_date == other.creation_date and \
               self.due_date == other.due_date and \
               self.actual_finish_date == other.actual_finish_date and \
               self.status == other.status and \
               self.customer_comment == other.customer_comment and \
               self.delivery_comment == other.delivery_comment

    possible_due_date_delays: ClassVar[array_t] = array([
        timedelta(days=4), timedelta(days=4),
        timedelta(days=7), timedelta(days=7)
    ], dtype=timedelta)
    """Time periods in days between order creation and due date"""

    possible_actual_finish_date_deltas: ClassVar[array_t] = array([
        -timedelta(days=1), -timedelta(days=1), -timedelta(days=1),
        timedelta(days=0), timedelta(days=0), timedelta(days=0),
        timedelta(days=1), timedelta(days=1)
    ], dtype=timedelta)
    """Time periods in days between order creation an actual finish date"""

    possible_statuses: ClassVar[array_t] = array([
        OrderStatus.created,
        OrderStatus.being_cleaned,
        OrderStatus.awaiting_other_clothes,
        OrderStatus.arrived_back_to_department,
        OrderStatus.arrived_to_customer
    ], dtype=OrderStatus)

    possible_customer_comments: ClassVar[array_t] = array([
        "PlaceholderCustomerComment"
    ], dtype=str)

    possible_delivery_comments: ClassVar[array_t] = array([
        "PlaceholderDeliveryComment"
    ], dtype=str)

    def create(not_banned_customers: List[NotBannedCustomer], *args, **kwargs) -> RandomEntry:
        creation_date: Date = RandomValueFactory.create_date()
        due_date: Date = None

        is_express = rand_bool()
        if is_express:
            due_date = creation_date + timedelta(days=2)
        else:
            due_date = creation_date + choice(Order.possible_due_date_delays)

        status: OrderStatus = choice(Order.possible_statuses)

        finished_date: Date = None
        if status == OrderStatus.arrived_back_to_department or status == OrderStatus.arrived_to_customer:
            finished_date = due_date + choice(Order.possible_actual_finish_date_deltas)

        to_be_delievered: bool = None
        if status == OrderStatus.arrived_to_customer:
            to_be_delievered = True
        elif status == OrderStatus.arrived_back_to_department:
            to_be_delievered = False
        else:
            to_be_delievered = rand_bool()

        status: str = status.value

        delivery_comment: str = none_or(choice(Order.possible_delivery_comments))

        if not to_be_delievered:
            delivery_comment = None

        customer_id: int = choice(not_banned_customers).id
        department_id: int = Department.bounds(Department).random()
        manager_id: int = Manager.bounds(Manager).random() + Courier.bounds(Courier).count()

        return Order(
            customer_id,
            department_id,
            manager_id,

            creation_date,
            due_date,
            finished_date,

            status,

            rand_bool(), # is_prepayed
            is_express,
            to_be_delievered,

            None, #none_or(choice(Order.possible_customer_comments)),  # customer comment
            None  #none_or(choice(Order.possible_delivery_comments)) if to_be_delievered else None # delivery comment
        )

@dataclass
class UnfinishedOrder(GeneratedEntry):
    """Order with one of not-finished statuses"""

    entry: Order
