from src.random_value_factory import *
from src.departments import Department, SortingDepartment, CleaningDepartment
from src.truck import WorkingTruck
from enum import Enum

class ShipmentJob(Enum):
    """Types of possible shipment jobs"""

    dpt_to_sort = "department_to_sorting_department"
    sort_to_clean = "sorting_department_to_cleaning_department"
    clean_to_sort = "cleaning_department_to_sorting_department"
    sort_to_dpt = "sorting_department_to_department"
    sort_to_cust = "sorting_department_to_customer"


@dataclass(frozen=True)
class Shipment(RandomEntry):
    __instances__: ClassVar[List[RandomEntry]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "shipments"

    department_id: int
    sorting_department_id: int
    cleaning_department_id: int
    truck_id: int
    """must be unique"""

    shipment_type: str
    is_on_route: bool

    def __eq__(self, other) -> bool:
        if not self.truck_id or not other.truck_id:
            return False
        return self.truck_id == other.truck_id

    possible_job_types: ClassVar[array_t] = array([
        ShipmentJob.dpt_to_sort, ShipmentJob.dpt_to_sort,       # x2 the chance
        ShipmentJob.sort_to_clean, ShipmentJob.sort_to_clean,   # x2 the chance
        ShipmentJob.clean_to_sort, ShipmentJob.clean_to_sort,   # x2 the chance
        ShipmentJob.sort_to_dpt,
        ShipmentJob.sort_to_cust
    ], dtype=ShipmentJob)

    @staticmethod
    def __jot_to_ids__(job: ShipmentJob, department_id: int, cleaning_department: int) -> None:
        """sets ids needed for specified job"""

        if job == ShipmentJob.dpt_to_sort or job == ShipmentJob.sort_to_dpt:
            department_id = Department.bounds(Department).random()
        elif job == ShipmentJob.sort_to_clean or job == ShipmentJob.clean_to_sort:
            cleaning_department = CleaningDepartment.bounds(CleaningDepartment).random() + \
                                  SortingDepartment.bounds(SortingDepartment).count() + \
                                  Department.bounds(Department).count()
        elif job == ShipmentJob.sort_to_cust:
            pass # truck driver gets addresses from customer_ids from clothing order_ids
        else:
            raise ValueError("Impossible shipment job")

    def create(working_trucks: List[WorkingTruck], shipment_to_w_trucks_ratio: int) -> RandomValue:
        job: ShipmentJob = choice(Shipment.possible_job_types)

        department_id: int = None
        sorting_department_id: int = SortingDepartment.bounds(SortingDepartment).random() + \
                                     Department.bounds(Department).count()
        cleaning_department_id: int = None

        # setting ids
        Shipment.__jot_to_ids__(job, department_id, cleaning_department_id)

        job: str = job.value

        truck_id: int = None
        is_on_route: bool = False

        if not rand_bool(shipment_to_w_trucks_ratio * 2):
            truck_id, _ = WorkingTruck.choose_unused(working_trucks)
            if rand_bool():
                is_on_route = True

        return Shipment(
            department_id,
            sorting_department_id,
            cleaning_department_id,
            truck_id,
            job,
            is_on_route
        )
