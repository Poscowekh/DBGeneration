from truck import *
from typing import Tuple
from enum import IntEnum


class ShipmentJob(IntEnum):
    dep_to_sort = 0,
    sort_to_clean = 1,
    clean_to_sort = 2,
    sort_to_dep = 3,
    sort_to_del = 4


@dataclass(frozen=True)
class Shipment(RandomEntry):
    department_id: int
    sorting_facility_id: int
    cleaning_facility_id: int
    truck_id: int
    origin: str
    destination: str

    possicble_job_types: ClassVar = nparray([
        ShipmentJob.dep_to_sort,
        ShipmentJob.sort_to_clean,
        ShipmentJob.clean_to_sort,
        ShipmentJob.sort_to_dep,
        ShipmentJob.sort_to_del
    ], dtype=int)

    def create(departments
               sorting_facility_id_bounds: Tuple[int, int],
               cleaning_facility_id_bounds: Tuple[int, int],
               truck_id_bounds: Tuple[int, int],

               ) \
            -> RandomValue:
        job = choice(ShipmentJob.possicble_job_types)

        return ShipmentJob(

        )

    @staticmethod
    def __job_to_ids__(department_id_bounds: Tuple[int, int],
                       sorting_facility_id_bounds: Tuple[int, int],
                       cleaning_facility_id_bounds: Tuple[int, int],
                       job: ShipmentJob
                       ) \
            -> Tuple[Union[int, None],
                     Union[int, None],
                     Union[int, None]
            ]:
        if job == ShipmentJob.dep_to_sort:
            return rand_from_bounds(department_id_bounds), \
                   rand_from_bounds(sorting_facility_id_bounds), \
                   None

        elif job == ShipmentJob.sort_to_clean:
            return None, \
                   rand_from_bounds(sorting_facility_id_bounds), \
                   rand_from_bounds(cleaning_facility_id_bounds)

        elif job == ShipmentJob.clean_to_sort: